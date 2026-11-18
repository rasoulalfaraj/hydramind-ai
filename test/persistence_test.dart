import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydramind/core/database/vault.dart';
import 'package:hydramind/core/domain/models.dart';
import 'package:hydramind/app/controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Encrypted SQLite persists without private plaintext', () async {
    final dir = await Directory.systemTemp.createTemp('hydra-test-');
    final file = File('${dir.path}/vault.sqlite'),
        key = await AesGcm.with256bits().newSecretKey();
    final first = Vault(VaultDatabase(NativeDatabase(file)), key);
    await first.save(
      AppData(
        profile: const Profile(name: 'سارة'),
        entries: [
          Intake(
            id: 'x',
            ml: 250,
            drink: Drink.tea,
            at: DateTime(2026),
            note: 'private_test_note',
          ),
        ],
      ),
    );
    await first.db.close();
    expect(
      utf8.decode(await file.readAsBytes(), allowMalformed: true),
      isNot(contains('private_test_note')),
    );
    final second = Vault(VaultDatabase(NativeDatabase(file)), key);
    expect((await second.load()).entries.single.ml, 250);
    expect((await second.load()).profile.name, 'سارة');
    await second.clear();
    expect((await second.load()).entries, isEmpty);
    await second.db.close();
    await dir.delete(recursive: true);
  });
  test('Wrong key never silently deletes a vault', () async {
    final db = VaultDatabase(NativeDatabase.memory()),
        key = await AesGcm.with256bits().newSecretKey();
    final vault = Vault(db, key);
    await vault.save(AppData(profile: const Profile(name: 'protected')));
    await expectLater(
      Vault(db, await AesGcm.with256bits().newSecretKey()).load(),
      throwsA(anything),
    );
    expect((await vault.load()).profile.name, 'protected');
    await db.close();
  });
  test(
    'Concurrent offline writes are serialized and edits idempotent',
    () async {
      final db = VaultDatabase(NativeDatabase.memory()),
          key = await AesGcm.with256bits().newSecretKey();
      final vault = Vault(db, key),
          controller = AppController(Vault(db, key), AppData());
      final now = DateTime.now();
      await Future.wait([
        for (var i = 0; i < 12; i++)
          controller.add(100, Drink.water, now, '', id: '$i'),
      ]);
      expect((await vault.load()).entries.length, 12);
      await controller.add(200, Drink.coffee, now, '', id: '0');
      expect((await vault.load()).entries.length, 12);
      expect(
        (await vault.load()).entries.firstWhere((e) => e.id == '0').ml,
        200,
      );
      await controller.remove('0');
      expect((await vault.load()).entries.length, 11);
      controller.dispose();
      await db.close();
    },
  );
}
