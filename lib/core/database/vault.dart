import 'dart:convert';
import 'dart:io';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/models.dart';

class VaultDatabase extends GeneratedDatabase {
  VaultDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => customStatement(
      'CREATE TABLE vault (id INTEGER PRIMARY KEY CHECK(id=1), payload BLOB NOT NULL)',
    ),
  );
}

class Vault {
  static const secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final VaultDatabase db;
  final SecretKey key;
  final cipher = AesGcm.with256bits();
  Vault(this.db, this.key);
  static Future<Vault> open() async {
    final directory = await getApplicationSupportDirectory(),
        cipher = AesGcm.with256bits();
    final file = File('${directory.path}/hydramind.sqlite');
    var encoded = await secure.read(key: 'vault_key_v1');
    if (encoded == null) {
      if (await file.exists()) {
        throw StateError('Existing vault key unavailable');
      }
      encoded = base64Encode(
        await (await cipher.newSecretKey()).extractBytes(),
      );
      await secure.write(key: 'vault_key_v1', value: encoded);
    }
    return Vault(
      VaultDatabase(NativeDatabase.createInBackground(file)),
      SecretKey(base64Decode(encoded)),
    );
  }

  Future<AppData> load() async {
    final row = await db
        .customSelect('SELECT payload FROM vault WHERE id=1')
        .getSingleOrNull();
    if (row == null) return AppData();
    final clear = await cipher.decrypt(
      SecretBox.fromConcatenation(
        row.read<Uint8List>('payload'),
        nonceLength: 12,
        macLength: 16,
      ),
      secretKey: key,
    );
    return AppData.fromJson(jsonDecode(utf8.decode(clear)));
  }

  Future<void> save(AppData data) async {
    final box = await cipher.encrypt(
      utf8.encode(data.encode()),
      secretKey: key,
    );
    await db.customStatement(
      'INSERT INTO vault(id,payload) VALUES(1,?) ON CONFLICT(id) DO UPDATE SET payload=excluded.payload',
      [box.concatenation()],
    );
  }

  Future<void> clear() async {
    await db.customStatement('PRAGMA secure_delete=ON');
    await db.customStatement('DELETE FROM vault');
    await db.customStatement('VACUUM');
  }
}
