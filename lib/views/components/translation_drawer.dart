import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/word_book.dart';
import '../../models/word_entry.dart';
import '../../services/word_dictionary.dart';

class TranslationDrawer extends StatefulWidget {
  final bool isVisible;
  final String word;
  final VoidCallback onHide;
  final bool isTranslating;
  final String? translation;
  final String? source;
  final String? partOfSpeech;

  const TranslationDrawer({
    super.key,
    required this.isVisible,
    required this.word,
    required this.onHide,
    this.isTranslating = false,
    this.translation,
    this.source,
    this.partOfSpeech,
  });

  @override
  State<TranslationDrawer> createState() => _TranslationDrawerState();
}

class _TranslationDrawerState extends State<TranslationDrawer> {
  bool _isInWordBook = false;

  @override
  void initState() {
    super.initState();
    _checkWordBookStatus();
  }

  void _checkWordBookStatus() async {
    bool exists = await DatabaseService().isInWordBook(widget.word);
    if (mounted) {
      setState(() {
        _isInWordBook = exists;
      });
    }
  }

  Future<void> _toggleWordBook() async {
    final db = DatabaseService();

    if (_isInWordBook) {
      // 从单词本移除
      await db.removeFromWordBook(widget.word);
      if (mounted) {
        setState(() {
          _isInWordBook = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已从单词本移除')),
        );
      }
    } else {
      // 添加到单词本
      // 获取词性信息
      String? partOfSpeech = widget.partOfSpeech;
      if (partOfSpeech == null) {
        WordEntry? entry = WordDictionary.getTranslation(widget.word);
        partOfSpeech = entry?.partOfSpeech;
      }

      final wordBookEntry = WordBookEntry(
        word: widget.word,
        translation: widget.translation ?? '',
        partOfSpeech: partOfSpeech,
        source: widget.source ?? '',
        addedAt: DateTime.now(),
      );

      await db.addToWordBook(wordBookEntry);
      if (mounted) {
        setState(() {
          _isInWordBook = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已添加到单词本')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 手柄
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 单词信息
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 单词信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            widget.word,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 词性显示
                          if (!widget.isTranslating && widget.partOfSpeech != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.partOfSpeech!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          // 翻译来源
                          if (!widget.isTranslating && widget.source != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.source == '词典'
                                    ? Colors.blue.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.source!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.source == '词典'
                                      ? Colors.blue.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          // 单词本按钮
                          if (!widget.isTranslating && widget.translation != null)
                            ElevatedButton.icon(
                              onPressed: _toggleWordBook,
                              icon: Icon(
                                _isInWordBook
                                    ? Icons.bookmark_remove
                                    : Icons.bookmark_add,
                                size: 20,
                              ),
                              label: Text(
                                _isInWordBook ? '从单词本移除' : '加入单词本',
                                style: const TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isInWordBook
                                    ? Colors.orange.shade100
                                    : Colors.blue.shade100,
                                foregroundColor: _isInWordBook
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 翻译内容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            '中文翻译',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          widget.isTranslating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.translation ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    // 隐藏按钮
                    IconButton(
                      onPressed: widget.onHide,
                      icon: const Icon(Icons.close, size: 28),
                      color: Colors.grey.shade600,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
