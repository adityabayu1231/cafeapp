import 'product_entity.dart';

class ProductListResult {
  final List<ProductEntity> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const ProductListResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}