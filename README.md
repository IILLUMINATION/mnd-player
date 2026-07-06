# mnd_player

Full-featured Meander quest player for Flutter. Load `.mnd` quest files and
play interactive text adventures with audio, timers, save/load, and script execution.

Built on [mnd_core](https://github.com/IILLUMINATION/mnd-core).

## Features

- Full quest player with `GameScreen` widget
- Save/Load game system with multiple slots
- Interactive node navigation with conditional transitions
- Built-in timer with configurable countdowns
- Audio playback (background music, sound effects)
- Markdown content rendering with styled themes
- Expression evaluation (math, string functions, variables)
- Quest table viewer for debugging
- HMAC-signed quest integrity verification
- AES-encrypted quest content support

## Quick Start

```dart
import 'package:mnd_player/mnd_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the player engine
  MndPlayerBootstrap.initialize();

  runApp(MaterialApp(
    home: GameScreen(
      questId: 'my_quest',
      startNodeId: 'start',
    ),
  ));
}
```

## Standalone Builder

To bundle your `.mnd` quest as a standalone Flutter app with CI/CD builds for
Android, Web, Windows, and Linux — use the
[mnd-standalone-builder](https://github.com/IILLUMINATION/mnd-standalone-builder).

## License

GNU Affero General Public License v3.0
