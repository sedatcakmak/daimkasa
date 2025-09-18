import 'package:daimkasa/localization/app_localizations.dart';
import 'package:daimkasa/localization/language_provider.dart';
import 'package:daimkasa/widgets/header.dart';
import 'package:daimkasa/widgets/bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<StatefulWidget> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  String selectedLanguage = "Türkçe";

  final List<Map<String, String>> languages = [
    {"name": "Türkçe", "native": "Türkçe", "code": "tr"},
    {"name": "English", "native": "İngilizce", "code": "en"},
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('language');
    setState(() {
      selectedLanguage =
          languages.firstWhere((lang) => lang["code"] == langCode)["name"] ??
              "Türkçe";
    });
  }

  Future<void> _changeLanguage(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);

    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.changeLanguage(langCode);

    setState(() {
      selectedLanguage =
          languages.firstWhere((lang) => lang["code"] == langCode)["name"]!;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "${AppLocalizations.of(context).translate('SELECTED_LANGUAGE_TEXT')}: $selectedLanguage")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(412, 915), minTextAdapt: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: AppLocalizations.of(context).translate('LANGUAGE_TITLE')),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final isSelected = language["name"] == selectedLanguage;

                  return GestureDetector(
                    onTap: () => {
                      if (!isSelected) {_changeLanguage(language["code"]!)}
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      padding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.language),
                              SizedBox(width: 12.w),
                              Text(language["name"]!,
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(language["native"]!,
                              style: TextStyle(
                                  fontSize: 16.sp, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
