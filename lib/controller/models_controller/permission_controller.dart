import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/permission.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/services/user_controller.dart';
import 'package:the_academy/utils/app_contanants.dart';

class PermissionController extends GetxController {
  List<Permission> _coachPermissions = [];

  final ApiClient apiClient = Get.find();

  List<Permission> get coachPermissions {
    return _coachPermissions;
  }

  Future<void> fetchAndSetCoachPermission() async {
    try {
      final response = await apiClient.getData(
          '${AppConstants.user}/${AppConstants.getPermissionByRole}?${AppConstants.role}=${UserController.coachRole}');
      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final response1Body = Map<String, dynamic>.from(response.body);

        final data = response1Body['data'] as Map<String, dynamic>;
        List<Permission> loadedPermissions = [];
        data.keys.forEach((key) {
          final permission = data[key];

          if (permission['nameAr'] != null && permission['nameEn'] != null) {
            loadedPermissions.add(Permission(
              id: key,
              nameAr: permission['nameAr'],
              nameEn: permission['nameEn'],
            ));
          }
        });
        _coachPermissions = loadedPermissions;

        update();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }
}
