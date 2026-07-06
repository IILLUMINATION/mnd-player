import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mnd_core/mnd_core.dart';
import 'package:mnd_player/utils/file_storage.dart';

export 'package:mnd_core/models/tag.dart' show Tag;

final questTagsProvider = FutureProvider.autoDispose.family<List<Tag>, String>((
  ref,
  questId,
) async {
  return FileStorage.synchronized('config_$questId', () async {
    try {
      final configPath = 'quests/$questId/config.json';
      if (!await FileStorage.exists(configPath)) {
        return [];
      }

      final config = await FileStorage.readJsonFile(configPath);
      final tagsJson = config['tags'] as List<dynamic>? ?? [];
      final tags = tagsJson.map((json) {
        final tag = Tag.fromJson(json as Map<String, dynamic>);
        return Tag(
          id: tag.id,
          name: tag.name,
          questId: questId,
          backgroundAssetId: tag.backgroundAssetId,
          backgroundAudioId: tag.backgroundAudioId,
          folderPath: tag.folderPath,
        );
      }).toList();

      tags.sort((a, b) => a.name.compareTo(b.name));
      return tags;
    } catch (e) {
      return [];
    }
  });
});
