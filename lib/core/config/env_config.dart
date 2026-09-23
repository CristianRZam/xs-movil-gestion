import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
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
}
