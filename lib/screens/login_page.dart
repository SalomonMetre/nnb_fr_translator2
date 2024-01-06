// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nnb_fr_translator2/models/auth.dart';
import 'package:nnb_fr_translator2/utilities/functions.dart';
import 'package:nnb_fr_translator2/utilities/globals.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showVisibility = false;
  final emailController = TextEditingController(),
      passwordController = TextEditingController();

  void _switchVisibility() {
    setState(() {
      showVisibility = showVisibility ? false : true;
    });
  }

  void _loginUser() async {
    try {
      await Auth.instance.loginUser(
          email: emailController.text, password: passwordController.text);
      setState(() {
        Globals.currentUser = FirebaseAuth.instance.currentUser;
        Globals.currentEmail = Globals.currentUser?.email;
        Globals.isUserAdmin = Globals.currentEmail == TextConstants.adminEmail;
      });
      if (Globals.currentUser!.emailVerified) {
        showScaffoldMessage(context,
            message: "Successful login !", color: ColorConstants.tealColor);
        pushPage(context, pageName: NamedRoutes.homePage);
      } else {
        showScaffoldMessage(context,
            message: "Please verify your email first !",
            color: ColorConstants.orangeColor);
            pushPage(context, pageName: NamedRoutes.loginPage);
      }
    } on HttpException {
      showScaffoldMessage(context,
          message: "Check your Internet connection...");
    } on SocketException {
      showScaffoldMessage(context, message: "Check your Internet connection");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          showScaffoldMessage(context,
              message: "Invalid email !", color: ColorConstants.orangeColor);
          break;
        case 'wrong-password':
          showScaffoldMessage(context,
              message: "Password incorrect !",
              color: ColorConstants.orangeColor);
          break;
        case 'user-disabled':
          showScaffoldMessage(context,
              message: "This account may have been disabled !",
              color: ColorConstants.orangeColor);
          break;
        default:
          showScaffoldMessage(context,
              message: "User account not found !",
              color: ColorConstants.redColor);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * (ScreenUIConstants.isScreenLarge ? AuthUIConstants.kHorizontalPadding2 : AuthUIConstants.kHorizontalPadding1),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenWidth *
                      (ScreenUIConstants.isScreenLarge
                          ? MainUIConstants.kLgLogoWidth
                          : MainUIConstants.kSmLogoWidth),
                  height: screenHeight *
                      (ScreenUIConstants.isScreenLarge
                          ? MainUIConstants.kLgLogoHeight
                          : MainUIConstants.kSmLogoHeight),
                  child: ClipOval(
                    child: Image.asset(
                      TextConstants.logoPath,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  height: AuthUIConstants.horizontalPadding * 2,
                ),
                TextField(
                  cursorColor: ColorConstants.greyColor,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    iconColor: ColorConstants.tealColor,
                    icon: Icon(Icons.account_circle),
                    hintStyle: TextStyle(color: ColorConstants.greyColor),
                    labelText: "Email",
                    labelStyle: TextStyle(color: ColorConstants.tealColor),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorConstants.tealColor,
                      ),
                    ),
                  ),
                ),
                TextField(
                  cursorColor: ColorConstants.greyColor,
                  controller: passwordController,
                  obscureText: showVisibility ? false : true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    iconColor: ColorConstants.tealColor,
                    suffixIcon: IconButton(
                      icon: Icon(showVisibility
                          ? Icons.visibility
                          : Icons.visibility_off),
                      color: ColorConstants.tealColor,
                      onPressed: _switchVisibility,
                    ),
                    icon: const Icon(Icons.lock_clock_outlined),
                    hintStyle: const TextStyle(color: ColorConstants.greyColor),
                    labelText: "Password",
                    labelStyle:
                        const TextStyle(color: ColorConstants.tealColor),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorConstants.tealColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: AuthUIConstants.horizontalPadding * 2,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(ColorConstants.tealColor),
                    foregroundColor:
                        MaterialStateProperty.all(ColorConstants.whiteColor2),
                  ),
                  onPressed: _loginUser,
                  child: const Text("Log In"),
                ),
                const SizedBox(
                  height: AuthUIConstants.horizontalPadding * 0.5,
                ),
                InkWell(
                  overlayColor: MaterialStateProperty.all(ColorConstants.whiteColor),
                  child: RichText(
                    text: const TextSpan(
                        text: "Don't have an account ?",
                        style: TextStyle(color: ColorConstants.tealColor),
                        children: [
                          TextSpan(
                              text: " sign up",
                              style:
                                  TextStyle(color: ColorConstants.orangeColor))
                        ]),
                  ),
                  onTap: () {
                    pushPage(context, pageName: NamedRoutes.signUpPage);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
