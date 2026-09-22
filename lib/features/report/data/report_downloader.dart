import 'dart:io';
import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ReportDownloader {
  final ApiClient apiClient;
  ReportDownloader(this.apiClient);

  Future<String> download({required String type, required String format, required DateTime start, required DateTime end}) async {
    final response = await apiClient.dio.post<List<int>>(
      '/reports/$type/$format',
      data: {'startDate': _date(start), 'endDate': _date(end)},
      options: Options(responseType: ResponseType.bytes),
    );
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final extension = format == 'excel' ? 'xlsx' : 'pdf';
    final file = File('${directory.path}/${type}_reporte_${_date(start)}_${_date(end)}.$extension');
    await file.writeAsBytes(response.data ?? const [], flush: true);
    // No se considera un error si el dispositivo no tiene una app para abrir
    // Excel/PDF: el archivo ya quedó guardado correctamente.
    await OpenFilex.open(file.path);
    return file.path;
  }

  String _date(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
