import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainUIConstants {
  static const double kLgLogoWidth = 0.1;
  static const double kSmLogoWidth = 0.3;
  static const double kLgLogoHeight = 0.2;
  static const double kSmLogoHeight = 0.2;
}

class HomeUIConstants {
  static const double kLgLogoWidth = 0.1;
  static const double kSmLogoWidth = 0.25;
  static const double kLgLogoHeight = 0.2;
  static const double kSmLogoHeight = 0.15;
}

class ScreenUIConstants {
  static get isScreenLarge =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.linux;
}

class AuthUIConstants {
  static const double kHorizontalPadding1 = 0.1;
  static const double kHorizontalPadding2 = 0.3;
  static const double horizontalPadding = 20.0;
}

class ColorConstants {
  static const blueColor1 = Color.fromARGB(255, 0, 132, 255);
  static const whiteColor = Colors.white;
  static const whiteColor2 = Color.fromARGB(255, 255, 252, 252);
  static const tealColor = Color.fromARGB(255, 0, 120, 136);
  static const redColor = Color.fromARGB(255, 156, 24, 15);
  static const orangeColor = Colors.orange;
  static const greenColor = Color.fromARGB(255, 17, 161, 4);
  static const blackColor = Colors.black;
  static const greyColor = Color.fromARGB(255, 56, 56, 56);
}
