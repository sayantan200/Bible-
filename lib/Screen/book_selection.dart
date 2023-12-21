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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 38, 83, 130),
        title: Row(
          children: [
            ElevatedButton(
              onPressed: () {
                _showLanguageSelectionMenu(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 38, 83, 130),
              ),
              child: Text(selectedLanguage == 'English' ? 'KJV' : 'İncil'),
            ),
            SizedBox(
                width: 65), // Add some spacing between the button and the title
            Text(
              selectedLanguage == 'English' ? 'Select a Book' : 'Bir Kitap Seç',
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // ... existing code ...
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

  void _showLanguageSelectionMenu(BuildContext context) async {
    String? result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(0, 100, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'English',
          child: Text(
            'English(King \nJames Version)',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Turkish',
          child: Text(
            'Türkçe(İncil)',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    if (result != null) {
      setState(() {
        selectedLanguage = result;
      });
    }
  }
}
