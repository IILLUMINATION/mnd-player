import 'dart:io';
import 'package:mnd_player/utils/file_storage.dart';
import 'package:mnd_player/providers/game_screen_provider.dart';
import 'package:flutter/services.dart';

class FontService {
  static Future<String?> loadQuestFont(String questId, String fileName) async {
    try {
      final fontPath = 'quests/$questId/res/fonts/$fileName';

      final store = GameScreenNotifier.assetStore;
      if (store != null) {
        final bytes = await store.readBytes(fontPath);
        if (bytes.isEmpty) {
          print('⚠️ Шрифт не найден (assetStore): $fontPath');
          return null;
        }
        final fontFamilyName =
            _fontFamilyName(questId, fileName);
        final loader = FontLoader(fontFamilyName);
        loader.addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
        await loader.load();
        return fontFamilyName;
      }

      final fullPath = await FileStorage.getFilePath(fontPath);
      final file = File(fullPath);

      if (!await file.exists()) {
        print('⚠️ Шрифт не найден: $fullPath');
        return null;
      }

      final fontFamilyName = _fontFamilyName(questId, fileName);

      final loader = FontLoader(fontFamilyName);

      final fontData = file.readAsBytes().then((bytes) {
        return ByteData.view(bytes.buffer);
      });

      loader.addFont(fontData);
      await loader.load();

      return fontFamilyName;
    } catch (e) {
      if (!e.toString().contains('already loaded')) {
        print('Ошибка загрузки шрифта: $e');
      }
      return _fontFamilyName(questId, fileName);
    }
  }

  static String _fontFamilyName(String questId, String fileName) {
    final safeQuestId = questId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final safeFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'Font_${safeQuestId}_$safeFileName';
  }
}
