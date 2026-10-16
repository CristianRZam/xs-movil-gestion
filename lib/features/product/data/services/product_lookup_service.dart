import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_lookup.dart';

class ProductLookupService {
  ProductLookupService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProductLookup>> search(String query) async {
    final term = query.trim();
    if (term.length < 2) return const [];
    final response = await _apiClient.dio.get(
      '/product/lookup',
      queryParameters: {'query': term, 'limit': 10},
    );
    final api = ApiResponse<List<ProductLookup>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => ProductLookup.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!api.success || api.data == null) {
      throw Exception(api.message ?? 'No se pudieron buscar productos');
    }
    return api.data!;
  }
}
