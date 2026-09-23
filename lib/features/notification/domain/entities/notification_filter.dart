import 'package:equatable/equatable.dart';

class NotificationFilter extends Equatable {
  const NotificationFilter({
    this.type,
    this.priority,
    this.read,
    this.fromDate,
    this.toDate,
    this.search,
  });

  final String? type;
  final String? priority;
  final bool? read;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? search;

  bool get hasActiveFilters =>
      type != null ||
      priority != null ||
      read != null ||
      fromDate != null ||
      toDate != null;

  NotificationFilter copyWith({
    String? type,
    String? priority,
    bool? read,
    DateTime? fromDate,
    DateTime? toDate,
    String? search,
    bool clearType = false,
    bool clearPriority = false,
    bool clearRead = false,
    bool clearDates = false,
    bool clearSearch = false,
  }) {
    return NotificationFilter(
      type: clearType ? null : type ?? this.type,
      priority: clearPriority ? null : priority ?? this.priority,
      read: clearRead ? null : read ?? this.read,
      fromDate: clearDates ? null : fromDate ?? this.fromDate,
      toDate: clearDates ? null : toDate ?? this.toDate,
      search: clearSearch ? null : search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [type, priority, read, fromDate, toDate, search];
}
