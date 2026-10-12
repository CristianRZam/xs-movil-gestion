import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  /// Reemplaza solo hosts locales devueltos por el backend por el host que la
  /// aplicación móvil puede alcanzar (por ejemplo, 10.0.2.2 en el emulador).
  static String resolveBackendFileUrl(String url) {
    final source = Uri.tryParse(url);
    final configuredBase = Uri.tryParse(baseUrl);
    if (source == null ||
        configuredBase == null ||
        configuredBase.host.isEmpty) {
      return url;
    }

    final isLocalBackendHost =
        source.host == 'localhost' || source.host == '127.0.0.1';
    if (source.hasScheme && !isLocalBackendHost) return url;

    if (source.hasScheme) {
      return source
          .replace(
            scheme: configuredBase.scheme,
            host: configuredBase.host,
            port: configuredBase.hasPort ? configuredBase.port : null,
          )
          .toString();
    }

    return configuredBase
        .replace(
          path: source.path.startsWith('/') ? source.path : '/${source.path}',
          query: source.hasQuery ? source.query : null,
        )
        .toString();
  }

  static int get productImageMaxFileSizeBytes {
    const defaultMegabytes = 2;
    final configuredMegabytes = int.tryParse(
      dotenv.env['PRODUCT_IMAGE_MAX_FILE_SIZE_MB'] ?? '',
    );
    final megabytes = configuredMegabytes != null && configuredMegabytes > 0
        ? configuredMegabytes
        : defaultMegabytes;
    return megabytes * 1024 * 1024;
  }

  static int get productPageSize {
    final configuredSize = int.tryParse(dotenv.env['PRODUCT_PAGE_SIZE'] ?? '');
    return configuredSize != null && configuredSize > 0 ? configuredSize : 50;
  }

  static int get inventoryMovementPageSize {
    final configuredSize = int.tryParse(
      dotenv.env['INVENTORY_MOVEMENT_PAGE_SIZE'] ?? '',
    );
    return configuredSize != null && configuredSize > 0 ? configuredSize : 20;
  }

  static int get salesAndOrdersPageSize {
    final size = int.tryParse(dotenv.env['SALES_ORDERS_PAGE_SIZE'] ?? '');
    return size != null && size > 0 ? size : 20;
  }

  static int get cashSessionHistoryPageSize {
    final size = int.tryParse(
      dotenv.env['CASH_SESSION_HISTORY_PAGE_SIZE'] ?? '',
    );
    return size != null && size > 0 ? size : 10;
  }
}
