import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/model/subject.dart';
import 'package:the_academy/utils/app_contanants.dart';

class SubjectController extends GetxController {
  final ApiClient apiClient = Get.find();
  List<Subject> _subjects = [];

  List<int> pages = [];
  int _total = 0;

  final int _limit = 10;

  List<Subject> _searched = [];
  List<int> pagesSearched = [];
  int _totalSearched = 0;

  List<Subject> get searched => [..._searched];

  int get totalSearched => _totalSearched;

  int get total => _total;

  List<Subject> get subjects {
    return _subjects;
  }

  Future<void> fetchAndSetSubjects(int pageNum,
      {String? categoryId, bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _subjects = [];
    }

    if (pages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = subjects.length;
    final category =
        categoryId != null ? '&${AppConstants.categoryId}=$categoryId' : '';

    try {
      final response = await apiClient.getData(
          '${AppConstants.subjectGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest$category');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _total = extractedData['total'] ?? _total;

        final data = extractedData['data'] as List<dynamic>;

        List<Subject> loadedSubjects = [];

        for (var subject in data) {
          if (subject['_id'] != null &&
              subject['image'] != null &&
              subject['nameAr'] != null &&
              subject['nameEn'] != null) {
            loadedSubjects.add(Subject(
              id: subject['_id'],
              nameAr: subject['nameAr'],
              nameEn: subject['nameEn'],
              image: subject['image'],
              categoryId: subject['category']['_id'],
            ));
          }
        }

        if (loadedSubjects.isNotEmpty) {
          _subjects.addAll(loadedSubjects);
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
    String? categoryId,
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
    final category =
        categoryId != null ? '&${AppConstants.categoryId}=$categoryId' : '';

    try {
      final response = await apiClient.getData(
          '${AppConstants.subjectGet}?${AppConstants.limit}=$limit&${AppConstants.offset}=$offest$search$category');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _totalSearched = extractedData['total'] ?? _totalSearched;

        final data = extractedData['data'] as List<dynamic>;

        List<Subject> loadedSubjects = [];

        for (var subject in data) {
          if (subject['_id'] != null &&
              subject['image'] != null &&
              subject['nameAr'] != null &&
              subject['nameEn'] != null) {
            loadedSubjects.add(Subject(
              id: subject['_id'],
              nameAr: subject['nameAr'],
              nameEn: subject['nameEn'],
              image: subject['image'],
              categoryId: subject['category']['_id'],
            ));
          }
        }

        if (pagesSearched.contains(pageNum)) return;

        _searched.addAll(loadedSubjects);
        update();

        if (loadedSubjects.isNotEmpty) {
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
