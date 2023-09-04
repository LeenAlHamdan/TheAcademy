// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/screens_controllers/transactions_screen_controller.dart';
import '../../model/themes.dart';
import '../../utils/get_double_number.dart';
import '../widgets/custom_widgets/load_more_widget.dart';
import '../widgets/custom_widgets/loading_widget.dart';
import 'package:intl/intl.dart' as intl;

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBar = const StatisticsAppBar();
    return Scaffold(
      appBar: appBar,
      body: GetBuilder<TransactionsScreenController>(
        init: TransactionsScreenController(),
        builder: (controller) => SafeArea(
          child: controller.isLoading
              ? const LoadingWidget(
                  isDefault: true,
                )
              : RefreshIndicator(
                  onRefresh: () => controller.getData(refresh: true),
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: Get.height * 0.017,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            elevation: 0,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Get.isDarkMode
                                    ? Get.theme.backgroundColor
                                    : Themes.gradientMerged.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: Get.height * 0.026,
                                horizontal: Get.width * 0.061,
                              ),
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'your_current_balance'.tr,
                                          textAlign: TextAlign.start,
                                          style: Get.textTheme.headlineSmall
                                              ?.copyWith(
                                                  color: Get.isDarkMode
                                                      ? Themes.textColorDark
                                                      : Themes.textColor,
                                                  fontWeight:
                                                      FontWeight.normal),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: Get.height * 0.005,
                                          ),
                                          child: Text(
                                            '${getDoubleNumber(controller.userController.currentUser.balance)} ${'s.p'.tr}',
                                            textAlign: TextAlign.start,
                                            style: Get.textTheme.titleLarge
                                                ?.copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes
                                                            .primaryColorLight
                                                        : Themes.primaryColor,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller
                              .transactionController.transactions.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final item = controller
                                .transactionController.transactions[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.all(8),
                              color: Get.isDarkMode
                                  ? Get.theme.backgroundColor
                                  : Themes.gradientMerged.withOpacity(0.5),
                              child: ExpansionTile(
                                title: Text(
                                  item.type.tr,
                                  style: Get.textTheme.titleLarge?.copyWith(
                                      color: Get.isDarkMode
                                          ? Themes.primaryColorLight
                                          : null,
                                      fontWeight: FontWeight.bold),
                                ),
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'amount'.tr,
                                            style: Get.textTheme.titleMedium!
                                                .copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes
                                                            .primaryColorLightDark
                                                        : null
                                                    //fontWeight: FontWeight.normal,
                                                    ),
                                          ),
                                          trailing: Text(
                                            '${getDoubleNumber(item.amount)} ${'s.p'.tr}',
                                            style: Get.textTheme.titleMedium!
                                                .copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes.gradientMerged
                                                        : Themes.primaryColor),
                                          ),
                                          onTap: () {},
                                        ),
                                        ListTile(
                                          title: Text('details'.tr,
                                              style: Get.textTheme.titleMedium!
                                                  .copyWith(
                                                color: Get.isDarkMode
                                                    ? Themes
                                                        .primaryColorLightDark
                                                    : null,
                                              )),
                                          trailing: Text(
                                            item.details,
                                            style: Get.textTheme.titleMedium!
                                                .copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes.gradientMerged
                                                        : Themes.primaryColor),
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'created_at'.tr,
                                            style: Get.textTheme.titleMedium!
                                                .copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes
                                                            .primaryColorLightDark
                                                        : null),
                                          ),
                                          trailing: Text(
                                            (intl.DateFormat('dd/MM/yyyy'))
                                                .format(DateTime.parse(
                                                    item.createdAt)),
                                            textDirection: TextDirection.ltr,
                                            style: Get.textTheme.titleMedium!
                                                .copyWith(
                                                    color: Get.isDarkMode
                                                        ? Themes.gradientMerged
                                                        : Themes.primaryColor),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        controller.loadMoreTransactions
                            ? const LoadMoreWidget(
                                isDefault: true,
                              )
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class StatisticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StatisticsAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'transactions'.tr,
            style: TextStyle(
                color:
                    Get.isDarkMode ? Themes.textColorDark : Themes.textColor),
          )),
      leading: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: Icon(
          Icons.arrow_back_ios_outlined,
          color: Get.isDarkMode ? Themes.textColorDark : Themes.textColor,
        ),
      ),
      backgroundColor:
          Get.isDarkMode ? Get.theme.backgroundColor : Themes.primaryColorLight,
      elevation: 2,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}
