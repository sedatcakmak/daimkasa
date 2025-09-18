import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/widgets/bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:daimkasa/managers/order_model.dart';
import 'package:daimkasa/managers/information.dart';
import 'package:daimkasa/widgets/header.dart';

class OrderDetailsPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('ORDER_DETAILS_TITLE')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfo(context),
            SizedBox(height: 16),
            _buildOrderItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo(context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              Icons.person,
              AppLocalizations.of(context).translate('ORDER_OWNER_TEXT'),
              order.userModel != null
                  ? "${order.userModel?.name} ${order.userModel?.surname}"
                  : "?"),
          SizedBox(height: 8.h),
          _buildInfoRow(
              Icons.access_time,
              AppLocalizations.of(context).translate('ORDER_DATE_TEXT'),
              DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now())),
          SizedBox(height: 8.h),
          _buildInfoRow(
              Icons.monetization_on,
              AppLocalizations.of(context).translate('TOTAL_PRICE_TEXT'),
              "${order.totalPrice.toStringAsFixed(2)} ₺"),
        ],
      ),
    );
  }

  /// **📌 Order Items List (With Scrollbar)**
  Widget _buildOrderItems(context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: _boxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).translate('ORDER_ITEMS_TEXT'),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true, // Ensures scrollbar is visible
                thickness: 6, // Adjusts scrollbar width
                radius: Radius.circular(8.r), // Smooth rounded scrollbar
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    final menuItem = Information.restaurant!.menu
                        .firstWhere((menu) => menu.id == item.id);

                    return _buildOrderItem(menuItem.image, menuItem.name,
                        item.amount, item.unitPrice);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **📌 Single Order Item Row (With Image)**
  Widget _buildOrderItem(
      String imageUrl, String name, int amount, double price) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(8.sp),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
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
                  "$amount x $name",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${(price * amount).toStringAsFixed(2)} ₺",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24.sp),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            "$label: $value",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  BoxDecoration _boxDecoration() {
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
}
