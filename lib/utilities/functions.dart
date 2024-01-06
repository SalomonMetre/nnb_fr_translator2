import 'package:flutter/material.dart';
import 'package:nnb_fr_translator2/utilities/globals.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

void pushFirstPage(BuildContext context) {
  final currentUser = Globals.currentUser;
  if (currentUser == null) {
    showScaffoldMessage(context, message: "No user currently logged in");
    Future.delayed(
      const Duration(seconds: 2),
    ).then(
      (value) =>
          Navigator.pushReplacementNamed(context, NamedRoutes.signUpPage),
    );
  } else {
    if (currentUser.emailVerified) {
      showScaffoldMessage(context,
          message: "Welcome!", color: ColorConstants.tealColor);
      pushPage(context, pageName: NamedRoutes.homePage);
    } else {
      showScaffoldMessage(context,
          message: "Please verify your email",
          color: ColorConstants.orangeColor);
      pushPage(context, pageName: NamedRoutes.loginPage);
    }
  }
}

void pushPage(BuildContext context,
    {required String pageName, bool replace = true}) {
  replace
      ? Navigator.pushReplacementNamed(context, pageName)
      : Navigator.pushNamed(context, pageName);
}

void showScaffoldMessage(
  BuildContext context, {
  required String message,
  Color color = ColorConstants.tealColor,
  bool showClose = false,
  Duration duration = const Duration(seconds: 1),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      action: showClose
          ? SnackBarAction(
              backgroundColor: ColorConstants.blackColor,
              textColor: ColorConstants.whiteColor,
              label: "Close",
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            )
          : null,
      backgroundColor: color,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: ColorConstants.whiteColor),
      ),
    ),
  );
}

void showDialogEditUserDetails(
  BuildContext context,
  double screenWidth,
  double screenHeight, {
  required TextEditingController controller,
  required VoidCallback onEdit,
  required String fieldToEdit,
}) {
  showDialog(
      context: context,
      builder: (context) => Center(
            child: Card(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.1),
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: "New $fieldToEdit",
                          hintText: "Enter new $fieldToEdit",
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              ColorConstants.tealColor),
                          foregroundColor: MaterialStateProperty.all(
                              ColorConstants.whiteColor2),
                        ),
                        onPressed: onEdit,
                        child: Text("Edit $fieldToEdit", textAlign: TextAlign.center,),
                      ),
                    ],
                  )),
            ),
          ));
}

void showPopUpMessage(
    BuildContext context, double screenWidth, double screenHeight,
    {required String message}) {
  showDialog(
      context: context,
      builder: (context) => Center(
            child: Card(
              color: ColorConstants.whiteColor,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.1),
                width: screenWidth * 0.8,
                height: screenHeight * 0.25,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      message,
                      style:
                          const TextStyle(color: ColorConstants.tealColor),
                    ),
                  ],
                ),
              ),
            ),
          ));
}
