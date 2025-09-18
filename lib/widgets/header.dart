import 'package:daimkasa/pages/account_information.dart';
import 'package:daimkasa/pages/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueAccent,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.sp),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.language, color: Colors.white, size: 24.sp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Language()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.account_circle, color: Colors.white, size: 24.sp),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountInformation()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(50.h);
}
