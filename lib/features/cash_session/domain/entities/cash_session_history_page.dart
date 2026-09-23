import 'cash_session.dart';

class CashSessionHistoryPage {
  const CashSessionHistoryPage({required this.items, required this.totalElements, required this.page, required this.size, required this.hasMore});
  final List<CashSession> items;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;
}
