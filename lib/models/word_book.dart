class WordBookEntry {
  final int? id;
  final String word;
  final String translation;
  final String? partOfSpeech;
  final String source; // 词典或在线翻译
  final DateTime addedAt;

  WordBookEntry({
    this.id,
    required this.word,
    required this.translation,
    this.partOfSpeech,
    required this.source,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'partOfSpeech': partOfSpeech,
      'source': source,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory WordBookEntry.fromJson(Map<String, dynamic> json) {
    return WordBookEntry(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      partOfSpeech: json['partOfSpeech'],
      source: json['source'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}
