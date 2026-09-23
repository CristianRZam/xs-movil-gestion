class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.hasMore, required this.totalElements});
  final List<T> items;
  final bool hasMore;
  final int totalElements;
}
