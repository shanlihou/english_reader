import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/word_history.dart';
import '../models/word_book.dart';

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
      version: 1,
      onCreate: (db, version) async {
        // 创建历史记录表
        await db.execute('''
          CREATE TABLE word_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            translation TEXT NOT NULL,
            partOfSpeech TEXT,
            source TEXT NOT NULL,
            viewedAt TEXT NOT NULL
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
      },
    );
  }

  // ========== 历史记录操作 ==========

  // 添加历史记录
  Future<void> addToHistory(WordHistory history) async {
    final db = await database;
    await db.insert('word_history', history.toJson());
  }

  // 获取所有历史记录（按时间倒序）
  Future<List<WordHistory>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'word_history',
      orderBy: 'viewedAt DESC',
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
}
