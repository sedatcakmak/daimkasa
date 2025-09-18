import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/managers/app_loader.dart';
import 'package:daimkasa/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OTPVerificationScreen(
      {super.key, required this.verificationId, required this.phone});

  @override
  State<StatefulWidget> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isButtonEnabled = false;
  int resendCooldown = 30;
  bool canResendSMS = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startResendCooldown();
  }

  void startResendCooldown() {
    setState(() {
      canResendSMS = false;
      resendCooldown = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (resendCooldown > 0) {
          resendCooldown--;
        } else {
          canResendSMS = true;
          timer.cancel();
        }
      });
    });
  }

  void verifyOTP() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text,
      );

      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate("USER_NOT_FOUND_TEXT"))));
        return;
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('phone', isEqualTo: widget.phone)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await AppLoader.loadAllData(widget.phone);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context).translate("LOGGED_TEXT"))));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate("USER_NOT_FOUND_TEXT"))));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().contains("invalid")
              ? AppLocalizations.of(context).translate("WRONG_CODE_TEXT")
              : e.toString())));
    }
  }

  void resendOTP() async {
    await auth.verifyPhoneNumber(
      phoneNumber: widget.phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${e.message}")));
      },
      codeSent: (String verificationId, int? resendToken) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate("CODE_SENT_TEXT")
                .replaceFirst("{phone}", widget.phone))));
        startResendCooldown();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _onOTPChanged(String value) {
    setState(() {
      isButtonEnabled =
          value.length == 6; // OTP kodu 6 karakter uzunluğunda olmalı
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
              AppLocalizations.of(context).translate("VERIFY_ACCOUNT_TITLE"),
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              "https://d3jmn01ri1fzgl.cloudfront.net/photoadking/webp_thumbnail/cafe-logo-template-hmu0ar64051fa9.webp",
            ),
            SizedBox(height: 20.h),
            Text("Daim Kasa",
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 50.h),
            Text(AppLocalizations.of(context).translate("ENTER_CODE_TEXT"),
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            Text(AppLocalizations.of(context)
                .translate("CODE_SENT_TEXT")
                .replaceFirst("{phone}", widget.phone)),
            SizedBox(height: 20.h),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: _onOTPChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText:
                    AppLocalizations.of(context).translate("VERIFY_CODE_TEXT"),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: isButtonEnabled ? verifyOTP : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? Colors.green : Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(
                    AppLocalizations.of(context).translate("VERIFY_CODE_TEXT"),
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: canResendSMS ? resendOTP : null,
              child: Text(
                canResendSMS
                    ? AppLocalizations.of(context)
                        .translate("SEND_CODE_AGAIN_TEXT")
                    : "${AppLocalizations.of(context).translate("SEND_CODE_AGAIN_TEXT")} ($resendCooldown)",
                style: TextStyle(
                    fontSize: 16.sp,
                    color: canResendSMS ? Colors.blue : Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                  AppLocalizations.of(context).translate("CHANGE_PHONE_TEXT"),
                  style: TextStyle(fontSize: 16.sp, color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
