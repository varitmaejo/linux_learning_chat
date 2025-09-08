import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  bool isUser;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String? command;

  @HiveField(5)
  String? explanation;

  @HiveField(6)
  MessageType type;

  @HiveField(7)
  List<String>? codeBlocks;

  @HiveField(8)
  String? category;

  @HiveField(9)
  String? difficulty;

  @HiveField(10)
  Map<String, dynamic>? metadata;

  @HiveField(11)
  bool isStarred;

  @HiveField(12)
  List<String>? tags;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.command,
    this.explanation,
    this.type = MessageType.text,
    this.codeBlocks,
    this.category,
    this.difficulty,
    this.metadata,
    this.isStarred = false,
    this.tags,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      command: json['command'],
      explanation: json['explanation'],
      type: MessageType.values[json['type'] ?? 0],
      codeBlocks: List<String>.from(json['codeBlocks'] ?? []),
      category: json['category'],
      difficulty: json['difficulty'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isStarred: json['isStarred'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'command': command,
      'explanation': explanation,
      'type': type.index,
      'codeBlocks': codeBlocks,
      'category': category,
      'difficulty': difficulty,
      'metadata': metadata,
      'isStarred': isStarred,
      'tags': tags,
    };
  }

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? command,
    String? explanation,
    MessageType? type,
    List<String>? codeBlocks,
    String? category,
    String? difficulty,
    Map<String, dynamic>? metadata,
    bool? isStarred,
    List<String>? tags,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      command: command ?? this.command,
      explanation: explanation ?? this.explanation,
      type: type ?? this.type,
      codeBlocks: codeBlocks ?? this.codeBlocks,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      metadata: metadata ?? this.metadata,
      isStarred: isStarred ?? this.isStarred,
      tags: tags ?? this.tags,
    );
  }

  // Helper methods
  bool get hasCommand => command != null && command!.isNotEmpty;
  bool get hasCodeBlocks => codeBlocks != null && codeBlocks!.isNotEmpty;
  bool get hasCategory => category != null && category!.isNotEmpty;

  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'เมื่อสักครู่';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

@HiveType(typeId: 1)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  command,
  @HiveField(2)
  code,
  @HiveField(3)
  tip,
  @HiveField(4)
  warning,
  @HiveField(5)
  success,
  @HiveField(6)
  error,
  @HiveField(7)
  quiz,
  @HiveField(8)
  explanation,
  @HiveField(9)
  example,
  @HiveField(10)
  system,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'ข้อความ';
      case MessageType.command:
        return 'คำสั่ง';
      case MessageType.code:
        return 'โค้ด';
      case MessageType.tip:
        return 'เคล็ดลับ';
      case MessageType.warning:
        return 'คำเตือน';
      case MessageType.success:
        return 'สำเร็จ';
      case MessageType.error:
        return 'ข้อผิดพลาด';
      case MessageType.quiz:
        return 'แบบทดสอบ';
      case MessageType.explanation:
        return 'คำอธิบาย';
      case MessageType.example:
        return 'ตัวอย่าง';
      case MessageType.system:
        return 'ระบบ';
    }
  }

  String get emoji {
    switch (this) {
      case MessageType.text:
        return '💬';
      case MessageType.command:
        return '⚡';
      case MessageType.code:
        return '💻';
      case MessageType.tip:
        return '💡';
      case MessageType.warning:
        return '⚠️';
      case MessageType.success:
        return '✅';
      case MessageType.error:
        return '❌';
      case MessageType.quiz:
        return '📝';
      case MessageType.explanation:
        return '📚';
      case MessageType.example:
        return '🔍';
      case MessageType.system:
        return '🤖';
    }
  }
}