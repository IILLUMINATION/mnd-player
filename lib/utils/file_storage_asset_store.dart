import 'dart:typed_data';

import 'package:mnd_core/mnd_core.dart';

/// Адаптер: статический [FileStorage] из `mnd_player` как [ExtendedAssetStore].
///
/// Позволяет постепенно мигрировать с прямых вызовов [FileStorage] на
/// dependency-injected [ExtendedAssetStore] без переписывания кода.
class FileStorageAssetStore implements ExtendedAssetStore {
  final Future<Map<String, dynamic>> Function(String path) _readJson;
  final Future<bool> Function(String path) _exists;
  final Future<Uint8List?> Function(String path) _readBytes;
  final Future<String> Function(String path) _readString;
  final Future<List<String>> Function(String path) _listDirectory;

  FileStorageAssetStore({
    required Future<Map<String, dynamic>> Function(String path) readJson,
    required Future<bool> Function(String path) exists,
    Future<Uint8List?> Function(String path)? readBytes,
    Future<String> Function(String path)? readString,
    Future<List<String>> Function(String path)? listDirectory,
  }) :
    _readJson = readJson,
    _exists = exists,
    _readBytes = readBytes ?? ((_) async => null),
    _readString = readString ?? ((_) async => ''),
    _listDirectory = listDirectory ?? ((_) async => []);

  @override
  Future<bool> exists(String path) => _exists(path);

  @override
  Future<Map<String, dynamic>> readJson(String path) => _readJson(path);

  @override
  Future<List<int>> readBytes(String path) async {
    final result = await _readBytes(path);
    return result ?? [];
  }

  @override
  Future<String> readString(String path) => _readString(path);

  @override
  Future<List<String>> listDirectory(String path) => _listDirectory(path);
}
