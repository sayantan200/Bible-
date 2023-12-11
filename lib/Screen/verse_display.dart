import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerseDisplayWidget extends StatelessWidget {
  final String book;
  final int chapter;
  final String content;
  final List<int> maxChapters;
  final String selectedLanguage;

  VerseDisplayWidget({
    required this.book,
    required this.chapter,
    required this.content,
    required this.maxChapters,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verses - $book Chapter $chapter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  style: TextStyle(fontSize: 23.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToChapter(context, book, chapter - 1, selectedLanguage),
                  child: Text('Previous Chapter'),
                ),
                ElevatedButton(
                  onPressed: () => _navigateToNextChapter(context, book, chapter, maxChapters, selectedLanguage),
                  child: Text('Next Chapter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNextChapter(BuildContext context, String book, int currentChapter, List<int> maxChapters, String selectedLanguage) async {
    final bookIndex = maxChapters.indexOf(maxChapters.firstWhere((element) => element >= currentChapter));

    int nextBookIndex = bookIndex + 1;
    if (nextBookIndex >= maxChapters.length) {
      print('Already at the end of the Bible');
      return;
    }

    String nextBook = maxChapters[nextBookIndex].toString();
    int nextChapter = currentChapter <= maxChapters[nextBookIndex] ? currentChapter : 1;

    String filePath = 'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$nextBook/$nextBook$nextChapter.txt';
    String chapterContent = await rootBundle.loadString(filePath);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VerseDisplayWidget(
          book: nextBook,
          chapter: nextChapter,
          content: chapterContent,
          maxChapters: maxChapters,
          selectedLanguage: selectedLanguage,
        ),
      ),
    );
  }

  void _navigateToChapter(BuildContext context, String book, int selectedChapter, String selectedLanguage) async {
    final bookIndex = maxChapters.indexOf(maxChapters.firstWhere((element) => element >= chapter));

    if (selectedChapter < 1) {
      int previousBookIndex = bookIndex - 1;
      if (previousBookIndex < 0) {
        print('Already at the beginning of the Bible');
        return;
      }

      String previousBook = getBookName(previousBookIndex);
      int previousChapter = maxChapters[previousBookIndex];

      String filePath = 'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$previousBook/$previousBook$previousChapter.txt';
      String chapterContent = await rootBundle.loadString(filePath);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerseDisplayWidget(
            book: previousBook,
            chapter: previousChapter,
            content: chapterContent,
            maxChapters: maxChapters,
            selectedLanguage: selectedLanguage,
          ),
        ),
      );
    } else if (selectedChapter > maxChapters[bookIndex]) {
      int nextBookIndex = bookIndex + 1;
      if (nextBookIndex >= maxChapters.length) {
        print('Already at the end of the Bible');
        return;
      }

      String nextBook = getBookName(nextBookIndex);
      int nextChapter = selectedChapter <= maxChapters[nextBookIndex] ? selectedChapter : 1;

      String filePath = 'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$nextBook/$nextBook$nextChapter.txt';
      String chapterContent = await rootBundle.loadString(filePath);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerseDisplayWidget(
            book: nextBook,
            chapter: nextChapter,
            content: chapterContent,
            maxChapters: maxChapters,
            selectedLanguage: selectedLanguage,
          ),
        ),
      );
    } else {
      String filePath = 'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$book/$book$selectedChapter.txt';
      String chapterContent = await rootBundle.loadString(filePath);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerseDisplayWidget(
            book: book,
            chapter: selectedChapter,
            content: chapterContent,
            maxChapters: maxChapters,
            selectedLanguage: selectedLanguage,
          ),
        ),
      );
    }
  }

  String getBookName(int bookIndex) {
    // Replace this logic with your actual book name retrieval logic
    // For example, if you have a list of book names, you can use that list
    List<String> bookNames = ["Genesis", "Exodus", "Leviticus", ""]; // Replace with your book names
    if (bookIndex >= 0 && bookIndex < bookNames.length) {
      return bookNames[bookIndex];
    } else {
      // Handle out-of-bounds index or other cases
      return "Unknown Book";
    }
  }

}
