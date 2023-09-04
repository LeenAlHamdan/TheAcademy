import 'package:get/get.dart';
import 'package:the_academy/data/api/api_client.dart';
import 'package:the_academy/model/http_exception.dart';
import 'package:the_academy/utils/app_contanants.dart';

import '../../model/transaction.dart';

class TransactionController extends GetxController {
  final ApiClient apiClient = Get.find();
  List<Transaction> _transactions = [];

  List<int> pages = [];
  int _total = 0;

  final int _limit = 10;

  int get total => _total;

  List<Transaction> get transactions {
    return _transactions;
  }

  Future<void> fetchAndSetTransactions(int pageNum, {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _transactions = [];
    }

    if (pages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = transactions.length;

    try {
      final response = await apiClient.getData(
          '${AppConstants.transactionGet}?${AppConstants.limit}=$_limit&${AppConstants.offset}=$offest');

      if (response.statusCode == 200) {
        if (response.body == null) {
          throw HttpException('error');
        }
        final extractedData = Map<String, dynamic>.from(response.body);

        _total = extractedData['total'] ?? _total;

        final data = extractedData['data'] as List<dynamic>;

        List<Transaction> loadedTransactions = [];

        for (var transaction in data) {
          if (transaction['_id'] != null &&
              transaction['type'] != null &&
              transaction['amount'] != null &&
              transaction['createdAt'] != null) {
            loadedTransactions.add(Transaction(
              id: transaction['_id'],
              type: transaction['type'],
              amount: double.parse(transaction['amount'].toString()),
              details: transaction['details'],
              createdAt: transaction['createdAt'],
            ));
          }
        }

        if (loadedTransactions.isNotEmpty) {
          _transactions.addAll(loadedTransactions);
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
}
