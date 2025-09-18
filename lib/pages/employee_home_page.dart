import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/managers/app_loader.dart';
import 'package:daimkasa/pages/order_details.dart';
import 'package:flutter/material.dart';
import 'package:daimkasa/managers/information.dart';
import 'package:daimkasa/managers/order_model.dart';
import 'package:daimkasa/widgets/header.dart';
import 'package:daimkasa/widgets/bottom.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentOrderIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('HOME_PAGE_TITLE')),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: Padding(
        padding: EdgeInsets.all(16.spMax),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmployeeInfo(),
              SizedBox(height: 16.h),
              _buildPerformanceInfo(context),
              SizedBox(height: 16.h),
              _buildOrdersCarousel(context),
              SizedBox(height: 16.h),
              _buildMenuGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          if (Information.restaurant?.image != "")
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                Information.restaurant?.image ?? "",
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(Icons.person, size: 30.sp, color: Colors.blueAccent),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${Information.name} ${Information.surname}",
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  Information.restaurant?.name ?? "?",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceInfo(context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _buildInfoRow(
              Icons.shopping_bag,
              AppLocalizations.of(context).translate('ORDER_COUNT_TEXT'),
              "${Information.orderCount}"),
          _buildInfoRow(
              Icons.shopping_basket,
              AppLocalizations.of(context).translate('PROCESS_COUNT_TEXT'),
              "${Information.priceCount.toStringAsFixed(2)} ₺"),
        ],
      ),
    );
  }

  Widget _buildOrdersCarousel(context) {
    if (Information.orders.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12.sp),
        decoration: _boxDecoration(),
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate('NO_VERIFIED_ORDER_TEXT'),
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('VERIFIED_ORDERS_TEXT'),
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 190.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: Information.orders.length,
            onPageChanged: (index) {
              setState(() {
                _currentOrderIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildOrderItem(Information.orders[index]);
            },
          ),
        ),
        SizedBox(height: 8.h),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildOrderItem(OrderModel order) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
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
                  : "Bilinmiyor"),
          SizedBox(height: 8.h),
          _buildInfoRow(
              Icons.access_time,
              AppLocalizations.of(context).translate('ORDER_DATE_TEXT'),
              DateFormat('HH.mm dd/MM/yyyy').format(order.date.toDate())),
          SizedBox(height: 8.h),
          _buildInfoRow(
              Icons.monetization_on,
              AppLocalizations.of(context).translate('TOTAL_PRICE_TEXT'),
              "${order.totalPrice.toStringAsFixed(2)} ₺"),
          SizedBox(height: 12.h),
          _buildOrderButtons(order),
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
            "$label $value",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderButtons(OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                AppLoader.endOrder(order);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(AppLocalizations.of(context)
                          .translate('ORDER_ENDED_TEXT'))),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(
                AppLocalizations.of(context).translate('END_ORDER_TEXT'),
                style: TextStyle(fontSize: 16.sp, color: Colors.white)),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(order: order)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(
                AppLocalizations.of(context).translate('ORDER_DETAILS_TEXT'),
                style: TextStyle(fontSize: 16.sp, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        Information.orders.length,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: _currentOrderIndex == index ? 12.w : 8.w,
          height: _currentOrderIndex == index ? 12.h : 8.h,
          decoration: BoxDecoration(
            color: _currentOrderIndex == index ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuGrid(context) {
    final menu = Information.restaurant?.menu ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('MENU_TEXT'),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: menu.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final item = menu[index];

            return Column(
              children: [
                ClipOval(
                  child: Image.network(
                    item.image,
                    width: 80.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.price > 0
                      ? "${item.price.toStringAsFixed(2)} ₺"
                      : "${item.stars} ⭐",
                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                ),
              ],
            );
          },
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
          color: Colors.grey.shade200,
          spreadRadius: 1.r,
          blurRadius: 3.r,
        ),
      ],
    );
  }
}
