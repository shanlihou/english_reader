class ReadingProgress {
  final int? id;
  final String fileName;
  final String filePath;
  final int currentPage;
  final int totalPages;
  final double progress; // 0.0 到 1.0 的进度百分比
  final DateTime lastReadAt;

  ReadingProgress({
    this.id,
    required this.fileName,
    required this.filePath,
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    required this.lastReadAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'progress': progress,
      'lastReadAt': lastReadAt.toIso8601String(),
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      progress: json['progress'],
      lastReadAt: DateTime.parse(json['lastReadAt']),
    );
  }
}
