import 'package:flutter/foundation.dart';
import '../models/category_item.dart';
import '../services/api_service.dart';

enum CatalogStatus { idle, loading, success, error }

class CatalogProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  CatalogStatus _status = CatalogStatus.idle;
  List<CategoryItem> _categories = [];
  String _errorMessage = '';
  final Map<String, int?> _itemCounts = {};

  CatalogStatus get status => _status;
  List<CategoryItem> get categories => List.unmodifiable(_categories);
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == CatalogStatus.loading;

  int? getItemCount(String slug) => _itemCounts[slug];

  Future<void> loadCategories({bool force = false}) async {
    if (_status == CatalogStatus.success && !force) return;

    if (force) {
      _api.clearCache();
    }

    _status = CatalogStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final slugs = await _api.fetchCategories();

      // Fetch item counts for all categories in parallel
      final results = await Future.wait(
        slugs.map((slug) async {
          try {
            final products = await _api.fetchProductsByCategory(slug);
            return products.length;
          } catch (e) {
            if (kDebugMode) {
              print('[CatalogProvider] Failed to count "$slug": $e');
            }
            return null; // null means counting failed
          }
        }),
      );

      _categories = List.generate(slugs.length, (i) {
        final count = results[i];
        _itemCounts[slugs[i]] = count;
        return CategoryItem(
          slug: slugs[i],
          displayName: CategoryItem.displayNameFromSlug(slugs[i]),
          itemCount: count,
        );
      });

      _status = CatalogStatus.success;
    } catch (e) {
      _errorMessage = 'Could not load categories. Check your connection.';
      _status = CatalogStatus.error;
      if (kDebugMode) {
        print('[CatalogProvider] Error: $e');
      }
    }

    notifyListeners();
  }
}
