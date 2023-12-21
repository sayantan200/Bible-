import 'package:flutter/material.dart';
import 'package:bible/Screen/verse_display.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterSelectionWidget extends StatelessWidget {
  final String book;
  final int chapters;
  final List<String> booksOfBibleEng;
  final List<int> x;
  final String selectedLanguage;

  ChapterSelectionWidget({
    required this.book,
    required this.chapters,
    required this.booksOfBibleEng,
    required this.selectedLanguage,
  }) : x = List<int>.generate(chapters, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 52, 2, 230),
        title: Text(selectedLanguage == 'English'
            ? 'Select a Chapter - $book'
            : 'Bir bölüm seçin - $book'),
        centerTitle: true,
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
      body: _buildChapterList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the next chapter
          int nextChapter = x.last < chapters ? x.last + 1 : 1;
          _loadChapterContent(
            context,
            book,
            nextChapter,
            booksOfBibleEng,
            selectedLanguage,
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildChapterList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: x.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Center(
              child: Text(
                selectedLanguage == 'English'
                    ? 'Chapter ${x[index]}'
                    : 'Bölüm ${x[index]}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              _loadChapterContent(
                context,
                book,
                x[index],
                booksOfBibleEng,
                selectedLanguage,
              );
            },
          );
        },
      ),
    );
  }

  void _loadChapterContent(
      BuildContext context,
      String book,
      int selectedChapter,
      List<String> booksOfBibleEng,
      String selectedLanguage) async {
    try {
      int maxChapters = chapters;

      if (selectedChapter < 1 || selectedChapter > maxChapters) {
        print('Invalid chapter selected: $selectedChapter');
        // Provide feedback to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid chapter selected: $selectedChapter'),
          ),
        );
        return;
      }

      String filePath =
          'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$book/$book$selectedChapter.txt';
      String chapterContent = await rootBundle.loadString(filePath);

      _navigateToVerseDisplay(
        context,
        book,
        selectedChapter,
        chapterContent,
        selectedLanguage,
      );
    } catch (e) {
      print('Error loading chapter content: $e');
      // Provide feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Error loading chapter content. Please try again.'),
        ),
      );
    }
  }

  void _navigateToVerseDisplay(
    BuildContext context,
    String book,
    int selectedChapter,
    String chapterContent,
    String selectedLanguage,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerseDisplayWidget(
          book: book,
          chapter: selectedChapter,
          content: chapterContent,
          maxChapters: x,
          selectedLanguage: selectedLanguage,
        ),
      ),
    );
  }
}
