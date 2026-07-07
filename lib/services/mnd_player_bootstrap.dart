import 'package:mnd_core/mnd_core.dart' hide ScriptCacheService;
import 'package:mnd_player/services/expression_evaluator.dart';
import 'package:mnd_player/utils/file_storage.dart';
import 'package:mnd_player/utils/file_storage_asset_store.dart';
import 'package:mnd_player/services/script_cache_service.dart';
import 'package:mnd_player_kit/services/key_derivation_service.dart';

class MndPlayerBootstrap {
  static void initialize({
    bool debugLogs = false,
    String? appSecret,
    ScriptAssetStore? assetStoreOverride,
  }) {
    if (appSecret != null) {
      KeyDerivationService.setAppSecret(appSecret);
    }

    final assetStore = assetStoreOverride ?? FileStorageAssetStore(
      readJson: (p) => FileStorage.readJsonFile(p),
      exists: (p) => FileStorage.exists(p),
      readBytes: (p) => FileStorage.readBytes(p),
    );

    ScriptExecutor.configure(
      expressionEngine: _AppExpressionEngine(),
      assetStore: assetStore,
      debugLogsEnabled: debugLogs,
    );

    ScriptCacheService().setStore(assetStore);
  }
}

class _AppExpressionEngine implements ScriptExpressionEngine {
  final _evaluator = ExpressionEvaluatorService();

  @override
  dynamic evaluate(String expression, Map<String, dynamic> context) {
    return _evaluator.evaluate(expression, context);
  }
}
