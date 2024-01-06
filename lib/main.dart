import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nnb_fr_translator2/firebase_options.dart';
import 'package:nnb_fr_translator2/utilities/functions.dart';
import 'package:nnb_fr_translator2/utilities/routes.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(),
    initialRoute: '/',
    routes: routes,
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: FlutterSplashScreen.fadeIn(
        backgroundColor: ColorConstants.whiteColor2,
        childWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Spacer(),
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
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
              ),
              const Spacer(),
              const Spacer(),
              RichText(
                  text: const TextSpan(
                text: "...Translating",
                style: TextStyle(color: ColorConstants.blueColor1),
                children: [
                  TextSpan(text: " low-resourced ", style: TextStyle(color: ColorConstants.tealColor),),
                  TextSpan(text: "languages...", style: TextStyle(color: ColorConstants.blueColor1),),
                ],
              ),),
              const Spacer(),
            ],
          ),
        ),
        onEnd: () {
          pushFirstPage(context);
        },
      ),
    );
  }
}
