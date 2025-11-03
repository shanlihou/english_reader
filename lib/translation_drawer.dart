import 'package:flutter/material.dart';

class TranslationDrawer extends StatelessWidget {
  final bool isVisible;
  final String word;
  final VoidCallback onHide;
  final bool isTranslating;
  final String? translation;
  final String? source;

  const TranslationDrawer({
    super.key,
    required this.isVisible,
    required this.word,
    required this.onHide,
    this.isTranslating = false,
    this.translation,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 单词信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            word,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!isTranslating && source != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: source == '词典'
                                    ? Colors.blue.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                source!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: source == '词典'
                                      ? Colors.blue.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 翻译内容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          isTranslating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  translation ?? '',
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
                      onPressed: onHide,
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
            ),
          ],
        ),
      ),
    );
  }
}
