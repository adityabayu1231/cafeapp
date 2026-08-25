import 'cafe_entity.dart';

class CafeListResult {
  final List<CafeEntity> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const CafeListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}