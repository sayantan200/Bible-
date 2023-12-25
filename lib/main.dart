import 'package:flutter/material.dart';
import 'package:bible/Screen/book_selection.dart';
import 'package:bible/Screen/verse_display.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
              book:
                  'Matta', // You can use the actual value or retrieve it from your data
              chapter: 1,
              content: snapshot.data
                  .toString(), // Pass the loaded chapter content here
              maxChapters: [], // Provide max chapters if needed
              selectedLanguage: 'Turkish',
            );
          } else {
            return CircularProgressIndicator(); // Show a loading indicator while the content is loading
          }
        },
      ),
    );
  }
}

