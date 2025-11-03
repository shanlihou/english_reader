import 'dart:convert';
import 'package:http/http.dart' as http;

class OnlineTranslation {
  final String translation;
  final String source;

  OnlineTranslation({required this.translation, required this.source});
}

class TranslationService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';
  static final Map<String, OnlineTranslation> _cache = {};

  /// 翻译单词
  /// [word] 要翻译的单词
  /// 返回翻译结果
  static Future<OnlineTranslation?> translateWord(String word) async {
    if (word.isEmpty) return null;

    word = word.trim().toLowerCase();

    // 检查缓存
    if (_cache.containsKey(word)) {
      return _cache[word];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$word&langpair=en|zh-CN'),
        headers: {'User-Agent': 'EnglishReader/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['responseStatus'] == 200) {
          final translation = data['responseData']['translatedText'] ?? '';
          final match = data['responseData']['match'] ?? 0.0;

          final result = OnlineTranslation(
            translation: translation,
            source: match.toString(),
          );

          // 存入缓存
          _cache[word] = result;
          return result;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      // print('Translation error: $e');
    }

    return null;
  }

  /// 预缓存常用单词
  static Future<void> preloadTranslations(List<String> words) async {
    final futures = words.map((word) async {
      word = word.toLowerCase();
      if (!_cache.containsKey(word)) {
        await translateWord(word);
      }
    });

    await Future.wait(futures);
  }

  /// 清除缓存
  static void clearCache() {
    _cache.clear();
  }

  /// 获取缓存大小
  static int get cacheSize => _cache.length;
}
