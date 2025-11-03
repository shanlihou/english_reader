import 'package:flutter/material.dart';
import 'word_dictionary.dart';

class ClickableWord {
  final String word;
  final int startIndex;
  final int endIndex;
  final bool isClickable;

  ClickableWord({
    required this.word,
    required this.startIndex,
    required this.endIndex,
    required this.isClickable,
  });
}

class ClickableTextRenderer extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool highlightWord;
  final String? highlightedWord;

  const ClickableTextRenderer({
    super.key,
    required this.text,
    required this.fontSize,
    this.highlightWord = false,
    this.highlightedWord,
  });

  @override
  Widget build(BuildContext context) {
    List<ClickableWord> clickableWords = _parseText(text);

    return RichText(
      text: TextSpan(
        children: clickableWords.map((clickableWord) {
          final isHighlighted =
              highlightWord &&
              highlightedWord != null &&
              clickableWord.word.toLowerCase() ==
                  highlightedWord!.toLowerCase();
          final isClickable = clickableWord.isClickable;

          return TextSpan(
            text: clickableWord.word,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.6,
              color: isHighlighted
                  ? Colors.blue
                  : isClickable
                  ? Colors.blue.shade600
                  : Colors.black87,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              decoration: isClickable
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  List<ClickableWord> _parseText(String text) {
    List<ClickableWord> result = [];
    RegExp wordRegex = RegExp(r'\b[a-zA-Z]+\b');
    Iterable<RegExpMatch> matches = wordRegex.allMatches(text);

    int lastIndex = 0;
    for (RegExpMatch match in matches) {
      // 添加匹配前的非单词字符
      if (match.start > lastIndex) {
        result.add(
          ClickableWord(
            word: text.substring(lastIndex, match.start),
            startIndex: lastIndex,
            endIndex: match.start,
            isClickable: false,
          ),
        );
      }

      // 添加匹配的单词
      String word = text.substring(match.start, match.end);
      bool isInDictionary = WordDictionary.hasTranslation(word);

      result.add(
        ClickableWord(
          word: word,
          startIndex: match.start,
          endIndex: match.end,
          isClickable: isInDictionary,
        ),
      );

      lastIndex = match.end;
    }

    // 添加剩余的非单词字符
    if (lastIndex < text.length) {
      result.add(
        ClickableWord(
          word: text.substring(lastIndex),
          startIndex: lastIndex,
          endIndex: text.length,
          isClickable: false,
        ),
      );
    }

    return result;
  }
}
