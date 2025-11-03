class TextPagination {
  /// 将文本分页
  /// [text] 要分页的文本
  /// [pageHeight] 页面高度
  /// [linesPerPage] 每页行数
  /// 返回分页后的文本列表
  static List<String> paginateText(
    String text,
    double pageHeight,
    int linesPerPage,
  ) {
    if (text.isEmpty) return [''];

    List<String> pages = [];
    List<String> lines = text.split('\n');
    List<String> currentPage = [];
    int lineCount = 0;

    for (String line in lines) {
      // 如果行数达到每页限制，开始新页面
      if (lineCount >= linesPerPage) {
        pages.add(currentPage.join('\n'));
        currentPage = [];
        lineCount = 0;
      }

      currentPage.add(line);
      lineCount++;
    }

    // 添加最后一页
    if (currentPage.isNotEmpty) {
      pages.add(currentPage.join('\n'));
    }

    return pages;
  }

  /// 计算每页行数
  /// 基于字体大小和页面高度估算
  static int calculateLinesPerPage(double pageHeight, double fontSize) {
    // 假设每行高度是字体大小的1.5倍
    double lineHeight = fontSize * 1.5;
    // 减去一些边距
    double usableHeight = pageHeight - 40; // 20px 上下边距
    return (usableHeight / lineHeight).floor();
  }
}
