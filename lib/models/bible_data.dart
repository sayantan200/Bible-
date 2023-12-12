class BibleData {
  final List<String> booksOfBibleTur;
  final List<String> booksOfBibleEng;
  final List<int> chaptersForAll;
  final List<List<String>> turAudioName;

  BibleData({
    required this.booksOfBibleTur,
    required this.booksOfBibleEng,
    required this.chaptersForAll,
    required this.turAudioName,
  });
}
