import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/pages/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daimkasa/widgets/bottom.dart';
import 'package:daimkasa/widgets/header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: AppLocalizations.of(context)
              .translate('ACCOUNT_INFORMATION_TITLE')),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30.h),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 100.w, vertical: 0.h),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('phone');

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PhoneNumberScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text(
                  AppLocalizations.of(context).translate('LOGOUT_TEXT'),
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
