import 'package:daimkasa/localization/language_provider.dart';
import 'package:daimkasa/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daimkasa/localization/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  LanguageProvider languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();

  await ScreenUtil.ensureScreenSize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => languageProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(412, 915),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: 'Daim Kasa',
              debugShowCheckedModeBanner: false,
              locale: languageProvider.locale,
              theme: ThemeData(
                fontFamily: 'Poppins',
                scaffoldBackgroundColor: Colors.white,
                primaryColor: Colors.blue,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black),
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.black,
                ),
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(color: Colors.black),
                  bodyMedium: TextStyle(color: Colors.black),
                  titleMedium: TextStyle(color: Colors.black),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  labelStyle: TextStyle(color: Colors.black),
                ),
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Colors.blue,
                  selectionColor: Colors.blueAccent.shade100,
                  selectionHandleColor: Colors.blue,
                ),
              ),
              supportedLocales: const [
                Locale('en'),
                Locale('tr'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
