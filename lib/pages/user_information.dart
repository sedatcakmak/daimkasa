import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/managers/app_loader.dart';
import 'package:daimkasa/managers/user_model.dart';
import 'package:daimkasa/pages/home_page.dart';
import 'package:daimkasa/widgets/bottom.dart';
import 'package:daimkasa/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInformationPage extends StatefulWidget {
  final UserModel userModel;

  const UserInformationPage({
    super.key,
    required this.userModel,
  });

  @override
  State<StatefulWidget> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  final TextEditingController _usedBalanceController = TextEditingController();
  final TextEditingController _orderTotalController = TextEditingController();

  double _usedBalance = 0.0;
  double _orderTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _usedBalanceController.text = "";
    _orderTotalController.text = "";
  }

  void _updateUsedBalance(String value) {
    double enteredValue = double.tryParse(value) ?? 0.0;

    if (enteredValue < 0) {
      enteredValue = 0.0;

      setState(() {
        _usedBalanceController.text = enteredValue.toString();
      });
    } else if (enteredValue > widget.userModel.userBalance) {
      enteredValue = widget.userModel.userBalance;

      setState(() {
        _usedBalanceController.text = enteredValue.toString();
      });
    } else if (enteredValue > _orderTotal) {
      enteredValue = _orderTotal;

      setState(() {
        _usedBalanceController.text = enteredValue.toString();
      });
    }

    setState(() {
      _usedBalance = enteredValue;
    });
  }

  void _updateOrderTotal(String value) {
    double enteredValue = double.tryParse(value) ?? 0.0;

    if (enteredValue < 0) {
      enteredValue = 0.0;

      setState(() {
        _orderTotalController.text = enteredValue.toString();
      });
    }

    if (enteredValue < _usedBalance) {
      setState(() {
        _usedBalance = enteredValue;
        _usedBalanceController.text = enteredValue.toString();
      });
    }

    setState(() {
      _orderTotal = enteredValue;
    });
  }

  Future<void> _confirmOrder() async {
    if (_orderTotal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                .translate('ENTER_TOTAL_PRICE_TEXT'))),
      );
      return;
    }

    bool status = await AppLoader.createOrderWithoutItems(
        widget.userModel.id, _orderTotal, _usedBalance);
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
          content: Text(
              AppLocalizations.of(context).translate('ORDER_VERIFIED_TEXT'))),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  void _cancelOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context).translate('ORDER_REJECTED_TEXT'))),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('USER_DETAILS_TITLE')),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Column(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                _buildUserInfo(),
                SizedBox(height: 16.h),
                _buildBalanceInfo(),
                SizedBox(height: 16.h),
                _buildPriceInput(),
                SizedBox(height: 16.h),
                _buildOrderInput(),
                SizedBox(height: 16.h),
                _buildOrderInfo(),
              ],
            ),
          ),
          Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Row(
        children: [
          Icon(Icons.person, size: 50.sp, color: Colors.blueAccent),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('USER_TEXT'),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                "${widget.userModel.name} ${widget.userModel.surname}",
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              AppLocalizations.of(context).translate('USER_BALANCE_TEXT'),
              "${widget.userModel.userBalance.toStringAsFixed(2)} ₺"),
          _buildInfoRow(
              AppLocalizations.of(context).translate('BALANCE_TO_USE_TEXT'),
              "$_usedBalance ₺"),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              AppLocalizations.of(context).translate('TOTAL_PRICE_TEXT'),
              "${_orderTotal.toStringAsFixed(2)} ₺"),
          _buildInfoRow(
              AppLocalizations.of(context).translate('PRICE_TO_BE_PAID_TEXT'),
              "${_orderTotal - _usedBalance} ₺"),
        ],
      ),
    );
  }

  Widget _buildOrderInput() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('BALANCE_TO_BE_USED_TEXT'),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _usedBalanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context).translate('ENTER_AMOUNT_TEXT'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _updateUsedBalance,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInput() {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('TOTAL_PRICE_TEXT'),
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _orderTotalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context).translate('ENTER_AMOUNT_TEXT'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _updateOrderTotal,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _confirmOrder,
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
              onPressed: _cancelOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
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

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          spreadRadius: 1,
          blurRadius: 3,
        ),
      ],
    );
  }
}
