import 'package:flutter/material.dart';
import '../services/text_pagination.dart';
import 'components/interactive_text.dart';
import 'components/translation_drawer.dart';
import '../services/word_dictionary.dart';
import '../services/translation_service.dart';
import '../models/word_entry.dart';

class ReaderScreen extends StatefulWidget {
  final String fileName;
  final String content;

  const ReaderScreen({
    super.key,
    required this.fileName,
    required this.content,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late List<String> _pages;
  int _currentPageIndex = 0;
  double _fontSize = 16.0;
  final PageController _pageController = PageController();

  String? _selectedWord;
  bool _showTranslationDrawer = false;
  bool _isTranslating = false;
  String? _onlineTranslation;
  String? _translationSource;

  @override
  void initState() {
    super.initState();
    _pages = []; // 初始为空列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePagination();
    });
  }

  void _calculatePagination() {
    // 计算每页行数（基于默认字体大小）
    int linesPerPage = TextPagination.calculateLinesPerPage(
      MediaQuery.of(context).size.height,
      _fontSize,
    );
    setState(() {
      _pages = TextPagination.paginateText(
        widget.content,
        MediaQuery.of(context).size.height,
        linesPerPage,
      );
    });
  }

  void _recalculatePagination() {
    int linesPerPage = TextPagination.calculateLinesPerPage(
      MediaQuery.of(context).size.height,
      _fontSize,
    );
    setState(() {
      _pages = TextPagination.paginateText(
        widget.content,
        MediaQuery.of(context).size.height,
        linesPerPage,
      );
      _currentPageIndex = 0;
      _pageController.jumpToPage(0);
    });
  }

  void _onWordTap(String word) async {
    if (word.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _selectedWord = word;
      _showTranslationDrawer = true;
      _onlineTranslation = null;
      _translationSource = null;
    });

    // 首先检查本地词典
    WordEntry? wordEntry = WordDictionary.getTranslation(word);

    if (wordEntry != null) {
      // 使用本地词典
      setState(() {
        _isTranslating = false;
        _onlineTranslation = wordEntry.translation;
        _translationSource = '词典';
      });
    } else {
      // 使用在线翻译
      final translation = await TranslationService.translateWord(word);
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _onlineTranslation = translation?.translation ?? '翻译失败';
          _translationSource = '在线翻译';
        });
      }
    }
  }

  void _hideTranslationDrawer() {
    setState(() {
      _showTranslationDrawer = false;
      _selectedWord = null;
      _onlineTranslation = null;
      _translationSource = null;
    });
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName.replaceAll(RegExp(r'\.[^.]+$'), '')),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('使用说明'),
                  content: const Text(
                    '点击文本中的蓝色下划线单词查看翻译。\n\n'
                    '翻页操作：\n'
                    '• 点击屏幕左侧：上一页\n'
                    '• 点击屏幕右侧：下一页\n\n'
                    '注意：点击单词时会显示翻译抽屉，此时无法翻页。',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('知道了'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () {
              if (_fontSize > 12.0) {
                setState(() {
                  _fontSize -= 2.0;
                });
                _recalculatePagination();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () {
              if (_fontSize < 32.0) {
                setState(() {
                  _fontSize += 2.0;
                });
                _recalculatePagination();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
                // 翻页时隐藏抽屉
                _hideTranslationDrawer();
              });
            },
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: InteractiveText(
                    text: _pages[index],
                    fontSize: _fontSize,
                    onWordTap: _onWordTap,
                  ),
                ),
              );
            },
          ),
          // 左边缘翻页手势区域（只覆盖屏幕最左边10%的区域）
          Positioned.fill(
            left: 0,
            right: MediaQuery.of(context).size.width * 0.9,
            child: GestureDetector(
              onTap: () {
                // 只有当没有显示抽屉时才允许翻页
                if (!_showTranslationDrawer) {
                  _previousPage();
                }
              },
            ),
          ),
          // 右边缘翻页手势区域（只覆盖屏幕最右边10%的区域）
          Positioned.fill(
            left: MediaQuery.of(context).size.width * 0.9,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // 只有当没有显示抽屉时才允许翻页
                if (!_showTranslationDrawer) {
                  _nextPage();
                }
              },
            ),
          ),
          // 翻译抽屉
          if (_showTranslationDrawer && _selectedWord != null)
            TranslationDrawer(
              isVisible: _showTranslationDrawer,
              word: _selectedWord!,
              onHide: _hideTranslationDrawer,
              isTranslating: _isTranslating,
              translation: _onlineTranslation,
              source: _translationSource,
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPageIndex > 0 ? _previousPage : null,
            ),
            Text(
              '${_currentPageIndex + 1} / ${_pages.length}',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPageIndex < _pages.length - 1
                  ? _nextPage
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
