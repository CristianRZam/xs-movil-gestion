import 'package:app_movil_sistema/features/cash_session/data/models/cash_session_close_request_model.dart';
import 'package:app_movil_sistema/features/cash_session/data/models/cash_session_model.dart';

abstract class CashSessionRemoteDataSource {

  Future<CashSessionModel> openSession(CashSessionModel request,);

  Future<CashSessionModel> getCurrentSession();

  Future<bool> existsOpenSession();

  Future<CashSessionModel> closeSession(CashSessionCloseRequestModel request,);

  Future<List<CashSessionModel>> getHistory();
}