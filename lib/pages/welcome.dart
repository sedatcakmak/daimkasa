import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/localization/language_provider.dart';
import 'package:daimkasa/pages/verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isButtonEnabled = false;
  String selectedLanguage = "Türkçe";

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language');
    setState(() {
      selectedLanguage =
          languages.firstWhere((lang) => lang["code"] == langCode)["name"] ??
              "Türkçe";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  final List<Map<String, String>> languages = [
    {"name": "Türkçe", "code": "tr"},
    {"name": "English", "code": "en"},
  ];

  void _verifyPhoneNumber() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    phone = "+9$phone";

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('employees')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      _showSnackBar('ACCOUNT_NOT_FOUND_TEXT');
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _showSnackBar(e.message!.contains("format")
            ? 'WRONG_PHONE_NUMBER_TEXT'
            : e.message!);
      },
      codeSent: (String verificationId, int? resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
                verificationId: verificationId, phone: phone),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _onPhoneNumberChanged(String value) {
    setState(() {
      isButtonEnabled = value.length == 11;
    });
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ...languages.map((lang) => _buildLanguageOption(lang)),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    Provider.of<LanguageProvider>(context, listen: false)
        .changeLanguage(langCode);

    setState(() {
      selectedLanguage =
          languages.firstWhere((lang) => lang["code"] == langCode)["name"]!;
    });

    _showSnackBar('SELECTED_LANGUAGE_TEXT');
  }

  Widget _buildLanguageOption(Map<String, String> lang) {
    bool isSelected = selectedLanguage == lang["name"];
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(lang["name"]!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : null,
      tileColor: isSelected ? Colors.blue.shade100 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: () {
        if (!isSelected) _changeLanguage(lang["code"]!);
        Navigator.pop(context);
      },
    );
  }

  void _showSnackBar(String messageKey) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context).translate(messageKey))),
    );
  }

  Widget _buildTitleText() {
    return Text(
      "Daim Kasa",
      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescriptionText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        AppLocalizations.of(context).translate("WELCOME_TEXT"),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: EdgeInsets.only(bottom: 40.h),
      child: Column(
        children: [
          _buildLinkText('TERMS_OF_USE_TEXT', _openTermsPage),
          SizedBox(height: 10.h),
          _buildLinkText('PRIVACY_POLICY_TEXT', _openPrivacyPolicyPage),
        ],
      ),
    );
  }

  Widget _buildLinkText(String key, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        AppLocalizations.of(context).translate(key),
        style: TextStyle(
            fontSize: 20.sp, color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openTermsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const TermsPage()));
  }

  void _openPrivacyPolicyPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(height: 25.h),
              _buildLanguageSelector(),
              SizedBox(height: 20.h),
              _buildLogo(),
              SizedBox(height: 20.h),
              _buildTitleText(),
              SizedBox(height: 20.h),
              _buildDescriptionText(),
              SizedBox(height: 40.h),
              _buildPhoneNumberInput(),
              SizedBox(height: 10.h),
              _buildContinueButton(),
              SizedBox(height: 40.h),
              _buildTermsAndPrivacy(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 20.h),
      child: GestureDetector(
        onTap: _showLanguageBottomSheet,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  AppLocalizations.of(context)
                      .translate('SELECTED_LANGUAGE_TEXT'),
                  style: TextStyle(fontSize: 16.sp)),
              Row(children: [
                Icon(Icons.language),
                SizedBox(width: 8.w),
                Text(selectedLanguage)
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.network(
      "https://d3jmn01ri1fzgl.cloudfront.net/photoadking/webp_thumbnail/cafe-logo-template-hmu0ar64051fa9.webp",
    );
  }

  Widget _buildPhoneNumberInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        maxLength: 11,
        maxLines: 1,
        onChanged: _onPhoneNumberChanged,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.black),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2.w),
          ),
          labelText:
              AppLocalizations.of(context).translate('WRITE_PHONE_NUMBER_TEXT'),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? _verifyPhoneNumber : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? Colors.green : Colors.grey,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
        child: Text(AppLocalizations.of(context).translate('CONTINUE_TEXT'),
            style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
              AppLocalizations.of(context).translate('TERMS_OF_USE_TITLE'),
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
          child: Text(AppLocalizations.of(context).translate('TERMS_OF_USE'))),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
              AppLocalizations.of(context).translate('PRIVACY_POLICY_TITLE'),
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Center(
          child:
              Text(AppLocalizations.of(context).translate('PRIVACY_POLICY'))),
    );
  }
}
