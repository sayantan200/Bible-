import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bible/models/bible_data.dart';

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
                  style: const TextStyle(fontSize: 23.0),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                // Check if the book is in the New Testament and the language is Turkish
                if (book.indexOf(book) >= 39 && selectedLanguage == 'Turkish') {
                  String audioName = BibleData
                      .turAudioName[book.indexOf(book) - 39][chapter - 1];
                  String audioUrl =
                      'https://incil.online/data/files/$audioName.mp3';

                  AudioPlayer audioPlayer = AudioPlayer();
                  audioPlayer.play(UrlSource(audioUrl));
                } else {
                  // Display a message or take appropriate action if conditions are not met
                  // For example, you can show a snackbar or toast message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Audio not available for this book or language.'),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _navigateToPreviousChapter(context),
                  child: const Text('Previous Chapter'),
                ),
                ElevatedButton(
                  onPressed: () => _navigateToNextChapter(context),
                  child: const Text('Next Chapter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to the next chapter content
  void _navigateToNextChapter(BuildContext context) async {
    int nextChapter = chapter + 1;

    if (nextChapter > maxChapters.last) {
      // If the next chapter exceeds the last chapter of the current book, check for the next book
      int nextBookIndex = maxChapters.indexOf(maxChapters.firstWhere((element) => element > chapter));

      if (nextBookIndex >= 0 && nextBookIndex < maxChapters.length) {
        String nextBook = maxChapters[nextBookIndex].toString();
        nextChapter = 1; // Reset to the first chapter of the next book

        _navigateToChapterContent(context, nextBook, nextChapter);
      } else {
        print('Already at the end of the Bible');
      }
    } else {
      // Otherwise, navigate to the next chapter in the current book
      _navigateToChapterContent(context, book, nextChapter);
    }
  }

  // Navigate to a specific chapter content
  void _navigateToChapterContent(BuildContext context, String book, int chapter) async {
    String filePath = 'assets/${selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$book/$book$chapter.txt';
    String chapterContent = await rootBundle.loadString(filePath);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VerseDisplayWidget(
          book: book,
          chapter: chapter,
          content: chapterContent,
          maxChapters: maxChapters,
          selectedLanguage: selectedLanguage,
        ),
      ),
    );
  }

  // Navigate to the previous chapter content
  void _navigateToPreviousChapter(BuildContext context) async {
    int previousChapter = chapter - 1;

    if (previousChapter < 1) {
      // If the previous chapter is less than 1, check for the previous book
      int previousBookIndex = maxChapters.indexOf(maxChapters.firstWhere((element) => element >= chapter)) - 1;

      if (previousBookIndex >= 0) {
        String previousBook = maxChapters[previousBookIndex].toString();
        int lastChapterOfPreviousBook = maxChapters[previousBookIndex];

        _navigateToChapterContent(context, previousBook, lastChapterOfPreviousBook);
      } else {
        print('Already at the beginning of the Bible');
      }
    } else {
      // Otherwise, navigate to the previous chapter in the current book
      _navigateToChapterContent(context, book, previousChapter);
    }
  }
}
