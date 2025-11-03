import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/word_history.dart';
import '../models/word_book.dart';
import '../models/reading_progress.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 初始化数据库工厂（针对Web和桌面平台）
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    String path = join(await getDatabasesPath(), 'english_reader.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // 创建历史记录表
        await db.execute('''
          CREATE TABLE word_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            translation TEXT NOT NULL,
            partOfSpeech TEXT,
            source TEXT NOT NULL,
            clickCount INTEGER NOT NULL DEFAULT 1,
            lastViewedAt TEXT NOT NULL
          )
        ''');

        // 创建单词本表
        await db.execute('''
          CREATE TABLE word_book(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL UNIQUE,
            translation TEXT NOT NULL,
            partOfSpeech TEXT,
            source TEXT NOT NULL,
            addedAt TEXT NOT NULL
          )
        ''');

        // 创建索引
        await db.execute('CREATE INDEX idx_word_history_word ON word_history(word)');
        await db.execute('CREATE INDEX idx_word_book_word ON word_book(word)');

        // 创建阅读进度表
        await db.execute('''
          CREATE TABLE reading_progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fileName TEXT NOT NULL,
            filePath TEXT NOT NULL UNIQUE,
            currentPage INTEGER NOT NULL,
            totalPages INTEGER NOT NULL,
            progress REAL NOT NULL,
            lastReadAt TEXT NOT NULL
          )
        ''');

        // 创建阅读进度索引
        await db.execute('CREATE INDEX idx_reading_progress_lastReadAt ON reading_progress(lastReadAt)');
        await db.execute('CREATE INDEX idx_reading_progress_filePath ON reading_progress(filePath)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 数据库升级逻辑：从版本1升级到版本2
        if (oldVersion < 2) {
          // 创建阅读进度表
          await db.execute('''
            CREATE TABLE reading_progress(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fileName TEXT NOT NULL,
              filePath TEXT NOT NULL UNIQUE,
              currentPage INTEGER NOT NULL,
              totalPages INTEGER NOT NULL,
              progress REAL NOT NULL,
              lastReadAt TEXT NOT NULL
            )
          ''');

          // 创建阅读进度索引
          await db.execute('CREATE INDEX idx_reading_progress_lastReadAt ON reading_progress(lastReadAt)');
          await db.execute('CREATE INDEX idx_reading_progress_filePath ON reading_progress(filePath)');
        }
        // 从版本2升级到版本3：添加历史记录的点击次数和最后点击时间
        if (oldVersion < 3) {
          // 添加新字段（如果不存在）
          try {
            await db.execute('ALTER TABLE word_history ADD COLUMN clickCount INTEGER NOT NULL DEFAULT 1');
          } catch (e) {
            // 字段可能已存在，忽略错误
          }
          try {
            await db.execute('ALTER TABLE word_history ADD COLUMN lastViewedAt TEXT NOT NULL');
          } catch (e) {
            // 字段可能已存在，忽略错误
          }
          // 更新lastViewedAt字段（从viewedAt迁移）
          await db.execute('''
            UPDATE word_history
            SET lastViewedAt = viewedAt
            WHERE lastViewedAt IS NULL
          ''');
        }
      },
    );
  }

  // ========== 历史记录操作 ==========

  // 添加历史记录（如果已存在则增加点击次数）
  Future<void> addToHistory(WordHistory history) async {
    final db = await database;

    // 检查单词是否已存在
    final existing = await db.query(
      'word_history',
      where: 'word = ?',
      whereArgs: [history.word],
    );

    if (existing.isNotEmpty) {
      // 单词已存在，更新点击次数和最后查看时间
      final currentCount = existing.first['clickCount'] as int? ?? 1;
      await db.update(
        'word_history',
        {
          'clickCount': currentCount + 1,
          'lastViewedAt': history.lastViewedAt.toIso8601String(),
        },
        where: 'word = ?',
        whereArgs: [history.word],
      );
    } else {
      // 单词不存在，插入新记录
      await db.insert('word_history', history.toJson());
    }
  }

  // 获取所有历史记录（按最后查看时间倒序）
  Future<List<WordHistory>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'word_history',
      orderBy: 'lastViewedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return WordHistory.fromJson(maps[i]);
    });
  }

  // 清空历史记录
  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('word_history');
  }

  // 删除单条历史记录
  Future<void> deleteHistory(int id) async {
    final db = await database;
    await db.delete(
      'word_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 检查单词是否在历史中
  Future<bool> isInHistory(String word) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'word_history',
      where: 'word = ?',
      whereArgs: [word],
    );
    return maps.isNotEmpty;
  }

  // ========== 单词本操作 ==========

  // 添加到单词本
  Future<void> addToWordBook(WordBookEntry entry) async {
    final db = await database;
    await db.insert('word_book', entry.toJson());
  }

  // 检查单词是否在单词本中
  Future<bool> isInWordBook(String word) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'word_book',
      where: 'word = ?',
      whereArgs: [word],
    );
    return maps.isNotEmpty;
  }

  // 从单词本中移除
  Future<void> removeFromWordBook(String word) async {
    final db = await database;
    await db.delete(
      'word_book',
      where: 'word = ?',
      whereArgs: [word],
    );
  }

  // 获取所有单词本条目
  Future<List<WordBookEntry>> getAllWordBookEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'word_book',
      orderBy: 'addedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return WordBookEntry.fromJson(maps[i]);
    });
  }

  // 清空单词本
  Future<void> clearWordBook() async {
    final db = await database;
    await db.delete('word_book');
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ========== 阅读进度操作 ==========

  // 保存或更新阅读进度
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    final db = await database;
    // 使用 INSERT OR REPLACE 来实现插入或更新
    await db.insert(
      'reading_progress',
      progress.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有阅读进度（按最后阅读时间倒序）
  Future<List<ReadingProgress>> getAllReadingProgress() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      orderBy: 'lastReadAt DESC',
    );

    return List.generate(maps.length, (i) {
      return ReadingProgress.fromJson(maps[i]);
    });
  }

  // 获取最近的N条阅读记录
  Future<List<ReadingProgress>> getRecentReadingProgress({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      orderBy: 'lastReadAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ReadingProgress.fromJson(maps[i]);
    });
  }

  // 根据文件路径获取阅读进度
  Future<ReadingProgress?> getReadingProgressByPath(String filePath) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );

    if (maps.isEmpty) {
      return null;
    }

    return ReadingProgress.fromJson(maps.first);
  }

  // 删除阅读进度
  Future<void> deleteReadingProgress(String filePath) async {
    final db = await database;
    await db.delete(
      'reading_progress',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );
  }

  // 清空所有阅读进度
  Future<void> clearAllReadingProgress() async {
    final db = await database;
    await db.delete('reading_progress');
  }
}
