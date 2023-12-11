import 'package:flutter/material.dart';
import 'package:bible/Screen/verse_display.dart';
import 'package:flutter/services.dart';

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
        title: Text('Select a Chapter - $book'),
      ),
      body: ListView.builder(
        itemCount: x.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Chapter ${x[index]}'),
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
        return;
      }

      String filePath =
          'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$book/$book$selectedChapter.txt';
      String chapterContent = await rootBundle.loadString(filePath);

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
    } catch (e) {
      print('Error loading chapter content: $e');
    }
  }
}