import 'package:daimkasa/managers/app_loader.dart';
import 'package:daimkasa/pages/home_page.dart';
import 'package:daimkasa/pages/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUser();
    });
  }

  void checkUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? phone = user?.phoneNumber ?? "";

    if (user != null && phone != "") {
      await AppLoader.loadAllData(phone);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', phone);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
                "https://d3jmn01ri1fzgl.cloudfront.net/photoadking/webp_thumbnail/cafe-logo-template-hmu0ar64051fa9.webp"),
            SizedBox(height: 25.h),
            Text("Daim Kasa",
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 25.h),
            CircularProgressIndicator(color: Colors.black),
          ],
        ),
      ),
    );
  }
}
