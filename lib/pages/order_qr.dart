import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/managers/app_loader.dart';
import 'package:daimkasa/managers/order_model.dart';
import 'package:daimkasa/managers/user_model.dart';
import 'package:daimkasa/pages/order_information.dart';
import 'package:daimkasa/pages/user_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:daimkasa/widgets/header.dart';
import '../widgets/bottom.dart';

class OrderQR extends StatefulWidget {
  const OrderQR({super.key});

  @override
  State<OrderQR> createState() => _OrderQRState();
}

class _OrderQRState extends State<OrderQR> {
  String qrText = "";
  final TextEditingController _textController = TextEditingController();

  Future<void> _updateQRText(String value) async {
    setState(() {
      qrText = value;
    });

    if (qrText == "" || qrText == "undefined") {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('WRONG_QR_TEXT'))),
      );

      return;
    }

    UserModel? userModel = await AppLoader.getUserById(qrText);
    if (userModel != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => UserInformationPage(userModel: userModel)),
        (Route<dynamic> route) => false,
      );

      return;
    }

    OrderModel? orderModel = await AppLoader.getPendingOrderById(qrText);
    if (orderModel != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => OrderInformationPage(orderModel: orderModel)),
        (Route<dynamic> route) => false,
      );

      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('WRONG_QR_TEXT'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('SCAN_QR_TITLE')),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).translate('SCAN_QR_TEXT'),
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Center(
            child: Container(
              width: 350.w,
              height: 350.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54, width: 2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      _updateQRText(barcode.rawValue ?? "undefined");
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Divider(),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).translate('WRITE_QR_TEXT'),
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: _textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText:
                    AppLocalizations.of(context).translate('WRITE_CODE_TEXT'),
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _updateQRText(_textController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 100.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).translate('VERIFY_CODE_TEXT'),
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
