import 'package:equatable/equatable.dart';

class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final bool hasMore;
  final String? lastCursor;

  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastCursor,
  });

  @override
  List<Object?> get props => [items, hasMore, lastCursor];
}

class PaginationParams extends Equatable {
  final int limit;
  final String? cursor;

  const PaginationParams({this.limit = 15, this.cursor});

  @override
  List<Object?> get props => [limit, cursor];
}
