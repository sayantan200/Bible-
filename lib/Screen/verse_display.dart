import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bible/models/bible_data.dart';
import 'package:bible/Services/bible_data_loader.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool shouldAutoPlay = true;
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

  void playMusic(String audioUrl) async {
    try {
      await audioPlayer.play(UrlSource(audioUrl));
      if (mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      print('Error playing audio: $e');
      // Handle the error, e.g., show a message to the user
    }
  }

  late BibleData bibleData;

  Future<void> _loadBibleData() async {
    try {
      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        // Set up a loading state if needed
      });

      bibleData = await BibleDataService().loadBibleData();

      if (mounted) {
        // Check again if the widget is still mounted before setting the state
        setState(() {
          // Clear the loading state if needed
        });
      }
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

    _loadBibleData();

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

    audioPlayer.onPlayerComplete.listen((event) {
      // Audio playback completed, navigate to the next chapter and start playing if needed
      if (shouldAutoPlay) {
        _navigateToNextChapter(context);
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (bibleData == null) {
      return CircularProgressIndicator(); // You can replace this with your loading widget
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 38, 83, 130),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Book selection
            ElevatedButton(
              onPressed: () {
                _showBookSelectionDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 38, 83,
                    130), // Set the background color to transparent
              ),
              child: Text(
                widget.book,
                style: TextStyle(
                  fontSize: 20.0, // Set the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.0), // Add some spacing
            // Chapter selection
            ElevatedButton(
              onPressed: () {
                _showChapterSelectionDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 38, 83,
                    130), // Set the background color to transparent
              ),
              child: Text(
                widget.chapter.toString(),
                style: TextStyle(
                  fontSize: 20.0, // Set the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe from left to right (previous chapter)
            _navigateToPreviousChapter(context);
          } else {
            // Swipe from right to left (next chapter)
            _navigateToNextChapter(context);
          }
        },
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: SingleChildScrollView(
                  child: Text(
                    widget.content,
                    style: const TextStyle(fontSize: 23.0),
                  ),
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                minHeight: 58.0,
              ),
              color: Color.fromARGB(255, 38, 83, 130),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left button
                  ElevatedButton(
                    onPressed: () => _navigateToPreviousChapter(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 38, 83,
                          130), // Set the background color to transparent
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      size: 45,
                    ),
                  ),
                  // Play button
                  if (getBookIndex() >= 39 &&
                      widget.selectedLanguage == 'Turkish')
                    IconButton(
                      icon: Image.asset(
                        isPlaying
                            ? 'assets/images/pausebutton.png'
                            : 'assets/images/playbutton.png',
                        width: 50.0, // Set the width as needed
                        height: 50.0, // Set the height as needed
                        // Set the height as needed
                      ),
                      iconSize: 56.0,
                      onPressed: () async {
                        if (isPlaying) {
                          pauseMusic();
                        } else {
                          // Check if the book is in the New Testament and the language is Turkish
                          int bookIndex =
                              bibleData.booksOfBibleTur.indexOf(widget.book);
                          if (bookIndex >= 39 &&
                              widget.selectedLanguage == 'Turkish') {
                            print('$bookIndex');
                            String audioName =
                                bibleData.turAudioName[bookIndex - 39]
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
                  // Right button
                  ElevatedButton(
                    onPressed: () => _navigateToNextChapter(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 38, 83,
                            130) // Set the background color to transparent
                        ),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 45,
                    ),
                  ),
                ],
              ),
            ),
            if (isPlaying) slider(),
          ],
        ),
      ),
    );
  }

  // Navigate to the next chapter content
  void _navigateToNextChapter(BuildContext context) async {
    int nextChapter = widget.chapter + 1;

    if (nextChapter > bibleData.chaptersForAll[getBookIndex()]) {
      // If the next chapter exceeds the last chapter of the current book, check for the next book
      int nextBookIndex = getBookIndex() + 1;

      if (nextBookIndex >= 0 &&
          nextBookIndex < bibleData.chaptersForAll.length) {
        String nextBook = widget.selectedLanguage == 'English'
            ? bibleData.booksOfBibleEng[nextBookIndex]
            : bibleData.booksOfBibleTur[nextBookIndex];
        ;
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return VerseDisplayWidget(
            book: book,
            chapter: chapter,
            content: chapterContent,
            maxChapters: widget.maxChapters,
            selectedLanguage: widget.selectedLanguage,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child; // Return the child directly for no transition
        },
      ),
    );
  }

  // Navigate to the previous chapter content
  void _navigateToPreviousChapter(BuildContext context) async {
    int previousChapter = widget.chapter - 1;
    int previousBookIndex = getBookIndex();

    ;

    if (previousChapter < 1) {
      print("hello2");
      // If the previous chapter is less than 1, check for the previous book
      previousBookIndex = getBookIndex() - 1;
      print("entered{$previousBookIndex}");

      if (previousBookIndex >= 0) {
        String previousBook = widget.selectedLanguage == 'English'
            ? bibleData.booksOfBibleEng[previousBookIndex]
            : bibleData.booksOfBibleTur[previousBookIndex];
        int lastChapterOfPreviousBook =
            bibleData.chaptersForAll[previousBookIndex];
        print("hello 1 {$lastChapterOfPreviousBook}");

        _navigateToChapterContent(
            context, previousBook, lastChapterOfPreviousBook);
      } else {
        print('Already at the beginning of the Bible ${getBookIndex()}');
      }
    } else {
      print(
          'Navigating to previous chapter. Current Book Index: ${getBookIndex()}  and ');
      // Otherwise, navigate to the previous chapter in the current book
      _navigateToChapterContent(context, widget.book, previousChapter);
    }
  }

  void playMusicForChapter(String book, int chapter) {
    // Update the audio URL based on the new chapter
    int bookIndex = getBookIndex();
    if (bookIndex >= 39 && widget.selectedLanguage == 'Turkish') {
      String audioName = bibleData.turAudioName[bookIndex - 39][widget.chapter];
      String audioUrl = 'https://incil.online/data/files/$audioName.mp3';
      print("Entered in playMusicForChapter $audioUrl");
      playMusic(audioUrl);
    }
  }

  int getBookIndex() {
    // Calculate the current book index
    int bookIndex = widget.selectedLanguage == 'English'
        ? bibleData.booksOfBibleEng.indexOf(widget.book)
        : bibleData.booksOfBibleTur.indexOf(widget.book);

    return bookIndex;
  }

  // Show book selection dialog
  Future<void> _showBookSelectionDialog(BuildContext context) async {
    String? selectedBook = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text('Book Choice'),
          ),
          contentPadding:
              EdgeInsets.only(top: 20.0), // Adjust the top padding as needed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.75,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (String book in widget.selectedLanguage == 'English'
                      ? bibleData.booksOfBibleEng
                      : bibleData.booksOfBibleTur)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, book);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                      ),
                      child: Text(
                        book,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
    print("$selectedBook");

    if (selectedBook != null) {
      _navigateToChapterContent(context, selectedBook, 1);
    }
  }

// Show chapter selection dialog
  Future<void> _showChapterSelectionDialog(BuildContext context) async {
    int? selectedChapter = await showDialog(
      context: context,
      builder: (BuildContext context) {
        int bookIndex = widget.selectedLanguage == 'English'
            ? bibleData.booksOfBibleEng.indexOf(widget.book)
            : bibleData.booksOfBibleTur.indexOf(widget.book);

        return AlertDialog(
          title: Center(
            child: Text('Chapters'),
          ),
          contentPadding: EdgeInsets.only(top: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width *
                0.2, // Set the width as needed
            height: MediaQuery.of(context).size.height *
                0.75, // Set the height as needed
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 1; i <= bibleData.chaptersForAll[bookIndex]; i++)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, i);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ),
                      ),
                      child: Text(
                        i.toString(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedChapter != null) {
      _navigateToChapterContent(context, widget.book, selectedChapter);
    }
  }
}
