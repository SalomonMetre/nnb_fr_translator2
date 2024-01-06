// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nnb_fr_translator2/models/auth.dart';
import 'package:nnb_fr_translator2/models/db_model.dart';
import 'package:nnb_fr_translator2/utilities/functions.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool showVisibilityOne = false, showVisibilityTwo = false;
  final emailController = TextEditingController(),
      passwordController = TextEditingController(),
      confirmPasswordController = TextEditingController();

  void _switchVisibilityOne() {
    setState(() {
      showVisibilityOne = showVisibilityOne ? false : true;
    });
  }

  void _switchVisibilityTwo() {
    setState(() {
      showVisibilityTwo = showVisibilityTwo ? false : true;
    });
  }

  void _registerUser() async {
    if (passwordController.text == confirmPasswordController.text) {
      try {
        await Auth.instance.registerUser(
            email: emailController.text, password: passwordController.text);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        DbModel.instance.save(collectionName: "users", data: <String, dynamic>{
          "email": FirebaseAuth.instance.currentUser?.email,
          "name": "No Name",
          "phoneNumber": "No Phone Number",
          "ratingPermission": false,
        });
        showScaffoldMessage(context,
            message: "New user successfully registered");
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
          case 'weak-password':
            showScaffoldMessage(context,
                message: "Weak password !", color: ColorConstants.orangeColor);
            break;
          case 'email-already-in-use':
            showScaffoldMessage(context,
                message: "Email already in use !",
                color: ColorConstants.orangeColor);
            break;
          default:
            showScaffoldMessage(context,
                message: "Operation not allowed !",
                color: ColorConstants.redColor);
            break;
        }
      }
    } else {
      showScaffoldMessage(context,
          message: "Passwords do not match", color: ColorConstants.redColor);
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
                    labelText: "Email",
                    hintStyle: TextStyle(color: ColorConstants.greyColor),
                    labelStyle:
                        TextStyle(color: ColorConstants.tealColor),
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
                  obscureText: showVisibilityOne ? false : true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    iconColor: ColorConstants.tealColor,
                    suffixIcon: IconButton(
                      icon: Icon(showVisibilityOne
                          ? Icons.visibility
                          : Icons.visibility_off),
                      color: ColorConstants.tealColor,
                      onPressed: _switchVisibilityOne,
                    ),
                    icon: const Icon(Icons.lock_clock_outlined),
                    labelText: "Password",
                    hintStyle: const TextStyle(color: ColorConstants.greyColor),
                    labelStyle:
                        const TextStyle(color: ColorConstants.tealColor),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorConstants.tealColor,
                      ),
                    ),
                  ),
                ),
                TextField(
                  cursorColor: ColorConstants.greyColor,
                  controller: confirmPasswordController,
                  obscureText: showVisibilityTwo ? false : true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    iconColor: ColorConstants.tealColor,
                    suffixIcon: IconButton(
                      icon: Icon(showVisibilityTwo
                          ? Icons.visibility
                          : Icons.visibility_off),
                      color: ColorConstants.tealColor,
                      onPressed: _switchVisibilityTwo,
                    ),
                    icon: const Icon(Icons.lock),
                    labelText: "Confirm Password",
                    hintStyle: const TextStyle(color: ColorConstants.greyColor),
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
                        MaterialStateProperty.all(ColorConstants.whiteColor),
                  ),
                  onPressed: _registerUser,
                  child: const Text("Sign Up"),
                ),
                const SizedBox(
                  height: AuthUIConstants.horizontalPadding * 1.5,
                ),
                InkWell(
                  overlayColor: MaterialStateProperty.all(ColorConstants.whiteColor),
                  child: RichText(
                    text: const TextSpan(
                        text: "Have an account ?",
                        style: TextStyle(color: ColorConstants.tealColor),
                        children: [
                          TextSpan(
                              text: " log in",
                              style:
                                  TextStyle(color: ColorConstants.orangeColor))
                        ]),
                  ),
                  onTap: () {
                    pushPage(context, pageName: NamedRoutes.loginPage);
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
