import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mnd_player/utils/file_storage_asset_store.dart';
import 'package:mnd_core/mnd_core.dart';

void main() {
  group('FileStorageAssetStore', () {
    late Map<String, String> storage;

    FileStorageAssetStore createStore() {
      return FileStorageAssetStore(
        readJson: (path) async {
          if (!storage.containsKey(path)) throw Exception('not found');
          return jsonDecode(storage[path]!) as Map<String, dynamic>;
        },
        exists: (path) async => storage.containsKey(path),
        readBytes: (path) async {
          if (!storage.containsKey(path)) return null;
          return Uint8List.fromList(utf8.encode(storage[path]!));
        },
        readString: (path) async => storage[path] ?? '',
        listDirectory: (path) async => storage.keys.where((k) => k.startsWith(path)).toList(),
      );
    }

    setUp(() {
      storage = {};
    });

    test('exists returns true for existing file', () async {
      storage['quests/foo/config.json'] = '{}';
      final store = createStore();
      expect(await store.exists('quests/foo/config.json'), isTrue);
    });

    test('exists returns false for missing file', () async {
      final store = createStore();
      expect(await store.exists('nonexistent'), isFalse);
    });

    test('readJson returns parsed JSON', () async {
      storage['quests/test/config.json'] = '{"title": "Test", "version": "1.0"}';
      final store = createStore();
      final result = await store.readJson('quests/test/config.json');
      expect(result['title'], 'Test');
      expect(result['version'], '1.0');
    });

    test('readJson throws for missing file', () async {
      final store = createStore();
      expect(() => store.readJson('missing.json'), throwsException);
    });

    test('readBytes returns bytes for existing file', () async {
      storage['image.png'] = 'binary-data';
      final store = createStore();
      final bytes = await store.readBytes('image.png');
      expect(bytes, isNotEmpty);
      expect(utf8.decode(bytes), 'binary-data');
    });

    test('readBytes returns empty list for missing file', () async {
      final store = createStore();
      final bytes = await store.readBytes('missing.png');
      expect(bytes, isEmpty);
    });

    test('readString returns file content', () async {
      storage['text.txt'] = 'hello world';
      final store = createStore();
      expect(await store.readString('text.txt'), 'hello world');
    });

    test('listDirectory returns files in directory', () async {
      storage['quests/test/config.json'] = '{}';
      storage['quests/test/nodes.json'] = '{}';
      storage['quests/other/config.json'] = '{}';
      final store = createStore();
      final files = await store.listDirectory('quests/test/');
      expect(files.length, 2);
    });

    test('ScriptAssetStore interface compliance — exists + readJson', () async {
      storage['data.json'] = '{"key": "value"}';
      final store = createStore();
      // store is both ExtendedAssetStore and ScriptAssetStore
      final assetStore = store as ScriptAssetStore;
      expect(await assetStore.exists('data.json'), isTrue);
      final data = await assetStore.readJson('data.json');
      expect(data['key'], 'value');
    });
  });
}
