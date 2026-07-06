import 'package:flutter/material.dart';
import 'package:mnd_player/widgets/glass.dart';

class GameTimerWidget extends StatelessWidget {
  final double remainingSeconds;
  final double totalSeconds;
  const GameTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  String _format(double s) {
    final d = Duration(milliseconds: (s * 1000).toInt());
    return "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  Color _getColor() {
    if (totalSeconds == 0) return Colors.green;
    final pct = remainingSeconds / totalSeconds;
    if (pct < 0.2) return Colors.red;
    if (pct < 0.5) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassSurface(
        radius: 24,
        blurSigma: 5,
        tintColor: Colors.black.withOpacity(0.35),
        borderColor: Colors.white24,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 24),
              Text(
                _format(remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
