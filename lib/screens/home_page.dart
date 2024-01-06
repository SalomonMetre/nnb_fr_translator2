// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nnb_fr_translator2/models/api_model.dart';
import 'package:nnb_fr_translator2/models/auth.dart';
import 'package:nnb_fr_translator2/models/db_model.dart';
import 'package:nnb_fr_translator2/utilities/functions.dart';
import 'package:nnb_fr_translator2/utilities/globals.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

extension on String {
  String get postProcessed => replaceAll("\u00C3\u00A9", "é") // Ã©
      .replaceAll("\u00C3\u00BB", "û") // Ã»
      .replaceAll("\u00C3\u00A2", "â") // Ã¢
      .replaceAll("\u00C3\u00A7", "ç") // Ã§
      .replaceAll("\u00C3\u00A8", "è") // Ã¨
      .replaceAll("\u00C3\u00A0", "à") // Ã
      .replaceAll("\u00C3\u00AA", "ê") // Ãª
      .replaceAll("\u00C3\u00B9", "ù") // Ã¹
      .replaceAll("\u00C3\u00B4", "ô") // Ã´
      .replaceAll("\u00C3\u00AE", "î"); // Ã®
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController(),
      phoneNumberController = TextEditingController(),
      ratingPermissionController = TextEditingController();
  String? name, phoneNumber;
  bool? ratingPermission;
  final TextEditingController sourceTextController = TextEditingController();
  String sourceText = "",
      translatedText = 'Your translated text will appear here...';
  bool isBeingTranslated = false;
  dynamic userData, userDocumentReference;
  double avgModelRating = 0;

  @override
  void initState() {
    super.initState();
    userDocumentReference = DbModel.instance
        .getData(collectionName: "users", id: Globals.currentEmail!);
    var userDataSnapshot = userDocumentReference.get().asStream().first;
    userDataSnapshot.then((value) {
      userData = value.data() as Map<String, dynamic>;
      setState(() {
        name = userData["name"];
        phoneNumber = userData["phoneNumber"];
        ratingPermission = userData["ratingPermission"];
      });
    });
    DbModel.instance.getAverage("ratings", "rating").then((value) {
      setState(() {
        avgModelRating = double.parse(value.toStringAsFixed(2)).toDouble();
      });
    });
  }

  void _logOut() async {
    await Auth.instance.signOut();
    pushPage(context, pageName: NamedRoutes.signUpPage);
    showScaffoldMessage(context,
        message: "Signing out...",
        color: ColorConstants.redColor,
        showClose: false);
  }

  void _translate() async {
    if (sourceTextController.text.isEmpty ||
        RegExp(r'^\s*$').hasMatch(sourceTextController.text)) {
      showScaffoldMessage(context,
          message: "You have not entered any text",
          color: ColorConstants.redColor);
    } else {
      setState(() {
        sourceText = sourceTextController.text;
        isBeingTranslated = true;
        translatedText = "Your text is being translated...";
      });
      final value = await ApiModel.instance
          .translate(sourceText: sourceTextController.text);
      isBeingTranslated = false;
      if (value != null) {
        setState(() {
          print(value);
          translatedText = value.postProcessed;
          print(translatedText);
        });
      } else {
        setState(() {
          translatedText = "Your translated text will appear here...";
        });
        showScaffoldMessage(context,
            message:
                "The model is experiencing high traffic and is temporarily unavailable. Please try again later!",
            color: ColorConstants.redColor,
            duration: const Duration(seconds: 2));
      }
    }
  }

  void _saveTranslation() {
    if (sourceTextController.text.isEmpty ||
        RegExp(r'^\s*$').hasMatch(sourceTextController.text)) {
      showScaffoldMessage(context,
          message: "You have not typed any text yet",
          color: ColorConstants.redColor);
    } else if (translatedText == "Your translated text will appear here...") {
      showScaffoldMessage(context,
          message: "You have not yet translated your text",
          color: ColorConstants.redColor);
    } else {
      DbModel.instance
          .save(collectionName: "translations", data: <String, dynamic>{
        "email": Globals.currentEmail,
        "sourceText": sourceText,
        "translatedText": translatedText,
        "isRated": false,
      });
      showScaffoldMessage(context,
          message: "Translation successfully saved !",
          color: ColorConstants.tealColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
        backgroundColor: ColorConstants.whiteColor2,
        foregroundColor: ColorConstants.greyColor,
        centerTitle: true,
        actions: [
          if (ScreenUIConstants.isScreenLarge &&
              FirebaseAuth.instance.currentUser?.email ==
                  TextConstants.adminEmail)
            IconButton(
              onPressed: () {
                pushPage(context,
                    pageName: NamedRoutes.usersPage, replace: false);
              },
              icon: const Icon(Icons.supervisor_account_sharp),
              color: ColorConstants.tealColor,
            ),
          if (ScreenUIConstants.isScreenLarge)
            IconButton(
              onPressed: () {
                pushPage(context,
                    pageName: NamedRoutes.translationHistoryPage,
                    replace: false);
              },
              icon: const Icon(Icons.history),
              color: ColorConstants.tealColor,
            ),
          IconButton(
            onPressed: _logOut,
            icon: const Icon(Icons.logout),
            color: ColorConstants.redColor,
          ),
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          width: screenWidth * (ScreenUIConstants.isScreenLarge ? 0.25 : 0.7),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: screenWidth *
                          (ScreenUIConstants.isScreenLarge
                              ? HomeUIConstants.kLgLogoWidth
                              : HomeUIConstants.kSmLogoWidth),
                      height: screenHeight *
                          (ScreenUIConstants.isScreenLarge
                              ? HomeUIConstants.kLgLogoHeight
                              : HomeUIConstants.kSmLogoHeight),
                      child: ClipOval(
                        child: Image.asset(
                          TextConstants.logoPath,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Average Model Rating: ",
                        style: const TextStyle(color: ColorConstants.greyColor),
                        children: [
                          TextSpan(
                            text: "$avgModelRating",
                            style: const TextStyle(
                                color: ColorConstants.redColor, fontSize: 20),
                          ),
                          const TextSpan(text: "/"),
                          const TextSpan(
                            text: "5",
                            style: TextStyle(
                                color: ColorConstants.tealColor, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Handle Drawer Item 1 tap
                    },
                  ),
                  const Divider(),
                  ListTile(
                    iconColor: ColorConstants.greyColor,
                    title: const Text(
                      'Name',
                      style: TextStyle(
                          color: ColorConstants.greyColor,
                          fontWeight: FontWeight.normal),
                    ),
                    leading: const Icon(
                      Icons.account_circle,
                    ),
                    subtitle: Text(
                      '$name',
                      style: const TextStyle(color: ColorConstants.tealColor),
                    ),
                    onTap: () {
                      showDialogEditUserDetails(
                          context, screenWidth, screenHeight,
                          controller: nameController, onEdit: () {
                        var newName = nameController.text;
                        setState(() {
                          name = newName;
                        });
                        userDocumentReference
                            .update(<String, dynamic>{"name": newName});
                        showPopUpMessage(context, screenWidth, screenHeight,
                            message: "Name successfully edited !");
                      }, fieldToEdit: "name");
                    },
                  ),
                  ListTile(
                    iconColor: ColorConstants.greyColor,
                    title: const Text(
                      'Phone Number',
                      style: TextStyle(
                          color: ColorConstants.greyColor,
                          fontWeight: FontWeight.normal),
                    ),
                    leading: const Icon(
                      Icons.phone,
                    ),
                    subtitle: Text(
                      '$phoneNumber',
                      style: const TextStyle(color: ColorConstants.tealColor),
                    ),
                    onTap: () {
                      showDialogEditUserDetails(
                          context, screenWidth, screenHeight,
                          controller: phoneNumberController, onEdit: () {
                        var newPhoneNumber = phoneNumberController.text;
                        setState(() {
                          phoneNumber = newPhoneNumber;
                        });
                        userDocumentReference.update(
                            <String, dynamic>{"phoneNumber": newPhoneNumber});
                        showPopUpMessage(context, screenWidth, screenHeight,
                            message: "Phone number successfully edited !");
                      }, fieldToEdit: "phone number");
                    },
                  ),
                  ListTile(
                    iconColor: ColorConstants.greyColor,
                    title: const Text(
                      'Rating Permission',
                      style: TextStyle(
                          color: ColorConstants.greyColor,
                          fontWeight: FontWeight.normal),
                    ),
                    leading: Icon(
                      ratingPermission ?? false
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    subtitle: Text(
                      ratingPermission ?? false ? 'Enabled' : 'Disabled',
                      style: const TextStyle(color: ColorConstants.tealColor),
                    ),
                    onTap: FirebaseAuth.instance.currentUser?.email ==
                            TextConstants.adminEmail
                        ? () {
                            showDialogEditUserDetails(
                                context, screenWidth, screenHeight,
                                controller: ratingPermissionController,
                                onEdit: () {
                              var newRatingPermission =
                                  ratingPermissionController.text;
                              setState(() {
                                ratingPermission =
                                    newRatingPermission == '1' ? true : false;
                              });
                              userDocumentReference.update(<String, dynamic>{
                                "ratingPermission": newRatingPermission
                              });
                              showPopUpMessage(
                                  context, screenWidth, screenHeight,
                                  message:
                                      "Rating permission successfully edited !");
                            }, fieldToEdit: "rating permission");
                          }
                        : null,
                  ),
                  const Divider(),
                  if (FirebaseAuth.instance.currentUser?.email ==
                      TextConstants.adminEmail)
                    ListTile(
                      iconColor: ColorConstants.greyColor,
                      title: const Text(
                        'View Users',
                        style: TextStyle(
                            color: ColorConstants.greyColor,
                            fontWeight: FontWeight.normal),
                      ),
                      leading: const Icon(
                        Icons.supervisor_account_sharp,
                      ),
                      // subtitle: Text('View users & edit their rating permissions', style: TextStyle(color: ColorConstants.greyColor),),
                      onTap: () {
                        pushPage(context,
                            pageName: NamedRoutes.usersPage, replace: false);
                      },
                    ),
                  ListTile(
                    iconColor: ColorConstants.greyColor,
                    title: const Text(
                      'Translation History',
                      style: TextStyle(
                          color: ColorConstants.greyColor,
                          fontWeight: FontWeight.normal),
                    ),
                    leading: const Icon(
                      Icons.history,
                    ),
                    // subtitle: Text('View a history of all your translations', style: TextStyle(color: ColorConstants.greyColor),),
                    onTap: () {
                      pushPage(context,
                          pageName: NamedRoutes.translationHistoryPage,
                          replace: false);
                    },
                  ),
                  // const Divider(),
                  ListTile(
                    tileColor: ColorConstants.redColor,
                    iconColor: ColorConstants.whiteColor,
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                          color: ColorConstants.whiteColor,
                          fontWeight: FontWeight.normal),
                    ),
                    leading: const Icon(
                      Icons.logout,
                    ),
                    onTap: _logOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 8.0),
            Expanded(
              child: TextField(
                controller: sourceTextController,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: "Enter text to translate",
                  hintStyle: TextStyle(
                    color: ColorConstants.greyColor,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                enabled: false,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: translatedText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isBeingTranslated
                        ? ColorConstants.redColor
                        : ColorConstants.tealColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          ColorConstants.whiteColor2,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          ColorConstants.greyColor,
                        ),
                      ),
                      onPressed: () async {
                        _translate();
                      },
                      child: const Text('Translate'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          ColorConstants.whiteColor2,
                        ),
                        foregroundColor: MaterialStateProperty.all(
                          ColorConstants.greyColor,
                        ),
                      ),
                      onPressed: _saveTranslation,
                      child: const Text('Save'),
                    ),
                  ),
                ),
              ],
            ),
            if (ScreenUIConstants.isScreenLarge)
              const SizedBox(height: 40.0)
            else
              const SizedBox(height: 8.0),
          ],
        ),
      ),
      bottomNavigationBar: ScreenUIConstants.isScreenLarge
          ? null
          : FirebaseAuth.instance.currentUser?.email == TextConstants.adminEmail
              ? BottomNavigationBar(
                  selectedItemColor: ColorConstants.tealColor,
                  backgroundColor: ColorConstants.whiteColor2,
                  unselectedItemColor: ColorConstants.greyColor,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.supervisor_account_sharp),
                      label: 'Users',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history),
                      label: 'History',
                    ),
                  ],
                  onTap: (itemRank) {
                    switch (itemRank) {
                      case 0:
                        pushPage(context, pageName: NamedRoutes.homePage);
                        break;
                      case 1:
                        pushPage(context,
                            pageName: NamedRoutes.usersPage, replace: false);
                        break;
                      case 2:
                        pushPage(context,
                            pageName: NamedRoutes.translationHistoryPage,
                            replace: false);
                        break;
                    }
                  },
                )
              : BottomNavigationBar(
                  selectedItemColor: ColorConstants.tealColor,
                  backgroundColor: ColorConstants.whiteColor2,
                  unselectedItemColor: ColorConstants.greyColor,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history),
                      label: 'History',
                    ),
                  ],
                  onTap: (itemRank) {
                    switch (itemRank) {
                      case 0:
                        pushPage(context, pageName: NamedRoutes.homePage);
                        break;
                      case 1:
                        pushPage(context,
                            pageName: NamedRoutes.translationHistoryPage,
                            replace: false);
                        break;
                    }
                  },
                ),
    );
  }
}
