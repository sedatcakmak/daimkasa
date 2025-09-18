import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/pages/order_qr.dart';
import 'package:daimkasa/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  Future<void> _navigateToScreen(BuildContext context, int index) async {
    Widget destination;

    switch (index) {
      case 0:
        destination = HomePage();
        break;
      case 1:
        destination = OrderQR();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 3.r,
            blurRadius: 8.r,
          )
        ],
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildNavItem(context, Icons.home,
                AppLocalizations.of(context).translate('HOME_PAGE_BOTTOM'), 0),
          ),
          Expanded(
            child: _buildNavItem(context, Icons.qr_code,
                AppLocalizations.of(context).translate('SCAN_QR_BOTTOM'), 1),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (!isSelected) _navigateToScreen(context, index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
            size: 24.sp,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
