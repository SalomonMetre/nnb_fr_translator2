import 'package:flutter/material.dart';
import 'package:nnb_fr_translator2/main.dart';
import 'package:nnb_fr_translator2/screens/home_page.dart';
import 'package:nnb_fr_translator2/screens/login_page.dart';
import 'package:nnb_fr_translator2/screens/signup_page.dart';
import 'package:nnb_fr_translator2/screens/translation_history_page.dart';
import 'package:nnb_fr_translator2/screens/users_page.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';

final routes = <String, WidgetBuilder>{
  '/': (context) => const MainPage(),
  NamedRoutes.signUpPage: (context) => const SignUpPage(),
  NamedRoutes.loginPage:(context) => const LoginPage(),
  NamedRoutes.homePage:(context) => const HomePage(),
  NamedRoutes.translationHistoryPage : (context) => const TranslationHistoryPage(),
  NamedRoutes.usersPage : (context) => const UsersPage(),
  };
