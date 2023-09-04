import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:the_academy/services/user_controller.dart';

import '../../model/http_exception.dart';
import '../../view/widgets/dialogs/error_dialog.dart';
import '../models_controller/transactions_controller.dart';

class TransactionsScreenController extends GetxController {
  bool isLoading = false;
  final scrollController = ScrollController();
  bool _canLoadTransactions = true;
  bool _loadMoreTransactions = false;
  int _pageNumTransactions = 0;

  bool get loadMoreTransactions => _loadMoreTransactions && !_lastPage;
  bool get _lastPage =>
      _transactionController.transactions.length ==
      _transactionController.total;

  //final PermissionController permissionController = Get.find();
  final UserController _userController = Get.find();
  final TransactionController _transactionController =
      Get.put(TransactionController());

  TransactionController get transactionController => _transactionController;
  UserController get userController => _userController;
  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 300) {
        _transactionsPagination();
      }
    });

    Future.delayed(Duration.zero).then((_) => getData());
  }

  Future<void> getData({bool refresh = false}) async {
    refresh ? _canLoadTransactions = false : isLoading = true;
    update();
    try {
      await userController.fetchProfile();

      await _transactionController.fetchAndSetTransactions(
        0,
      );
      _pageNumTransactions = 0;
      _canLoadTransactions = true;
      isLoading = false;
      update();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr).then((_) =>
          refresh ? {_canLoadTransactions = true, update()} : Get.back());
    } catch (error) {
      showErrorDialog('error'.tr).then((_) =>
          refresh ? {_canLoadTransactions = true, update()} : Get.back());
    }
  }

  void _transactionsPagination() async {
    if (_canLoadTransactions) {
      _loadMoreTransactions = true;
      update();

      _canLoadTransactions = false;
      _getTransactions();
    }
  }

  Future<void> _getTransactions() async {
    if (_lastPage) {
      _canLoadTransactions = true;
      _loadMoreTransactions = false;
      update();

      return;
    }
    try {
      await _transactionController.fetchAndSetTransactions(
        ++_pageNumTransactions,
      );
      _canLoadTransactions = true;
    } on HttpException catch (error) {
      _pageNumTransactions--;
      _canLoadTransactions = true;

      showErrorDialog('error'.tr);
      _loadMoreTransactions = false;
      update();
      throw error;
    } catch (error) {
      _pageNumTransactions--;
      _canLoadTransactions = true;

      showErrorDialog('error'.tr);
      _loadMoreTransactions = false;
      update();
      throw error;
    }
    _loadMoreTransactions = false;
    update();
  }
}
