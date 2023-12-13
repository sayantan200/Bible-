import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bible/models/bible_data.dart';
import 'package:bible/Services/bible_data_loader.dart';

class VerseDisplayWidget extends StatefulWidget {
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
  _VerseDisplayWidgetState createState() => _VerseDisplayWidgetState();
}

class _VerseDisplayWidgetState extends State<VerseDisplayWidget> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int timeProgress = 0;
  int audioDuration = 0;
  

  Widget slider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(getTimeString(timeProgress)),
            Text(getTimeString(audioDuration)),
          ],
        ),
        Slider.adaptive(
          value: timeProgress.toDouble(),
          max: audioDuration.toDouble(),
          onChanged: (value) {
            seekToSec(value.toInt());
          },
        ),
      ],
    );
  }

  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    audioPlayer.seek(newPos);
  }

  String getTimeString(int seconds) {
    String minuteString = '${(seconds ~/ 60).toString().padLeft(2, '0')}';
    String secondString = '${(seconds % 60).toString().padLeft(2, '0')}';
    return '$minuteString:$secondString';
  }

  pauseMusic() async {
    await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  playMusic(String audioUrl) async {
    await audioPlayer.play(UrlSource(audioUrl));
    setState(() {
      isPlaying = true;
    });
  }

  late BibleData bibleData;

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
    }
  }

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();

    audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        audioDuration = duration.inSeconds;
      });
      print('Duration changed: $audioDuration seconds');
    });

    audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        timeProgress = position.inSeconds;
        print('Duration changed: $timeProgress seconds');
      });
    });

    _loadBibleData();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verses - ${widget.book} Chapter ${widget.chapter}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.content,
                  style: const TextStyle(fontSize: 23.0),
                ),
              ),
            ),
            
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () async {
                if (isPlaying) {
                  pauseMusic();
                } else {
                  // Check if the book is in the New Testament and the language is Turkish
                  int bookIndex =
                      bibleData.booksOfBibleTur.indexOf(widget.book);
                  if (bookIndex >= 39 && widget.selectedLanguage == 'Turkish') {
                    print('$bookIndex');
                    String audioName = bibleData.turAudioName[bookIndex - 39]
                        [widget.chapter - 1];
                    String audioUrl =
                        'https://incil.online/data/files/$audioName.mp3';

                    playMusic(audioUrl);
                  } else {
                    // Display a message or take appropriate action if conditions are not met
                    // For example, you can show a snackbar or toast message
                    print(
                        'The selected language is: ${widget.selectedLanguage} ${widget.book.indexOf(widget.book)}');

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Audio not available for this book or language.'),
                      ),
                    );
                  }
                }
              },
            ),
            
            
            if (isPlaying) slider(),
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
    int nextChapter = widget.chapter + 1;

    if (nextChapter > widget.maxChapters.last) {
      // If the next chapter exceeds the last chapter of the current book, check for the next book
      int nextBookIndex = widget.maxChapters.indexOf(
          widget.maxChapters.firstWhere((element) => element > widget.chapter));

      if (nextBookIndex >= 0 && nextBookIndex < widget.maxChapters.length) {
        String nextBook = widget.maxChapters[nextBookIndex].toString();
        nextChapter = 1; // Reset to the first chapter of the next book

        _navigateToChapterContent(context, nextBook, nextChapter);
      } else {
        print('Already at the end of the Bible');
      }
    } else {
      // Otherwise, navigate to the next chapter in the current book
      _navigateToChapterContent(context, widget.book, nextChapter);
    }
  }

  // Navigate to a specific chapter content
  void _navigateToChapterContent(
      BuildContext context, String book, int chapter) async {
    String filePath =
        'assets/${widget.selectedLanguage == 'English' ? 'Eng' : 'Tur'}/$book/$book$chapter.txt';
    String chapterContent = await rootBundle.loadString(filePath);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VerseDisplayWidget(
          book: book,
          chapter: chapter,
          content: chapterContent,
          maxChapters: widget.maxChapters,
          selectedLanguage: widget.selectedLanguage,
        ),
      ),
    );
  }

  // Navigate to the previous chapter content
  void _navigateToPreviousChapter(BuildContext context) async {
    int previousChapter = widget.chapter - 1;

    if (previousChapter < 1) {
      // If the previous chapter is less than 1, check for the previous book
      int previousBookIndex = widget.maxChapters.indexOf(widget.maxChapters
              .firstWhere((element) => element >= widget.chapter)) -
          1;

      if (previousBookIndex >= 0) {
        String previousBook = widget.maxChapters[previousBookIndex].toString();
        int lastChapterOfPreviousBook = widget.maxChapters[previousBookIndex];

        _navigateToChapterContent(
            context, previousBook, lastChapterOfPreviousBook);
      } else {
        print('Already at the beginning of the Bible');
      }
    } else {
      // Otherwise, navigate to the previous chapter in the current book
      _navigateToChapterContent(context, widget.book, previousChapter);
    }
  }
}
