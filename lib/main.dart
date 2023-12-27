import 'dart:async';
import 'package:bible/utils/shared_pref_constraints.dart';
import 'package:flutter/material.dart';
import 'package:bible/Screen/verse_display.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Timer(Duration(milliseconds: 1), () async {
      AppConstraints.chapterNameVal =
          await sharedPref.getChapterName() ?? "Matta";
      AppConstraints.chapterNumberVal =
          await sharedPref.getChapterNumber() ?? 1;
      AppConstraints.languageVal = await sharedPref.getLanguage() ?? "Turkish";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: DefaultAssetBundle.of(context)
            .loadString('assets/Tur/Matta/Matta1.txt'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return VerseDisplayWidget(
              book: AppConstraints
                  .chapterNameVal, // You can use the actual value or retrieve it from your data
              chapter: AppConstraints.chapterNumberVal,
              content: snapshot.data
                  .toString(), // Pass the loaded chapter content here
              maxChapters: [], // Provide max chapters if needed
              selectedLanguage: AppConstraints.languageVal,
            );
          } else {
            return CircularProgressIndicator(); // Show a loading indicator while the content is loading
          }
        },
      ),
    );
  }
}
