import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/managers/information.dart';
import 'package:daimkasa/managers/menu_item_model.dart';
import 'package:daimkasa/managers/order_item_model.dart';
import 'package:daimkasa/managers/order_model.dart';
import 'package:daimkasa/managers/app_loader.dart';
import 'package:daimkasa/pages/home_page.dart';
import 'package:daimkasa/widgets/bottom.dart';
import 'package:daimkasa/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderInformationPage extends StatefulWidget {
  final OrderModel orderModel;

  const OrderInformationPage({
    super.key,
    required this.orderModel,
  });

  @override
  State<StatefulWidget> createState() => _OrderInformationPageState();
}

class _OrderInformationPageState extends State<OrderInformationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: AppLocalizations.of(context)
              .translate('ORDER_INFORMATION_TITLE')),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(),
                  SizedBox(height: 16.h),
                  _buildRestaurantInfo(),
                  SizedBox(height: 16.h),
                  _buildSummaryInfo(),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context).translate('ORDER_ITEMS_TEXT'),
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  _buildOrderList(),
                ],
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return Container(
      height: 285.h,
      decoration: _containerDecoration(),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: widget.orderModel.items.length,
          itemBuilder: (context, index) {
            final item = widget.orderModel.items[index];
            final menuItem = Information.restaurant!.menu
                .firstWhere((menu) => menu.id == item.id);
            return _buildOrderItem(menuItem, item);
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                bool status = await AppLoader.createOrder(widget.orderModel);
                if (!status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)
                            .translate('VERIFY_ORDER_ERROR_TEXT'))),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .translate('ORDER_VERIFIED_TEXT'))),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('CONFIRM_ORDER_TEXT'),
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                bool status = await AppLoader.deleteOrder(widget.orderModel);
                if (!status) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(AppLocalizations.of(context)
                            .translate('REJECT_ORDER_ERROR_TEXT'))),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .translate('ORDER_REJECTED_TEXT'))),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).translate('REJECT_ORDER_TEXT'),
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **🆕 Kullanıcı Bilgisi Kartı**
  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Row(
        children: [
          Icon(Icons.person, size: 50.sp, color: Colors.blueAccent),
          SizedBox(width: 10.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('ORDER_OWNER_TEXT'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              widget.orderModel.userModel == null
                  ? Text(AppLocalizations.of(context).translate('LOADING_TEXT'),
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey))
                  : Text(
                      "${widget.orderModel.userModel!.name} ${widget.orderModel.userModel!.surname}",
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryInfo() {
    if (widget.orderModel.userModel == null || Information.restaurant == null) {
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: _containerDecoration(),
        child: Center(
            child: Text(AppLocalizations.of(context).translate('LOADING_TEXT'),
                style: TextStyle(fontSize: 16))),
      );
    }

    double userBalance = widget.orderModel.userModel?.userBalance ?? 0;
    double finalUsedBalance = userBalance < widget.orderModel.usedBalance
        ? userBalance
        : widget.orderModel.usedBalance;
    double remainingAmount = widget.orderModel.totalPrice - finalUsedBalance;

    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              AppLocalizations.of(context).translate('TOTAL_PRICE_TEXT'),
              "${widget.orderModel.totalPrice.toStringAsFixed(2)} ₺"),
          _buildInfoRow(
              AppLocalizations.of(context).translate('USED_BALANCE_TEXT'),
              "$finalUsedBalance ₺"),
          _buildInfoRow(
              AppLocalizations.of(context).translate('PRICE_TO_BE_PAID_TEXT'),
              "${remainingAmount.toStringAsFixed(2)} ₺"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16.sp, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(MenuItemModel menuItem, OrderItemModel item) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(8.sp),
      decoration: _containerDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              menuItem.image,
              width: 60.w,
              height: 60.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.amount}x ${menuItem.name}",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  menuItem.price > 0
                      ? "${(item.unitPrice * item.amount).toStringAsFixed(2)} ₺"
                      : "${item.unitPrice * item.amount} ⭐",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey,
          spreadRadius: 1.r,
          blurRadius: 3.r,
        ),
      ],
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              Information.restaurant!.image,
              width: 60.w,
              height: 60.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('RESTAURANT_TEXT'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Information.restaurant == null
                  ? Text(AppLocalizations.of(context).translate('LOADING_TEXT'),
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey))
                  : Text(
                      Information.restaurant!.name,
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
            ],
          )),
        ],
      ),
    );
  }
}
