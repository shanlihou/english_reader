import 'package:flutter/material.dart';
import '../../services/word_dictionary.dart';

class InteractiveText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Function(String)? onWordTap;

  const InteractiveText({
    super.key,
    required this.text,
    required this.fontSize,
    this.onWordTap,
  });

  @override
  State<InteractiveText> createState() => _InteractiveTextState();
}

class _InteractiveTextState extends State<InteractiveText> {
  List<InlineSpan> _spans = [];

  @override
  void initState() {
    super.initState();
    _buildSpans();
  }

  @override
  void didUpdateWidget(InteractiveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text ||
        widget.fontSize != oldWidget.fontSize) {
      _buildSpans();
    }
  }

  void _buildSpans() {
    List<InlineSpan> spans = [];
    RegExp wordRegex = RegExp(r'\b[a-zA-Z]+\b');
    Iterable<RegExpMatch> matches = wordRegex.allMatches(widget.text);

    int lastIndex = 0;
    for (RegExpMatch match in matches) {
      // 添加匹配前的非单词字符
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: widget.text.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: widget.fontSize,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        );
      }

      // 添加匹配的单词
      String word = widget.text.substring(match.start, match.end);
      bool isEnglishWord = WordDictionary.isEnglishWord(word);

      if (isEnglishWord) {
        spans.add(
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                if (widget.onWordTap != null) {
                  widget.onWordTap!(word);
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  word,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    height: 1.6,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              fontSize: widget.fontSize,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    // 添加剩余的非单词字符
    if (lastIndex < widget.text.length) {
      spans.add(
        TextSpan(
          text: widget.text.substring(lastIndex),
          style: TextStyle(
            fontSize: widget.fontSize,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      );
    }

    setState(() {
      _spans = spans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RichText(text: TextSpan(children: _spans));
  }
}
