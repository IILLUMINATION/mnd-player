# mnd_player

Полноценный плеер для текстовых квестов Meander.
Загружает `.mnd` файлы, воспроизводит аудио, таймеры, сохранения.

⚠️ **Лицензия: GNU AGPL v3.0**.

## Что внутри

- **GameScreen** — главный экран плеера (скрипты, переходы, аудио, таймер, HUD)
- **LoadGameScreen** — выбор/загрузка сохранений
- **TableViewerScreen** — отладчик таблиц
- **ContentDisplayFactory** — рендерер контент-айтемов (текст, кнопки, картинки, аудио, чат, модалки)
- **Провайдеры** (Riverpod): GameState, Nodes, Templates, Tags, Quests
- **Сервисы**: ExpressionEvaluator, FontService, FileStorage, ScriptCache

## Быстрый старт

```dart
import 'package:mnd_player/mnd_player.dart';

// Десктоп/мобилки:
MndPlayerBootstrap.initialize();

// Web:
final bytes = await rootBundle.load('assets/quest.mnd');
final store = InMemoryAssetStore.fromZip(bytes.buffer.asUint8List());
FileStorage.memoryStore = store;

// Запуск
GameScreen(
  questId: 'my_quest',
  startNodeId: 'start',
)
```

## Standalone билдер

Чтобы собрать свой квест как отдельное приложение (Android APK, Linux, Windows, Web) — используйте [mnd-standalone-builder](https://github.com/IILLUMINATION/mnd-standalone-builder).

## Архитектура

```
mnd_core
   ↑
mnd_player_kit
   ↑
mnd_player ← вы здесь
   ↑
main_app (приложение с редактором и маркетом)
```

## Тесты

```bash
flutter test  # 56 тестов
```

## Зависимости

- [mnd_core](https://github.com/IILLUMINATION/mnd-core)
- [mnd_player_kit](https://github.com/IILLUMINATION/mnd-kit)
- flutter_riverpod, audioplayers, markdown_widget, photo_view, google_fonts, crypto, archive
