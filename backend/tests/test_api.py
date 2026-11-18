from unittest.mock import AsyncMock
import httpx
from fastapi.testclient import TestClient
from app.main import app, requests, validate_topic
TOKEN='x'*48

def client(monkeypatch):
    monkeypatch.setenv('HYDRA_CLIENT_TOKEN',TOKEN)
    monkeypatch.setenv('GEMINI_API_KEY','test-only-placeholder')
    requests.clear()
    return TestClient(app)

def test_auth(monkeypatch):
    with client(monkeypatch) as c:
        assert c.post('/v1/coach',json={'question':'مرحبا'}).status_code==401

def test_emergency_no_provider(monkeypatch):
    with client(monkeypatch) as c:
        app.state.client.post=AsyncMock(side_effect=AssertionError('must not call'))
        assert c.post('/v1/coach',json={'question':'لدي ارتباك مع الحر'},headers={'Authorization':f'Bearer {TOKEN}'}).json()=={'topic':'emergency'}

def test_free_text_rejected(monkeypatch):
    with client(monkeypatch) as c:
        app.state.client.post=AsyncMock(return_value=httpx.Response(200,request=httpx.Request('POST','https://example.org'),json={'candidates':[{'content':{'parts':[{'text':'{"topic":"drink 10 litres"}'}]}}]}))
        assert c.post('/v1/coach',json={'question':'عادات'},headers={'Authorization':f'Bearer {TOKEN}'}).json()=={'topic':'general'}

def test_provider_failure(monkeypatch):
    with client(monkeypatch) as c:
        app.state.client.post=AsyncMock(side_effect=httpx.ConnectError('failed'))
        response=c.post('/v1/coach',json={'question':'عادات'},headers={'Authorization':f'Bearer {TOKEN}'})
        assert response.status_code==502
        assert 'test-only-placeholder' not in response.text

def test_extra_health_context_rejected(monkeypatch):
    with client(monkeypatch) as c:
        h={'Authorization':f'Bearer {TOKEN}'}
        assert c.post('/v1/coach',json={'question':'hello','medicalNotes':'private'},headers=h).status_code==422
        assert c.post('/v1/coach',json={'question':'a'*1001},headers=h).status_code==422

def test_gate():
    assert validate_topic('routine','fainting in the heat')=='emergency'
    assert validate_topic({'text':'unsafe'},'hello')=='general'

def test_missing_provider(monkeypatch):
    with client(monkeypatch) as c:
        monkeypatch.delenv('GEMINI_API_KEY')
        assert c.post('/v1/coach',json={'question':'عادات'},headers={'Authorization':f'Bearer {TOKEN}'}).status_code==503

def test_rate_limit(monkeypatch):
    with client(monkeypatch) as c:
        for _ in range(12):
            assert c.post('/v1/coach',json={'question':'heatstroke'},headers={'Authorization':f'Bearer {TOKEN}'}).status_code==200
        assert c.post('/v1/coach',json={'question':'heatstroke'},headers={'Authorization':f'Bearer {TOKEN}'}).status_code==429
