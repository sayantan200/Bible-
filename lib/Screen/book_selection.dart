import 'package:bible/Screen/chapter_selection.dart';
import 'package:flutter/material.dart';
import 'package:bible/models/bible_data.dart';
import 'package:bible/services/bible_data_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class BookSelectionWidget extends StatefulWidget {
  @override
  _BookSelectionWidgetState createState() => _BookSelectionWidgetState();
}

class _BookSelectionWidgetState extends State<BookSelectionWidget> {
  late String selectedLanguage;
  late BibleData bibleData;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedLanguage = 'English';
    _loadBibleData();
  }

  Future<void> _loadBibleData() async {
    try {
      bibleData = await BibleDataService().loadBibleData();
    } catch (e) {
      print('Error loading Bible data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading Bible data. Please try again.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Select a Book'),
        ),
        actions: [
          // Add the email icon button
          IconButton(
            icon: Icon(Icons.email),
            onPressed: () {
              // Open email with the specified address and subject
              launch(
                'mailto:josephdaniellepalmer@me.com?subject=İncil',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              items: ['English', 'Turkish'].map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(
                    language,
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value!;
                });
              },
            ),
          ),
          if (isLoading)
            CircularProgressIndicator(), // Show a loading indicator
          if (!isLoading && bibleData != null)
            Expanded(
              child: ListView.builder(
                itemCount: selectedLanguage == 'English'
                    ? bibleData.booksOfBibleEng.length
                    : bibleData.booksOfBibleTur.length,
                itemBuilder: (context, index) {
                  final books = selectedLanguage == 'English'
                      ? bibleData.booksOfBibleEng
                      : bibleData.booksOfBibleTur;

                  final selectedBook = books[index];

                  return ListTile(
                    title: Center(
                      child: Text(
                        selectedBook,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterSelectionWidget(
                            book: selectedBook,
                            chapters: bibleData.chaptersForAll[index],
                            booksOfBibleEng: books,
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
