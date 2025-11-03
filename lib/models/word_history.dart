class WordHistory {
  final int? id;
  final String word;
  final String translation;
  final String? partOfSpeech;
  final String source; // 词典或在线翻译
  final DateTime viewedAt;

  WordHistory({
    this.id,
    required this.word,
    required this.translation,
    this.partOfSpeech,
    required this.source,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'partOfSpeech': partOfSpeech,
      'source': source,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }

  factory WordHistory.fromJson(Map<String, dynamic> json) {
    return WordHistory(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      partOfSpeech: json['partOfSpeech'],
      source: json['source'],
      viewedAt: DateTime.parse(json['viewedAt']),
    );
  }
}
