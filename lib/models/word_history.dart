class WordHistory {
  final int? id;
  final String word;
  final String translation;
  final String? partOfSpeech;
  final String source; // 词典或在线翻译
  final int clickCount; // 点击次数
  final DateTime lastViewedAt; // 最后点击时间

  WordHistory({
    this.id,
    required this.word,
    required this.translation,
    this.partOfSpeech,
    required this.source,
    required this.clickCount,
    required this.lastViewedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'partOfSpeech': partOfSpeech,
      'source': source,
      'clickCount': clickCount,
      'lastViewedAt': lastViewedAt.toIso8601String(),
    };
  }

  factory WordHistory.fromJson(Map<String, dynamic> json) {
    return WordHistory(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      partOfSpeech: json['partOfSpeech'],
      source: json['source'],
      clickCount: json['clickCount'] ?? 1,
      lastViewedAt: DateTime.parse(json['lastViewedAt']),
    );
  }
}
