import 'package:flutter/material.dart';

class LinuxCommand {
  final String name;
  final String description;
  final String syntax;
  final List<String> examples;
  final CommandLevel level;
  final CommandCategory category;
  final List<String> options;
  final List<String> relatedCommands;
  final String? warning;
  final List<String> tips;
  final List<CommandExample> detailedExamples;
  final Map<String, String> commonErrors;
  final String? manualLink;
  final List<String> prerequisites;
  final int popularityScore;

  const LinuxCommand({
    required this.name,
    required this.description,
    required this.syntax,
    required this.examples,
    required this.level,
    required this.category,
    this.options = const [],
    this.relatedCommands = const [],
    this.warning,
    this.tips = const [],
    this.detailedExamples = const [],
    this.commonErrors = const {},
    this.manualLink,
    this.prerequisites = const [],
    this.popularityScore = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'syntax': syntax,
      'examples': examples,
      'level': level.name,
      'category': category.name,
      'options': options,
      'relatedCommands': relatedCommands,
      'warning': warning,
      'tips': tips,
      'detailedExamples': detailedExamples.map((e) => e.toJson()).toList(),
      'commonErrors': commonErrors,
      'manualLink': manualLink,
      'prerequisites': prerequisites,
      'popularityScore': popularityScore,
    };
  }

  factory LinuxCommand.fromJson(Map<String, dynamic> json) {
    return LinuxCommand(
      name: json['name'],
      description: json['description'],
      syntax: json['syntax'],
      examples: List<String>.from(json['examples']),
      level: CommandLevel.values.firstWhere((e) => e.name == json['level']),
      category: CommandCategory.values.firstWhere((e) => e.name == json['category']),
      options: List<String>.from(json['options'] ?? []),
      relatedCommands: List<String>.from(json['relatedCommands'] ?? []),
      warning: json['warning'],
      tips: List<String>.from(json['tips'] ?? []),
      detailedExamples: (json['detailedExamples'] as List?)
          ?.map((e) => CommandExample.fromJson(e))
          .toList() ?? [],
      commonErrors: Map<String, String>.from(json['commonErrors'] ?? {}),
      manualLink: json['manualLink'],
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      popularityScore: json['popularityScore'] ?? 0,
    );
  }
}

class CommandExample {
  final String command;
  final String description;
  final String? output;
  final String? explanation;
  final bool isInteractive;

  const CommandExample({
    required this.command,
    required this.description,
    this.output,
    this.explanation,
    this.isInteractive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'command': command,
      'description': description,
      'output': output,
      'explanation': explanation,
      'isInteractive': isInteractive,
    };
  }

  factory CommandExample.fromJson(Map<String, dynamic> json) {
    return CommandExample(
      command: json['command'],
      description: json['description'],
      output: json['output'],
      explanation: json['explanation'],
      isInteractive: json['isInteractive'] ?? false,
    );
  }
}

enum CommandLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension CommandLevelExtension on CommandLevel {
  String get displayName {
    switch (this) {
      case CommandLevel.beginner:
        return 'ผู้เริ่มต้น';
      case CommandLevel.intermediate:
        return 'ระดับกลาง';
      case CommandLevel.advanced:
        return 'ระดับสูง';
      case CommandLevel.expert:
        return 'ผู้เชี่ยวชาญ';
    }
  }

  Color get color {
    switch (this) {
      case CommandLevel.beginner:
        return Colors.green;
      case CommandLevel.intermediate:
        return Colors.orange;
      case CommandLevel.advanced:
        return Colors.red;
      case CommandLevel.expert:
        return Colors.purple;
    }
  }

  String get emoji {
    switch (this) {
      case CommandLevel.beginner:
        return '🌱';
      case CommandLevel.intermediate:
        return '🌿';
      case CommandLevel.advanced:
        return '🌳';
      case CommandLevel.expert:
        return '🏆';
    }
  }
}

enum CommandCategory {
  fileManagement,
  navigation,
  textProcessing,
  permissions,
  systemAdmin,
  processManagement,
  networking,
  archive,
  automation,
  development,
  monitoring,
  search,
}

extension CommandCategoryExtension on CommandCategory {
  String get displayName {
    switch (this) {
      case CommandCategory.fileManagement:
        return 'จัดการไฟล์';
      case CommandCategory.navigation:
        return 'การนำทาง';
      case CommandCategory.textProcessing:
        return 'ประมวลผลข้อความ';
      case CommandCategory.permissions:
        return 'การจัดการสิทธิ์';
      case CommandCategory.systemAdmin:
        return 'ผู้ดูแลระบบ';
      case CommandCategory.processManagement:
        return 'จัดการกระบวนการ';
      case CommandCategory.networking:
        return 'เครือข่าย';
      case CommandCategory.archive:
        return 'บีบอัดไฟล์';
      case CommandCategory.automation:
        return 'อัตโนมัติ';
      case CommandCategory.development:
        return 'การพัฒนา';
      case CommandCategory.monitoring:
        return 'การตรวจสอบ';
      case CommandCategory.search:
        return 'การค้นหา';
    }
  }

  String get emoji {
    switch (this) {
      case CommandCategory.fileManagement:
        return '📁';
      case CommandCategory.navigation:
        return '🧭';
      case CommandCategory.textProcessing:
        return '📝';
      case CommandCategory.permissions:
        return '🔐';
      case CommandCategory.systemAdmin:
        return '⚙️';
      case CommandCategory.processManagement:
        return '⚡';
      case CommandCategory.networking:
        return '🌐';
      case CommandCategory.archive:
        return '📦';
      case CommandCategory.automation:
        return '🤖';
      case CommandCategory.development:
        return '💻';
      case CommandCategory.monitoring:
        return '📊';
      case CommandCategory.search:
        return '🔍';
    }
  }

  Color get color {
    switch (this) {
      case CommandCategory.fileManagement:
        return const Color(0xFF2196F3);
      case CommandCategory.navigation:
        return const Color(0xFF4CAF50);
      case CommandCategory.textProcessing:
        return const Color(0xFFFF9800);
      case CommandCategory.permissions:
        return const Color(0xFFE91E63);
      case CommandCategory.systemAdmin:
        return const Color(0xFF9C27B0);
      case CommandCategory.processManagement:
        return const Color(0xFF607D8B);
      case CommandCategory.networking:
        return const Color(0xFF795548);
      case CommandCategory.archive:
        return const Color(0xFF00BCD4);
      case CommandCategory.automation:
        return const Color(0xFFFF5722);
      case CommandCategory.development:
        return const Color(0xFF3F51B5);
      case CommandCategory.monitoring:
        return const Color(0xFF8BC34A);
      case CommandCategory.search:
        return const Color(0xFFFFEB3B);
    }
  }
}

class LinuxCommandDatabase {
  static final LinuxCommandDatabase _instance = LinuxCommandDatabase._internal();
  factory LinuxCommandDatabase() => _instance;
  LinuxCommandDatabase._internal();

  final Map<String, LinuxCommand> _commands = {
    'ls': LinuxCommand(
      name: 'ls',
      description: 'แสดงรายการไฟล์และโฟลเดอร์ในไดเรกทอรี',
      syntax: 'ls [options] [directory]',
      examples: ['ls', 'ls -la', 'ls -lh /home', 'ls -t *.txt'],
      level: CommandLevel.beginner,
      category: CommandCategory.fileManagement,
      options: [
        '-l: แสดงรายละเอียดแบบยาว',
        '-a: แสดงไฟล์ซ่อน',
        '-h: แสดงขนาดที่อ่านง่าย',
        '-t: เรียงตามเวลาแก้ไข',
        '-r: เรียงลำดับย้อนกลับ',
        '-R: แสดงโฟลเดอร์ย่อยทั้งหมด',
      ],
      relatedCommands: ['dir', 'tree', 'find'],
      tips: [
        'ใช้ ls -la เพื่อดูไฟล์ซ่อนและข้อมูลละเอียด',
        'ls -lh แสดงขนาดไฟล์ในรูปแบบที่อ่านง่าย (KB, MB, GB)',
        'ls -t เรียงไฟล์ตามเวลาแก้ไขล่าสุด',
      ],
      detailedExamples: [
        CommandExample(
          command: 'ls -la',
          description: 'แสดงรายการไฟล์ทั้งหมดพร้อมรายละเอียด',
          output: 'drwxr-xr-x 5 user user 4096 Jan 15 10:30 Documents\n-rw-r--r-- 1 user user 1024 Jan 14 15:20 file.txt',
          explanation: 'แสดงสิทธิ์, เจ้าของ, ขนาด และเวลาแก้ไข',
        ),
        CommandExample(
          command: 'ls -lh',
          description: 'แสดงขนาดไฟล์ในรูปแบบที่อ่านง่าย',
          output: '-rw-r--r-- 1 user user 1.5K Jan 14 15:20 file.txt\n-rw-r--r-- 1 user user 2.3M Jan 13 09:15 image.jpg',
        ),
      ],
      popularityScore: 100,
    ),

    'cd': LinuxCommand(
      name: 'cd',
      description: 'เปลี่ยนไดเรกทอรีปัจจุบัน',
      syntax: 'cd [directory]',
      examples: ['cd /home', 'cd ..', 'cd ~', 'cd -'],
      level: CommandLevel.beginner,
      category: CommandCategory.navigation,
      relatedCommands: ['pwd', 'ls', 'mkdir'],
      tips: [
        'cd โดยไม่มีพารามิเตอร์จะกลับไปที่ home directory',
        'cd - จะกลับไปยังไดเรกทอรีก่อนหน้า',
        'cd .. ไปยังไดเรกทอรีแม่',
        'cd ~ ไปยัง home directory',
      ],
      detailedExamples: [
        CommandExample(
          command: 'cd /usr/local/bin',
          description: 'ไปยังไดเรกทอรีที่ระบุ',
          explanation: 'เปลี่ยนไปยังไดเรกทอรี /usr/local/bin',
        ),
        CommandExample(
          command: 'cd ..',
          description: 'ไปยังไดเรกทอรีแม่',
          explanation: '.. หมายถึงไดเรกทอรีที่อยู่เหนือขึ้นไปหนึ่งระดับ',
        ),
      ],
      popularityScore: 95,
    ),

    'pwd': LinuxCommand(
      name: 'pwd',
      description: 'แสดงเส้นทางของไดเรกทอรีปัจจุบัน',
      syntax: 'pwd',
      examples: ['pwd'],
      level: CommandLevel.beginner,
      category: CommandCategory.navigation,
      relatedCommands: ['cd', 'ls'],
      tips: [
        'pwd ย่อมาจาก "print working directory"',
        'มีประโยชน์เมื่อต้องการทราบว่าอยู่ไดเรกทอรีไหน',
      ],
      detailedExamples: [
        CommandExample(
          command: 'pwd',
          description: 'แสดงตำแหน่งปัจจุบัน',
          output: '/home/user/Documents',
          explanation: 'แสดงเส้นทางเต็มของไดเรกทอรีที่อยู่ปัจจุบัน',
        ),
      ],
      popularityScore: 85,
    ),

    'mkdir': LinuxCommand(
      name: 'mkdir',
      description: 'สร้างไดเรกทอรีใหม่',
      syntax: 'mkdir [options] directory_name',
      examples: ['mkdir newfolder', 'mkdir -p path/to/folder', 'mkdir dir1 dir2 dir3'],
      level: CommandLevel.beginner,
      category: CommandCategory.fileManagement,
      options: [
        '-p: สร้างไดเรกทอรีแม่ถ้าไม่มี',
        '-m: กำหนดสิทธิ์',
        '-v: แสดงข้อความยืนยัน',
      ],
      relatedCommands: ['rmdir', 'rm', 'ls'],
      tips: [
        'ใช้ -p เพื่อสร้างโฟลเดอร์หลายระดับพร้อมกัน',
        'สามารถสร้างหลายโฟลเดอร์พร้อมกันได้',
      ],
      detailedExamples: [
        CommandExample(
          command: 'mkdir -p project/src/components',
          description: 'สร้างโฟลเดอร์หลายระดับ',
          explanation: 'สร้างโฟลเดอร์ project, src และ components หากไม่มี',
        ),
      ],
      popularityScore: 80,
    ),

    'rm': LinuxCommand(
      name: 'rm',
      description: 'ลบไฟล์หรือไดเรกทอรี',
      syntax: 'rm [options] file/directory',
      examples: ['rm file.txt', 'rm -rf folder', 'rm *.tmp'],
      level: CommandLevel.intermediate,
      category: CommandCategory.fileManagement,
      options: [
        '-r: ลบไดเรกทอรีและไฟล์ข้างในทั้งหมด',
        '-f: บังคับลบโดยไม่ถามยืนยัน',
        '-i: ถามยืนยันก่อนลบ',
        '-v: แสดงข้อความยืนยัน',
      ],
      relatedCommands: ['rmdir', 'mv', 'cp'],
      warning: '⚠️ ระวัง! rm -rf สามารถลบไฟล์ถาวรและไม่สามารถกู้คืนได้',
      tips: [
        'ใช้ rm -i เพื่อความปลอดภัย',
        'ตรวจสอบไฟล์ก่อนใช้ rm -rf',
        'หลีกเลี่ยงการใช้ rm -rf /* อย่างเด็ดขาด',
      ],
      detailedExamples: [
        CommandExample(
          command: 'rm -i file.txt',
          description: 'ลบไฟล์โดยถามยืนยันก่อน',
          output: 'rm: remove regular file \'file.txt\'? y',
          explanation: 'ระบบจะถามก่อนลบ ตอบ y เพื่อยืนยัน',
        ),
        CommandExample(
          command: 'rm -rf temp/',
          description: 'ลบโฟลเดอร์และไฟล์ข้างในทั้งหมด',
          explanation: 'ลบโฟลเดอร์ temp และไฟล์ทั้งหมดข้างในโดยไม่ถามยืนยัน',
          isInteractive: true,
        ),
      ],
      commonErrors: {
        'rm: cannot remove \'file\': No such file or directory': 'ไฟล์ที่ต้องการลบไม่มีอยู่',
        'rm: cannot remove \'dir\': Is a directory': 'ต้องใช้ -r เพื่อลบไดเรกทอรี',
        'rm: cannot remove \'file\': Permission denied': 'ไม่มีสิทธิ์ลบไฟล์นี้',
      },
      popularityScore: 75,
    ),

    'cp': LinuxCommand(
      name: 'cp',
      description: 'คัดลอกไฟล์หรือไดเรกทอรี',
      syntax: 'cp [options] source destination',
      examples: ['cp file.txt backup.txt', 'cp -r folder1 folder2', 'cp *.txt /backup/'],
      level: CommandLevel.intermediate,
      category: CommandCategory.fileManagement,
      options: [
        '-r: คัดลอกไดเรกทอรีแบบ recursive',
        '-i: ถามยืนยันก่อนเขียนทับ',
        '-u: คัดลอกเฉพาะไฟล์ที่ใหม่กว่า',
        '-v: แสดงข้อความยืนยัน',
        '-p: รักษาข้อมูล metadata',
      ],
      relatedCommands: ['mv', 'rsync', 'scp'],
      tips: [
        'ใช้ -r เมื่อต้องการคัดลอกโฟลเดอร์',
        'ใช้ -i เพื่อป้องกันการเขียนทับไฟล์สำคัญ',
        'ใช้ wildcards (*) เพื่อคัดลอกหลายไฟล์',
      ],
      detailedExamples: [
        CommandExample(
          command: 'cp -r project/ backup/',
          description: 'คัดลอกโฟลเดอร์ทั้งหมด',
          explanation: 'คัดลอกโฟลเดอร์ project และไฟล์ข้างในทั้งหมดไปยัง backup',
        ),
        CommandExample(
          command: 'cp *.jpg images/',
          description: 'คัดลอกไฟล์ jpg ทั้งหมด',
          explanation: 'คัดลอกไฟล์ที่มีนามสกุล .jpg ทั้งหมดไปยังโฟลเดอร์ images',
        ),
      ],
      popularityScore: 70,
    ),

    'mv': LinuxCommand(
      name: 'mv',
      description: 'ย้ายหรือเปลี่ยนชื่อไฟล์/ไดเรกทอรี',
      syntax: 'mv [options] source destination',
      examples: ['mv old.txt new.txt', 'mv file.txt /tmp/', 'mv folder1 folder2'],
      level: CommandLevel.intermediate,
      category: CommandCategory.fileManagement,
      options: [
        '-i: ถามยืนยันก่อนเขียนทับ',
        '-u: ย้ายเฉพาะไฟล์ที่ใหม่กว่า',
        '-v: แสดงข้อความยืนยัน',
        '-n: ไม่เขียนทับไฟล์ที่มีอยู่',
      ],
      relatedCommands: ['cp', 'rm', 'rename'],
      tips: [
        'mv ทำทั้งการย้ายและเปลี่ยนชื่อ',
        'ไม่ต้องใช้ -r สำหรับโฟลเดอร์',
        'ใช้ -i เพื่อความปลอดภัย',
      ],
      detailedExamples: [
        CommandExample(
          command: 'mv report.doc reports/',
          description: 'ย้ายไฟล์ไปยังโฟลเดอร์อื่น',
          explanation: 'ย้ายไฟล์ report.doc ไปยังโฟลเดอร์ reports',
        ),
        CommandExample(
          command: 'mv oldname.txt newname.txt',
          description: 'เปลี่ยนชื่อไฟล์',
          explanation: 'เปลี่ยนชื่อไฟล์จาก oldname.txt เป็น newname.txt',
        ),
      ],
      popularityScore: 65,
    ),

    'grep': LinuxCommand(
      name: 'grep',
      description: 'ค้นหาข้อความในไฟล์',
      syntax: 'grep [options] pattern file',
      examples: ['grep "error" log.txt', 'grep -r "function" .', 'grep -i "hello" *.txt'],
      level: CommandLevel.intermediate,
      category: CommandCategory.textProcessing,
      options: [
        '-i: ไม่สนใจตัวพิมพ์เล็กใหญ่',
        '-r: ค้นหาในโฟลเดอร์ย่อย',
        '-n: แสดงหมายเลขบรรทัด',
        '-v: แสดงบรรทัดที่ไม่ตรงกับ pattern',
        '-c: นับจำนวนบรรทัดที่ตรงกัน',
        '-l: แสดงเฉพาะชื่อไฟล์ที่พบ',
      ],
      relatedCommands: ['find', 'awk', 'sed'],
      tips: [
        'ใช้ grep -i เพื่อค้นหาแบบไม่สนใจตัวพิมพ์',
        'ใช้ grep -r เพื่อค้นหาในโฟลเดอร์ย่อย',
        'สามารถใช้ regular expressions ได้',
      ],
      detailedExamples: [
        CommandExample(
          command: 'grep -n "error" /var/log/syslog',
          description: 'ค้นหาคำว่า error พร้อมแสดงหมายเลขบรรทัด',
          output: '45: Jan 15 10:30:15 server error: connection failed\n67: Jan 15 11:20:32 server error: timeout',
        ),
        CommandExample(
          command: 'grep -r "TODO" src/',
          description: 'ค้นหา TODO ในโฟลเดอร์ src ทั้งหมด',
          explanation: 'ค้นหาคำว่า TODO ในไฟล์ทั้งหมดในโฟลเดอร์ src และโฟลเดอร์ย่อย',
        ),
      ],
      popularityScore: 85,
    ),

    'find': LinuxCommand(
      name: 'find',
      description: 'ค้นหาไฟล์และไดเรกทอรี',
      syntax: 'find [path] [expression]',
      examples: ['find . -name "*.txt"', 'find /home -user john', 'find . -type f -size +10M'],
      level: CommandLevel.advanced,
      category: CommandCategory.search,
      options: [
        '-name: ค้นหาตามชื่อ',
        '-type: ค้นหาตามประเภท (f=file, d=directory)',
        '-size: ค้นหาตามขนาด',
        '-user: ค้นหาตามเจ้าของ',
        '-mtime: ค้นหาตามเวลาแก้ไข',
        '-exec: รันคำสั่งกับไฟล์ที่พบ',
      ],
      relatedCommands: ['locate', 'grep', 'ls'],
      tips: [
        'ใช้ -iname เพื่อค้นหาแบบไม่สนใจตัวพิมพ์',
        'ใช้ -exec เพื่อทำอะไรกับไฟล์ที่พบ',
        'ใช้ wildcards (*) ในการค้นหา',
      ],
      detailedExamples: [
        CommandExample(
          command: 'find . -name "*.log" -mtime -7',
          description: 'ค้นหาไฟล์ .log ที่แก้ไขภายใน 7 วัน',
          explanation: 'ค้นหาไฟล์ที่มีนามสกุล .log และถูกแก้ไขภายใน 7 วันที่ผ่านมา',
        ),
        CommandExample(
          command: 'find /var -type f -size +100M',
          description: 'ค้นหาไฟล์ที่มีขนาดใหญ่กว่า 100MB',
          explanation: 'ค้นหาไฟล์ในโฟลเดอร์ /var ที่มีขนาดมากกว่า 100 เมกะไบต์',
        ),
      ],
      popularityScore: 70,
    ),

    'chmod': LinuxCommand(
      name: 'chmod',
      description: 'เปลี่ยนสิทธิ์การเข้าถึงไฟล์',
      syntax: 'chmod [permissions] file',
      examples: ['chmod 755 script.sh', 'chmod +x file', 'chmod u+w,g-r file.txt'],
      level: CommandLevel.advanced,
      category: CommandCategory.permissions,
      options: [
        '+: เพิ่มสิทธิ์',
        '-: ลบสิทธิ์',
        '=: กำหนดสิทธิ์',
        'u: user (เจ้าของ)',
        'g: group (กลุ่ม)',
        'o: others (อื่นๆ)',
        'a: all (ทุกคน)',
      ],
      relatedCommands: ['chown', 'chgrp', 'umask'],
      warning: '⚠️ ระวังการเปลี่ยนสิทธิ์ไฟล์ระบบ อาจทำให้ระบบเสียหายได้',
      tips: [
        '755 = rwxr-xr-x (เจ้าของทำทุกอย่างได้, อื่นๆอ่านและรันได้)',
        '644 = rw-r--r-- (เจ้าของอ่านเขียนได้, อื่นๆอ่านได้)',
        'chmod +x เพื่อทำให้ไฟล์รันได้',
      ],
      detailedExamples: [
        CommandExample(
          command: 'chmod 755 script.sh',
          description: 'ให้สิทธิ์ execute กับ script',
          explanation: '7=rwx (เจ้าของ), 5=r-x (กลุ่ม), 5=r-x (อื่นๆ)',
        ),
        CommandExample(
          command: 'chmod u+x,g+w file.txt',
          description: 'เพิ่มสิทธิ์ execute ให้เจ้าของ และ write ให้กลุ่ม',
          explanation: 'u+x = เพิ่มสิทธิ์ execute ให้ user, g+w = เพิ่มสิทธิ์ write ให้ group',
        ),
      ],
      popularityScore: 60,
    ),

    'sudo': LinuxCommand(
      name: 'sudo',
      description: 'รันคำสั่งด้วยสิทธิ์ administrator',
      syntax: 'sudo command',
      examples: ['sudo apt update', 'sudo systemctl restart nginx', 'sudo chmod 777 /tmp'],
      level: CommandLevel.intermediate,
      category: CommandCategory.systemAdmin,
      options: [
        '-u: รันในนาม user อื่น',
        '-i: เข้าสู่ interactive shell',
        '-s: รัน shell',
        '-l: แสดงสิทธิ์ที่มี',
      ],
      relatedCommands: ['su', 'whoami', 'id'],
      warning: '⚠️ ใช้ sudo อย่างระมัดระวัง เพราะมีสิทธิ์สูงสุดในระบบ',
      tips: [
        'sudo ต้องใส่รหัสผ่านของคุณเอง ไม่ใช่ root',
        'ใช้ sudo -l เพื่อดูสิทธิ์ที่มี',
        'หลีกเลี่ยงการใช้ sudo su - ถ้าไม่จำเป็น',
      ],
      prerequisites: ['ต้องอยู่ในกลุ่ม sudo หรือ wheel'],
      detailedExamples: [
        CommandExample(
          command: 'sudo apt update',
          description: 'อัพเดทแพ็คเกจ (ต้องใช้สิทธิ์ admin)',
          explanation: 'รันคำสั่ง apt update ด้วยสิทธิ์ root เพื่ออัพเดทรายการแพ็คเกจ',
        ),
        CommandExample(
          command: 'sudo -u www-data ls /var/www',
          description: 'รันคำสั่งในนาม user อื่น',
          explanation: 'รันคำสั่ง ls ในนาม user www-data',
        ),
      ],
      popularityScore: 90,
    ),

    'ps': LinuxCommand(
      name: 'ps',
      description: 'แสดงรายการกระบวนการที่ทำงานอยู่',
      syntax: 'ps [options]',
      examples: ['ps aux', 'ps -ef', 'ps -u username'],
      level: CommandLevel.intermediate,
      category: CommandCategory.processManagement,
      options: [
        'aux: แสดงกระบวนการทั้งหมด',
        '-e: แสดงกระบวนการทั้งหมด',
        '-f: แสดงข้อมูลแบบเต็ม',
        '-u: แสดงกระบวนการของ user ที่ระบุ',
        '--forest: แสดงแบบ tree',
      ],
      relatedCommands: ['top', 'htop', 'kill', 'killall'],
      tips: [
        'ps aux แสดงกระบวนการทั้งหมดพร้อมรายละเอียด',
        'ใช้ grep ร่วมกับ ps เพื่อค้นหากระบวนการ',
        'PID คือหมายเลขประจำกระบวนการ',
      ],
      detailedExamples: [
        CommandExample(
          command: 'ps aux | grep apache',
          description: 'ค้นหากระบวนการ Apache',
          output: 'root     1234  0.0  1.2 123456  7890 ?  S  10:30  0:01 /usr/sbin/apache2',
          explanation: 'แสดงกระบวนการที่มีคำว่า apache พร้อม PID และข้อมูลการใช้ทรัพยากร',
        ),
      ],
      popularityScore: 75,
    ),

    'top': LinuxCommand(
      name: 'top',
      description: 'แสดงกระบวนการที่ทำงานอยู่แบบ real-time',
      syntax: 'top [options]',
      examples: ['top', 'top -u username', 'top -p 1234'],
      level: CommandLevel.intermediate,
      category: CommandCategory.monitoring,
      options: [
        '-u: แสดงกระบวนการของ user ที่ระบุ',
        '-p: แสดงกระบวนการที่ระบุ PID',
        '-d: กำหนดความถี่ในการอัพเดท',
        '-n: จำนวนครั้งที่อัพเดทแล้วออก',
      ],
      relatedCommands: ['htop', 'ps', 'iostat', 'vmstat'],
      tips: [
        'กด q เพื่อออกจาก top',
        'กด k เพื่อ kill กระบวนการ',
        'กด M เพื่อเรียงตามการใช้ memory',
        'กด P เพื่อเรียงตามการใช้ CPU',
      ],
      detailedExamples: [
        CommandExample(
          command: 'top -d 1',
          description: 'อัพเดทข้อมูลทุก 1 วินาทีี',
          explanation: 'แสดงข้อมูลกระบวนการและอัพเดททุกวินาที',
          isInteractive: true,
        ),
      ],
      popularityScore: 80,
    ),

    'tar': LinuxCommand(
      name: 'tar',
      description: 'บีบอัดและแตกไฟล์',
      syntax: 'tar [options] archive files',
      examples: ['tar -czf backup.tar.gz files/', 'tar -xzf archive.tar.gz', 'tar -tzf archive.tar.gz'],
      level: CommandLevel.intermediate,
      category: CommandCategory.archive,
      options: [
        '-c: สร้าง archive',
        '-x: แตก archive',
        '-z: ใช้ gzip compression',
        '-j: ใช้ bzip2 compression',
        '-f: ระบุชื่อไฟล์ archive',
        '-v: แสดงรายละเอียด',
        '-t: แสดงเนื้อหาใน archive',
      ],
      relatedCommands: ['gzip', 'zip', 'unzip'],
      tips: [
        'tar -czf สำหรับบีบอัด, tar -xzf สำหรับแตกไฟล์',
        'ใช้ -v เพื่อดูความคืบหน้า',
        '.tar.gz และ .tgz เป็นนามสกุลเดียวกัน',
      ],
      detailedExamples: [
        CommandExample(
          command: 'tar -czf backup.tar.gz /home/user/documents',
          description: 'บีบอัดโฟลเดอร์ documents',
          explanation: 'สร้างไฟล์ backup.tar.gz จากโฟลเดอร์ documents',
        ),
        CommandExample(
          command: 'tar -xzf backup.tar.gz -C /tmp',
          description: 'แตกไฟล์ไปยังโฟลเดอร์ที่ระบุ',
          explanation: 'แตกไฟล์ backup.tar.gz ไปยังโฟลเดอร์ /tmp',
        ),
      ],
      popularityScore: 65,
    ),
  };

  Map<String, LinuxCommand> getAllCommands() => _commands;

  LinuxCommand? getCommand(String name) => _commands[name.toLowerCase()];

  List<LinuxCommand> getCommandsByLevel(CommandLevel level) {
    return _commands.values.where((cmd) => cmd.level == level).toList();
  }

  List<LinuxCommand> getCommandsByCategory(CommandCategory category) {
    return _commands.values.where((cmd) => cmd.category == category).toList();
  }

  List<LinuxCommand> searchCommands(String query) {
    query = query.toLowerCase();
    return _commands.values.where((cmd) =>
    cmd.name.toLowerCase().contains(query) ||
        cmd.description.toLowerCase().contains(query) ||
        cmd.examples.any((example) => example.toLowerCase().contains(query))
    ).toList();
  }

  List<LinuxCommand> getRecommendedCommands(UserLevel userLevel) {
    CommandLevel targetLevel;
    switch (userLevel) {
      case UserLevel.beginner:
        targetLevel = CommandLevel.beginner;
        break;
      case UserLevel.intermediate:
        targetLevel = CommandLevel.intermediate;
        break;
      case UserLevel.advanced:
        targetLevel = CommandLevel.advanced;
        break;
      case UserLevel.expert:
        targetLevel = CommandLevel.expert;
        break;
    }

    return getCommandsByLevel(targetLevel)
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
  }

  List<LinuxCommand> getPopularCommands({int limit = 10}) {
    final commands = _commands.values.toList()
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    return commands.take(limit).toList();
  }
}

// Quiz related classes
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final CommandLevel difficulty;
  final String? relatedCommand;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    this.relatedCommand,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty.name,
      'relatedCommand': relatedCommand,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      difficulty: CommandLevel.values.firstWhere((e) => e.name == json['difficulty']),
      relatedCommand: json['relatedCommand'],
    );
  }
}