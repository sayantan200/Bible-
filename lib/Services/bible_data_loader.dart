// lib/services/bible_data_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible_data.dart';

class BibleDataService {
  Future<BibleData> loadBibleData() async {
    String data = await rootBundle.loadString('assets/bible_data.json');
    Map<String, dynamic> jsonData = json.decode(data);

    return BibleData(
      booksOfBibleTur: List<String>.from(jsonData['booksOfBibleTur']),
      booksOfBibleEng: List<String>.from(jsonData['booksOfBibleEng']),
      chaptersForAll: List<int>.from(jsonData['chaptersForAll']),
      turAudioName: (jsonData['turAudioName'] as List<dynamic>)
          .map((audioNames) =>
              List<String>.from(audioNames.map((name) => name as String)))
          .toList(),
    );
  }
}
