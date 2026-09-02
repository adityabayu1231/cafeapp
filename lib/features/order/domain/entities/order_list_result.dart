import 'package:equatable/equatable.dart';
import 'order_entity.dart';

class OrderListResult extends Equatable {
  final List<OrderEntity> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const OrderListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  @override
  List<Object?> get props => [items, currentPage, lastPage, total];
}