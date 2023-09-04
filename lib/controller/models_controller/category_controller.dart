import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/category.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/utils/app_contanants.dart';

class CategoryController extends GetxController {
  final ApiClient apiClient = Get.find();
  List<Category> _categories = [];

  List<int> pages = [];
  int _total = 0;

  final int _limit = 10;

  List<Category> _searched = [];
  List<int> pagesSearched = [];
  int _totalSearched = 0;

  List<Category> get searched => [..._searched];

  int get total => _total;
  int get totalSearched => _totalSearched;

  List<Category> get categories {
    return _categories;
  }

  Future<void> fetchAndSetCategories(int pageNum, {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _categories = [];
    }

    if (pages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = categories.length;

    try {
      final response = await apiClient.getData(
          '${AppConstants.categoryGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _total = extractedData['total'] ?? _total;

        final data = extractedData['data'] as List<dynamic>;

        List<Category> loadedCategories = [];

        for (var category in data) {
          if (category['_id'] != null &&
              category['image'] != null &&
              category['nameAr'] != null &&
              category['nameEn'] != null) {
            loadedCategories.add(Category(
              id: category['_id'],
              nameAr: category['nameAr'],
              nameEn: category['nameEn'],
              image: category['image'],
            ));
          }
        }

        if (loadedCategories.isNotEmpty) {
          _categories.addAll(loadedCategories);
        } else {
          pages.remove(pageNum);
        }
        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      pages.remove(pageNum);

      rethrow;
    }
  }

  Future<void> search(
    String name,
    int pageNum, {
    int? lim,
    bool isRefresh = false,
  }) async {
    if (searched.isEmpty) {
      pagesSearched = [];
    } else if (searched.isNotEmpty || isRefresh) {
      pagesSearched = [];
      _searched = [];
    }

    if (searched.isNotEmpty && pagesSearched.contains(pageNum)) {
      return;
    }

    final search = name != '' ? '&${AppConstants.name}=$name' : '';
    final offest = searched.length;
    final limit = lim ?? _limit;

    try {
      final response = await apiClient.getData(
          '${AppConstants.categoryGet}?${AppConstants.limit}=$limit&${AppConstants.offset}=$offest$search');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _totalSearched = extractedData['total'] ?? _totalSearched;

        final data = extractedData['data'] as List<dynamic>;

        List<Category> loadedCategories = [];

        for (var category in data) {
          if (category['_id'] != null &&
              category['image'] != null &&
              category['nameAr'] != null &&
              category['nameEn'] != null) {
            loadedCategories.add(Category(
              id: category['_id'],
              nameAr: category['nameAr'],
              nameEn: category['nameEn'],
              image: category['image'],
            ));
          }
        }

        if (pagesSearched.contains(pageNum)) return;

        _searched.addAll(loadedCategories);
        update();

        if (loadedCategories.isNotEmpty) {
          pagesSearched.add(pageNum);
        }
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
