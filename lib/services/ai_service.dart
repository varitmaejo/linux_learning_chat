question: 'คำสั่งใดใช้สำหรับค้นหาข้อความในไฟล์?',
options: ['find', 'grep', 'locate', 'search'],
correctAnswer: 1,
explanation: 'grep ใช้สำหรับค้นหาข้อความหรือ pattern ในไฟล์',
difficulty: CommandLevel.intermediate,
relatedCommand: 'grep',
),
QuizQuestion(
id: 'q5',
question: 'chmod 755 หมายถึงอะไร?',
options: [
'rwxr-xr-x',
'rw-rw-rw-',
'rwxrwxrwx',
'r--r--r--'
],
correctAnswer: 0,
explanation: '755 = rwxr-xr-x หมายถึง เจ้าของทำทุกอย่างได้ (rwx), กลุ่มและอื่นๆ อ่านและรันได้ (r-x)',
difficulty: CommandLevel.advanced,
relatedCommand: 'chmod',
),
];

Future<Message> generateResponse(String userInput, UserProfile profile) async {
// จำลองการประมวลผล AI
await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));

final response = await _analyzeInput(userInput.toLowerCase(), profile);

return Message(
id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
text: response.text,
isUser: false,
timestamp: DateTime.now(),
type: response.type,
command: response.command,
explanation: response.explanation,
category: response.category,
);
}

Future<AIResponse> _analyzeInput(String input, UserProfile profile) async {
// ตรวจสอบคำสั่งพิเศษก่อน
if (_isHelpRequest(input)) {
return _getHelpResponse();
}

if (_isQuizRequest(input)) {
return _generateQuizResponse(profile);
}

if (_isStatsRequest(input)) {
return _getStatsResponse(profile);
}

if (_isResetRequest(input)) {
return _getResetConfirmation();
}

// ตรวจสอบคำสั่ง Linux
for (String command in _commandDb.getAllCommands().keys) {
if (input.contains(command)) {
_updateUserProgress(profile, command);
return _generateCommandResponse(command, profile);
}
}

// วิเคราะห์ pattern อื่นๆ
if (_isBeginnerRequest(input)) {
return _getBeginnerRecommendations(profile);
} else if (_isFileManagementRequest(input)) {
return _getFileManagementCommands();
} else if (_isNavigationRequest(input)) {
return _getNavigationCommands();
} else if (_isSearchRequest(input)) {
return _getSearchCommands();
} else if (_isPermissionRequest(input)) {
return _getPermissionCommands();
} else if (_isRecommendationRequest(input)) {
return _getPersonalizedRecommendations(profile);
} else if (_isLevelAssessmentRequest(input)) {
return _getLevelAssessment(profile);
} else if (_isCategoryRequest(input)) {
return _getCategoryOverview();
} else {
return _getGeneralResponse(profile);
}
}

// Helper methods for input detection
bool _isHelpRequest(String input) {
return input.contains('help') || input.contains('ช่วยเหลือ') ||
input.contains('วิธีใช้') || input.contains('คำแนะนำ');
}

bool _isQuizRequest(String input) {
return input.contains('ทดสอบ') || input.contains('แบบทดสอบ') ||
input.contains('quiz') || input.contains('ข้อสอบ');
}

bool _isStatsRequest(String input) {
return input.contains('สถิติ') || input.contains('ความก้าวหน้า') ||
input.contains('stats') || input.contains('progress');
}

bool _isResetRequest(String input) {
return input.contains('รีเซ็ต') || input.contains('reset') ||
input.contains('เริ่มใหม่') || input.contains('ล้างข้อมูล');
}

bool _isBeginnerRequest(String input) {
return input.contains('เริ่มต้น') || input.contains('beginner') ||
input.contains('มือใหม่') || input.contains('พื้นฐาน');
}

bool _isFileManagementRequest(String input) {
return input.contains('ไฟล์') || input.contains('file') ||
input.contains('จัดการไฟล์');
}

bool _isNavigationRequest(String input) {
return input.contains('นำทาง') || input.contains('เดิน') ||
input.contains('โฟลเดอร์') || input.contains('directory');
}

bool _isSearchRequest(String input) {
return input.contains('ค้นหา') || input.contains('search') ||
input.contains('หา');
}

bool _isPermissionRequest(String input) {
return input.contains('สิทธิ์') || input.contains('permission') ||
input.contains('chmod') || input.contains('เจ้าของ');
}

bool _isRecommendationRequest(String input) {
return input.contains('แนะนำ') || input.contains('recommend') ||
input.contains('ควรเรียน');
}

bool _isLevelAssessmentRequest(String input) {
return input.contains('ระดับ') || input.contains('level') ||
input.contains('ประเมิน') || input.contains('assess');
}

bool _isCategoryRequest(String input) {
return input.contains('หมวดหมู่') || input.contains('category') ||
input.contains('ประเภท');
}

// Response generators
AIResponse _getHelpResponse() {
return AIResponse(
text: '''
📚 **คำแนะนำการใช้งาน Linux Learning Assistant**

**🎯 วิธีถามคำถาม:**
• `ls คืออะไร` - เรียนรู้คำสั่งเฉพาะ
• `แนะนำคำสั่งพื้นฐาน` - รับคำแนะนำตามระดับ
• `วิธีจัดการไฟล์` - เรียนรู้ตามหมวดหมู่
• `ทดสอบความรู้` - ประเมินความเข้าใจ

**💡 คำสั่งพิเศษ:**
• `สถิติ` - ดูความก้าวหน้า
• `แนะนำสำหรับฉัน` - แนะนำเฉพาะบุคคล
• `ประเมินระดับ` - ตรวจสอบระดับทักษะ
• `หมวดหมู่คำสั่ง` - ดูคำสั่งตามประเภท

**🏆 ฟีเจอร์พิเศษ:**
✅ ระบบปรับการเรียนรู้ตามบุคคล
📊 ติดตามความก้าวหน้าแบบเรียลไทม์
🎯 แบบทดสอบและความสำเร็จ
💪 ระบบวันติดต่อกันในการเรียน

พิมพ์คำถามหรือคำสั่งที่สนใจได้เลย! 🚀
''',
type: MessageType.system,
);
}

AIResponse _generateQuizResponse(UserProfile profile) {
final availableQuestions = _quizQuestions.where((q) {
switch (profile.level) {
case UserLevel.beginner:
return q.difficulty == CommandLevel.beginner;
case UserLevel.intermediate:
return q.difficulty == CommandLevel.beginner ||
q.difficulty == CommandLevel.intermediate;
case UserLevel.advanced:
return q.difficulty != CommandLevel.expert;
case UserLevel.expert:
return true;
}
}).toList();

if (availableQuestions.isEmpty) {
return AIResponse(
text: 'ขออภัยครับ ยังไม่มีแบบทดสอบสำหรับระดับของคุณ',
type: MessageType.error,
);
}

final question = availableQuestions[_random.nextInt(availableQuestions.length)];
final optionsText = question.options
    .asMap()
    .entries
    .map((entry) => '${entry.key + 1}. ${entry.value}')
    .join('\n');

return AIResponse(
text: '''
📝 **แบบทดสอบ - ${question.difficulty.displayName}**

**คำถาม:** ${question.question}

$optionsText

กรุณาตอบด้วยหมายเลข (1-${question.options.length}) หรือพิมพ์คำตอบ

💡 *เคล็ดลับ: คิดอย่างระมัดระวังก่อนตอบ*
''',
type: MessageType.quiz,
category: 'quiz',
);
}

AIResponse _getStatsResponse(UserProfile profile) {
final progressPercent = profile.progressPercentage;
final exp = profile.experiencePoints;
final nextLevelExp = _getNextLevelExp(profile.level);

return AIResponse(
text: '''
📊 **สถิติการเรียนรู้ของ ${profile.name}**

**🎯 ระดับปัจจุบัน:** ${profile.level.emoji} ${profile.level.displayName}
**⭐ คะแนนประสบการณ์:** $exp XP
**📈 ความก้าวหน้า:** ${progressPercent.toStringAsFixed(1)}%

**📚 การเรียนรู้:**
• คำสั่งที่เรียนรู้: ${profile.learnedCommands.length} คำสั่ง
• การโต้ตอบทั้งหมด: ${profile.totalInteractions} ครั้ง
• วันติดต่อกัน: ${profile.streakDays} วัน 🔥

**🏆 ความสำเร็จ:** ${profile.achievements.length} รางวัล
${profile.achievements.take(3).map((a) => '${a.icon} ${a.title}').join('\n')}

**📋 คำสั่งล่าสุด:**
${profile.learnedCommands.take(5).map((cmd) => '• $cmd').join('\n')}

${_getEncouragementMessage(profile)}
''',
type: MessageType.system,
);
}

int _getNextLevelExp(UserLevel level) {
switch (level) {
case UserLevel.beginner: return 600;
case UserLevel.intermediate: return 1200;
case UserLevel.advanced: return 2000;
case UserLevel.expert: return 3000;
}
}

String _getEncouragementMessage(UserProfile profile) {
if (profile.streakDays >= 7) {
return '🔥 **สุดยอด!** คุณเรียนติดต่อกันมา ${profile.streakDays} วันแล้ว!';
} else if (profile.learnedCommands.length >= 10) {
return '🌟 **เก่งมาก!** คุณเรียนรู้คำสั่งไปแล้ว ${profile.learnedCommands.length} คำสั่ง!';
} else {
return '💪 **เก็บ!** มาเรียนรู้คำสั่งใหม่ๆ กันต่อ!';
}
}

AIResponse _getResetConfirmation() {
return AIResponse(
text: '''
⚠️ **ยืนยันการรีเซ็ตข้อมูล**

การรีเซ็ตจะลบข้อมูลต่อไปนี้:
• ประวัติการสนทนาทั้งหมด
• สถิติการเรียนรู้
• ความสำเร็จที่ได้รับ
• วันติดต่อกันในการเรียน

**ข้อมูลโปรไฟล์ (ชื่อ, มหาวิทยาลัย) จะยังคงอยู่**

หากต้องการดำเนินการ กรุณาพิมพ์ "ยืนยันรีเซ็ต"
หากไม่ต้องการ พิมพ์ "ยกเลิก"
''',
type: MessageType.warning,
);
}

AIResponse _generateCommandResponse(String command, UserProfile profile) {
final cmd = _commandDb.getCommand(command);
if (cmd == null) {
return AIResponse(
text: 'ขออภัยครับ ไม่พบข้อมูลคำสั่ง $command',
type: MessageType.error,
);
}

final difficulty = _getDifficultyIndicator(cmd.level);
final categoryIcon = cmd.category.emoji;

String response = '''
$categoryIcon **คำสั่ง: `$command`** $difficulty

📝 **คำอธิบาย:** ${cmd.description}

⚡ **รูปแบบการใช้งาน:**
```
${cmd.syntax}
```

💡 **ตัวอย่างการใช้งาน:**
${cmd.examples.map((e) => '• `$e`').join('\n')}
''';

if (cmd.options.isNotEmpty) {
response += '\n\n🔧 **ตัวเลือกสำคัญ:**\n';
response += cmd.options.take(4).map((opt) => '• $opt').join('\n');
}

if (cmd.warning != null) {
response += '\n\n${cmd.warning}';
}

if (cmd.tips.isNotEmpty) {
response += '\n\n💡 **เคล็ดลับ:**\n';
response += cmd.tips.take(2).map((tip) => '• $tip').join('\n');
}

if (cmd.relatedCommands.isNotEmpty) {
response += '\n\n🔗 **คำสั่งที่เกี่ยวข้อง:** ';
response += cmd.relatedCommands.take(3).map((c) => '`$c`').join(', ');
}

// เพิ่มคำแนะนำตามระดับผู้ใช้
response += _getPersonalizedTip(cmd, profile);

return AIResponse(
text: response,
type: MessageType.command,
command: command,
explanation: cmd.description,
category: cmd.category.name,
);
}

String _getDifficultyIndicator(CommandLevel level) {
switch (level) {
case CommandLevel.beginner:
return '🟢 ง่าย';
case CommandLevel.intermediate:
return '🟡 ปานกลาง';
case CommandLevel.advanced:
return '🟠 ยาก';
case CommandLevel.expert:
return '🔴 ผู้เชี่ยวชาญ';
}
}

String _getPersonalizedTip(LinuxCommand cmd, UserProfile profile) {
String tip = '\n\n';

if (profile.level == UserLevel.beginner && cmd.level != CommandLevel.beginner) {
tip += '📚 **สำหรับมือใหม่:** ลองฝึกคำสั่งพื้นฐานก่อน เช่น ls, cd, pwd';
} else if (profile.commandUsage[cmd.name] == null) {
tip += '🆕 **คำสั่งใหม่สำหรับคุณ!** ลองฝึกใช้ดู';
} else if ((profile.commandUsage[cmd.name] ?? 0) > 5) {
tip += '⭐ **คุณใช้คำสั่งนี้เป็นอย่างดีแล้ว!** ลองเรียนรู้คำสั่งขั้นสูงต่อ';
}

return tip;
}

AIResponse _getBeginnerRecommendations(UserProfile profile) {
final beginnerCommands = _commandDb.getCommandsByLevel(CommandLevel.beginner);
final unlearned = beginnerCommands.where((cmd) =>
!profile.learnedCommands.contains(cmd.name)
).take(5).toList();

String response = '''
🎓 **คำสั่งพื้นฐานสำหรับผู้เริ่มต้น**

เริ่มต้นด้วยคำสั่งเหล่านี้เพื่อสร้างพื้นฐานที่แข็งแรง:

''';

if (unlearned.isNotEmpty) {
response += '**🆕 คำสั่งที่แนะนำ:**\n';
for (var cmd in unlearned) {
response += '${cmd.category.emoji} **`${cmd.name}`** - ${cmd.description}\n';
}
}

response += '''

**📚 เส้นทางการเรียนรู้:**
1️⃣ **การนำทาง:** `pwd`, `ls`, `cd`
2️⃣ **จัดการไฟล์:** `mkdir`, `touch`, `cp`, `mv`
3️⃣ **ดูเนื้อหา:** `cat`, `less`, `head`, `tail`
4️⃣ **ค้นหา:** `find`, `grep`

พิมพ์ชื่อคำสั่งที่สนใจเพื่อเรียนรู้รายละเอียด! 🚀
''';

return AIResponse(
text: response,
type: MessageType.explanation,
category: 'recommendations',
);
}

AIResponse _getFileManagementCommands() {
return AIResponse(
text: '''
📁 **คำสั่งจัดการไฟล์และโฟลเดอร์**

**🆕 สร้างและลบ:**
• `mkdir` - สร้างโฟลเดอร์
• `touch` - สร้างไฟล์ว่าง
• `rm` - ลบไฟล์/โฟลเดอร์
• `rmdir` - ลบโฟลเดอร์ว่าง

**📋 คัดลอกและย้าย:**
• `cp` - คัดลอกไฟล์/โฟลเดอร์
• `mv` - ย้าย/เปลี่ยนชื่อ
• `rsync` - ซิงค์ไฟล์

**👁️ ดูข้อมูล:**
• `ls` - แสดงรายการไฟล์
• `file` - ตรวจสอบประเภทไฟล์
• `du` - ดูขนาดการใช้งาน
• `df` - ดูพื้นที่ดิสก์

ลองถามเกี่ยวกับคำสั่งใดก็ได้เพื่อเรียนรู้รายละเอียด!
''',
type: MessageType.explanation,
category: 'file_management',
);
}

AIResponse _getNavigationCommands() {
return AIResponse(
text: '''
🧭 **คำสั่งการนำทางในระบบไฟล์**

**📍 ดูตำแหน่ง:**
• `pwd` - แสดงไดเรกทอรีปัจจุบัน
• `ls` - แสดงเนื้อหาในโฟลเดอร์
• `tree` - แสดงโครงสร้างแบบต้นไม้

**🚶 เดินทาง:**
• `cd` - เปลี่ยนไดเรกทอรี
• `cd ..` - ขึ้นไปโฟลเดอร์แม่
• `cd ~` - กลับ home directory
• `cd -` - กลับไดเรกทอรีก่อนหน้า

**🔍 สำรวจ:**
• `find` - ค้นหาไฟล์/โฟลเดอร์
• `locate` - ค้นหาอย่างรวดเร็ว
• `which` - หาตำแหน่งโปรแกรม

**💡 เคล็ดลับ:**
• ใช้ Tab เพื่อ auto-complete ชื่อไฟล์
• `..` = โฟลเดอร์แม่, `.` = โฟลเดอร์ปัจจุบัน
• `~` = home directory

ต้องการเรียนรู้คำสั่งไหนเป็นพิเศษครับ?
''',
type: MessageType.explanation,
category: 'navigation',
);
}

AIResponse _getSearchCommands() {
return AIResponse(
text: '''
🔍 **คำสั่งการค้นหาและกรองข้อมูล**

**🎯 ค้นหาไฟล์:**
• `find` - ค้นหาไฟล์ตามเงื่อนไข
• `locate` - ค้นหาอย่างรวดเร็วจากฐานข้อมูล
• `which` - หาตำแหน่งคำสั่ง/โปรแกรม
• `whereis` - หาไฟล์ binary และ manual

**📝 ค้นหาในข้อความ:**
• `grep` - ค้นหา pattern ในไฟล์
• `egrep` - grep แบบ extended regex
• `fgrep` - grep แบบ fixed string
• `rgrep` - grep แบบ recursive

**🔧 ตัวอย่างการใช้งาน:**
```bash
find . -name "*.txt"           # หา .txt ทั้งหมด
grep -r "error" /var/log       # หา error ใน log
locate filename                # หาไฟล์อย่างรวดเร็ว
```

**💡 Pro Tips:**
• ใช้ wildcards (*,?) ในการค้นหา
• ใช้ -i กับ grep เพื่อไม่สนใจตัวพิมพ์
• ใช้ pipe (|) เพื่อเชื่อมคำสั่ง

สนใจคำสั่งไหนเป็นพิเศษครับ?
''',
type: MessageType.explanation,
category: 'search',
);
}

AIResponse _getPermissionCommands() {
return AIResponse(
text: '''
🔐 **คำสั่งการจัดการสิทธิ์และความปลอดภัย**

**👤 เปลี่ยนเจ้าของ:**
• `chown` - เปลี่ยนเจ้าของไฟล์
• `chgrp` - เปลี่ยนกลุ่มของไฟล์
• `sudo` - รันคำสั่งด้วยสิทธิ์ admin

**🔧 จัดการสิทธิ์:**
• `chmod` - เปลี่ยนสิทธิ์การเข้าถึง
• `umask` - กำหนดสิทธิ์เริ่มต้น

**📊 ดูข้อมูลสิทธิ์:**
• `ls -l` - ดูสิทธิ์ไฟล์
• `id` - ดูข้อมูล user และ group
• `whoami` - ดูชื่อ user ปัจจุบัน

**🔢 รหัสสิทธิ์ที่ใช้บ่อย:**
• `755` = rwxr-xr-x (โปรแกรม)
• `644` = rw-r--r-- (ไฟล์ข้อมูล)
• `600` = rw------- (ไฟล์ส่วนตัว)
• `777` = rwxrwxrwx (อันตราย!)

**⚠️ คำเตือน:**
• ระวังใช้ sudo กับคำสั่งที่อันตราย
• ไม่ควรใช้ chmod 777 ยกเว้นกรณีพิเศษ
• ตรวจสอบสิทธิ์ก่อนเปลี่ยนแปลง

ต้องการเรียนรู้เรื่องสิทธิ์เพิ่มเติมไหมครับ?
''',
type: MessageType.explanation,
category: 'permissions',
);
}

AIResponse _getPersonalizedRecommendations(UserProfile profile) {
String response = '''
🎯 **แนะนำเฉพาะสำหรับ ${profile.name}**

**📊 สถานะปัจจุบัน:**
• ระดับ: ${profile.level.emoji} ${profile.level.displayName}
• คำสั่งที่รู้: ${profile.learnedCommands.length} คำสั่ง
• วันติดต่อกัน: ${profile.streakDays} วัน 🔥

''';

// แนะนำตามระดับ
if (profile.learnedCommands.length < 5) {
response += '''
**🌱 คำแนะนำสำหรับผู้เริ่มต้น:**
เริ่มต้นด้วยคำสั่งพื้นฐานก่อน:
• `pwd` - ดูตำแหน่งปัจจุบัน
• `ls` - ดูรายการไฟล์
• `cd` - เปลี่ยนโฟลเดอร์
• `mkdir` - สร้างโฟลเดอร์

**🎯 เป้าหมายระยะสั้น:** เรียนรู้ 5 คำสั่งพื้นฐาน
''';
} else if (profile.learnedCommands.length < 12) {
response += '''
**🌿 คำแนะนำสำหรับระดับกลาง:**
ขยายทักษะด้วยคำสั่งเหล่านี้:
• `grep` - ค้นหาข้อความ
• `find` - ค้นหาไฟล์
• `chmod` - จัดการสิทธิ์
• `ps` - ดูกระบวนการ

**🎯 เป้าหมายระยะสั้น:** เรียนรู้การจัดการระบบ
''';
} else {
response += '''
**🌳 คำแนะนำสำหรับระดับสูง:**
พัฒนาทักษะขั้นสูง:
• `awk` - ประมวลผลข้อความ
• `sed` - แก้ไขข้อความ
• `systemctl` - จัดการ services
• `crontab` - ตั้งเวลางาน

**🎯 เป้าหมายระยะยาว:** เรียนรู้ scripting และ automation
''';
}

// แนะนำตาม streak
if (profile.streakDays == 0) {
response += '\n💪 **เริ่มสร้างนิสัยการเรียนรู้:** เรียนอย่างน้อยวันละ 1 คำสั่ง';
} else if (profile.streakDays < 7) {
response += '\n🔥 **เก็บ!** เรียนต่อไปอีก ${7 - profile.streakDays} วันจะครบสัปดาห์';
} else {
response += '\n🏆 **สุดยอด!** คุณเรียนติดต่อกันมา ${profile.streakDays} วันแล้ว!';
}

// แนะนำเฉพาะตามความสนใจ
final mostUsedCategory = _getMostUsedCategory(profile);
if (mostUsedCategory != null) {
response += '\n\n🎯 **คุณสนใจเรื่อง ${mostUsedCategory.displayName}** ลองเรียนรู้คำสั่งขั้นสูงในหมวดนี้:';
final categoryCommands = _commandDb.getCommandsByCategory(mostUsedCategory);
final unlearned = categoryCommands.where((cmd) =>
!profile.learnedCommands.contains(cmd.name)
).take(3);
for (var cmd in unlearned) {
response += '\n• `${cmd.name}` - ${cmd.description}';
}
}

return AIResponse(
text: response,
type: MessageType.explanation,
category: 'recommendations',
);
}

CommandCategory? _getMostUsedCategory(UserProfile profile) {
final categoryCount = <CommandCategory, int>{};

for (final cmdName in profile.learnedCommands) {
final cmd = _commandDb.getCommand(cmdName);
if (cmd != null) {
categoryCount[cmd.category] = (categoryCount[cmd.category] ?? 0) + 1;
}
}

if (categoryCount.isEmpty) return null;

return categoryCount.entries
    .reduce((a, b) => a.value > b.value ? a : b)
    .key;
}

AIResponse _getLevelAssessment(UserProfile profile) {
final commandCount = profile.learnedCommands.length;
final exp = profile.experiencePoints;
final calculatedLevel = profile.calculatedLevel;

String assessment = '''
📊 **การประเมินระดับความสามารถ**

**🏅 ระดับปัจจุบัน:** ${profile.level.emoji} ${profile.level.displayName}
''';

if (calculatedLevel != profile.level) {
assessment += '''
**🎉 ยินดีด้วย!** คุณพร้อมเลื่อนระดับเป็น ${calculatedLevel.emoji} ${calculatedLevel.displayName}!

''';
}

assessment += '''
**📈 สถิติประสิทธิภาพ:**
• คำสั่งที่เรียนรู้: $commandCount คำสั่ง
• คะแนนประสบการณ์: $exp XP
• วันติดต่อกันในการเรียน: ${profile.streakDays} วัน
• ความสำเร็จที่ได้รับ: ${profile.achievements.length} รางวัล

**📋 การวิเคราะห์ทักษะ:**
${_getSkillAnalysis(profile)}

**🎯 แนะนำการพัฒนาต่อ:**
${_getNextStepRecommendations(profile)}
''';

return AIResponse(
text: assessment,
type: MessageType.explanation,
category: 'assessment',
);
}

String _getSkillAnalysis(UserProfile profile) {
final categories = CommandCategory.values;
final analysis = <String>[];

for (final category in categories) {
final categoryCommands = _commandDb.getCommandsByCategory(category);
final learnedInCategory = categoryCommands.where((cmd) =>
profile.learnedCommands.contains(cmd.name)
).length;

if (learnedInCategory > 0) {
final percentage = (learnedInCategory / categoryCommands.length * 100).round();
final level = _getCategoryLevel(percentage);
analysis.add('${category.emoji} ${category.displayName}: $level ($percentage%)');
}
}

return analysis.isEmpty ? 'ยังไม่มีข้อมูลการเรียนรู้' : analysis.take(5).join('\n');
}

String _getCategoryLevel(int percentage) {
if (percentage >= 80) return '🌟 เชี่ยวชาญ';
if (percentage >= 60) return '🔥 ดี';
if (percentage >= 40) return '⚡ ปานกลาง';
if (percentage >= 20) return '🌱 เริ่มต้น';
return '📚 ต้องพัฒนา';
}

String _getNextStepRecommendations(UserProfile profile) {
switch (profile.calculatedLevel) {
case UserLevel.beginner:
return '''
• เรียนรู้คำสั่งพื้นฐาน: pwd, ls, cd, mkdir
• ฝึกการนำทางในระบบไฟล์
• เริ่มต้นจัดการไฟล์อย่างง่าย''';

case UserLevel.intermediate:
return '''
• เรียนรู้การค้นหา: grep, find
• จัดการสิทธิ์ไฟล์: chmod, chown
• ศึกษาการใช้งาน pipe และ redirection''';

case UserLevel.advanced:
return '''
• เรียนรู้ text processing: awk, sed
• การจัดการ processes: ps, top, kill
• เริ่มเรียน shell scripting''';

case UserLevel.expert:
return '''
• พัฒนา automation scripts
• เรียนรู้ system administration
• แชร์ความรู้กับผู้อื่น''';
}
}

AIResponse _getCategoryOverview() {
return AIResponse(
text: '''
📚 **หมวดหมู่คำสั่ง Linux**

**🧭 การนำทาง (Navigation)**
• pwd, ls, cd, tree
• สำหรับเดินทางในระบบไฟล์

**📁 จัดการไฟล์ (File Management)**
• mkdir, cp, mv, rm, find
• สร้าง คัดลอก ย้าย ลบไฟล์

**📝 ประมวลผลข้อความ (Text Processing)**
• cat, grep, awk, sed, sort
• อ่าน ค้นหา แก้ไขข้อความ

**🔐 การจัดการสิทธิ์ (Permissions)**
• chmod, chown, sudo
• ควบคุมการเข้าถึงไฟล์

**⚙️ ผู้ดูแลระบบ (System Admin)**
• ps, top, systemctl, crontab
• จัดการระบบและกระบวนการ

**🌐 เครือข่าย (Networking)**
• ping, wget, curl, ssh
• การทำงานเกี่ยวกับเครือข่าย

**📦 บีบอัดไฟล์ (Archive)**
• tar, gzip, zip, unzip
• จัดการไฟล์บีบอัด

พิมพ์ชื่อหมวดหมู่หรือคำสั่งที่สนใจได้เลย!
''',
type: MessageType.explanation,
category: 'overview',
);
}

AIResponse _getGeneralResponse(UserProfile profile) {
final responses = [
'''
สวัสดีครับ ${profile.name}! 👋

คุณต้องการเรียนรู้คำสั่ง Linux เรื่องอะไรครับ?

💡 **ตัวอย่างคำถาม:**
• "ls คืออะไร" - เรียนรู้คำสั่งเฉพาะ
• "แนะนำคำสั่งพื้นฐาน" - รับคำแนะนำ
• "วิธีจัดการไฟล์" - เรียนตามหมวดหมู่
• "ทดสอบความรู้" - ทำแบบทดสอบ
''',
'''
มีอะไรให้ช่วยเหลือครับ? 🤖

ผมสามารถช่วยอธิบายคำสั่ง Linux ได้ครับ

🎯 **ลองถามเกี่ยวกับ:**
• คำสั่งที่สนใจ เช่น "grep", "chmod"
• การใช้งานเฉพาะ เช่น "ค้นหาไฟล์"
• แนะนำคำสั่งตามระดับ
''',
'''
พร้อมเรียนรู้ Linux กันแล้วหรือยัง? 🚀

📚 **ความรู้ที่ผมมี:**
• คำสั่งพื้นฐานถึงขั้นสูง
• เคล็ดลับการใช้งาน
• แบบทดสอบและแบบฝึกหัด
• การแนะนำเฉพาะบุคคล

ลองถามคำถามที่สนใจมาครับ!
''',
];

final selectedResponse = responses[_random.nextInt(responses.length)];

return AIResponse(
text: selectedResponse,
type: MessageType.text,
);
}

void _updateUserProgress(UserProfile profile, String command) {
profile.addLearnedCommand(command);
profile.incrementCommandUsage(command);
}

// Quiz handling methods
Future<AIResponse> handleQuizAnswer(String answer, QuizQuestion question, UserProfile profile) async {
// Parse answer (number or text)
int? selectedOption;

if (RegExp(r'^\d+import 'dart:math';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../models/linux_command.dart';

class AIService {
static final AIService _instance = AIService._internal();
factory AIService() => _instance;
AIService._internal();

final LinuxCommandDatabase _commandDb = LinuxCommandDatabase();
final Random _random = Random();

// Quiz questions database
final List<QuizQuestion> _quizQuestions = [
QuizQuestion(
id: 'q1',
question: 'คำสั่งใดใช้สำหรับแสดงรายการไฟล์ในไดเรกทอรี?',
options: ['ls', 'cd', 'pwd', 'mkdir'],
correctAnswer: 0,
explanation: 'ls (list) ใช้สำหรับแสดงรายการไฟล์และโฟลเดอร์ในไดเรกทอรี',
difficulty: CommandLevel.beginner,
relatedCommand: 'ls',
),
QuizQuestion(
id: 'q2',
question: 'คำสั่งใดใช้สำหรับเปลี่ยนไดเรกทอรี?',
options: ['ls', 'cd', 'pwd', 'mkdir'],
correctAnswer: 1,
explanation: 'cd (change directory) ใช้สำหรับเปลี่ยนไดเรกทอรีปัจจุบัน',
difficulty: CommandLevel.beginner,
relatedCommand: 'cd',
),
QuizQuestion(
id: 'q3',
question: 'option -r ใน rm มีความหมายว่าอย่างไร?',
options: ['read-only', 'recursive', 'reverse', 'restore'],
correctAnswer: 1,
explanation: '-r หมายถึง recursive คือลบไดเรกทอรีและไฟล์ข้างในทั้งหมด',
difficulty: CommandLevel.intermediate,
relatedCommand: 'rm',
),
QuizQuestion(
id: 'q4',
question: 'คำสั่งใดใช้สำหรับค้นหาข้อความในไฟล์?',).hasMatch(answer.trim())) {
selectedOption = int.tryParse(answer.trim());
if (selectedOption != null) selectedOption--; // Convert to 0-based index
} else {
// Try to match answer text
for (int i = 0; i < question.options.length; i++) {
if (question.options[i].toLowerCase() == answer.toLowerCase().trim()) {
selectedOption = i;
break;
}
}
}

if (selectedOption == null || selectedOption < 0 || selectedOption >= question.options.length) {
return AIResponse(
text: '''
❌ **คำตอบไม่ถูกต้อง**

กรุณาตอบด้วยหมายเลข 1-${question.options.length} หรือพิมพ์คำตอบที่ตรงกับตัวเลือก

**ตัวเลือก:**
${question.options.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}
''',
type: MessageType.error,
);
}

final isCorrect = selectedOption == question.correctAnswer;
final selectedAnswer = question.options[selectedOption];
final correctAnswer = question.options[question.correctAnswer];

// Update profile with quiz result
final quizResult = QuizResult(
id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
quizId: question.id,
title: 'คำถามเดี่ยว',
score: isCorrect ? 1 : 0,
totalQuestions: 1,
completedAt: DateTime.now(),
timeSpent: 60, // Assume 1 minute
difficulty: question.difficulty.name,
incorrectAnswers: isCorrect ? [] : [selectedAnswer],
);

profile.addQuizResult(quizResult);

String response;
MessageType responseType;

if (isCorrect) {
response = '''
✅ **ถูกต้อง! ยอดเยี่ยม!** 🎉

**คำตอบของคุณ:** $selectedAnswer

**💡 คำอธิบาย:** ${question.explanation}

**🎯 คะแนน:** +10 XP
**📊 สถิติ:** ตอบถูก ${profile.quizHistory.where((q) => q.passed).length}/${profile.quizHistory.length} ข้อ

พร้อมสำหรับคำถามต่อไปหรือยัง? พิมพ์ "ทดสอบต่อ" 🚀
''';
responseType = MessageType.success;

// Add experience points
profile.studyStats.totalStudyTime += 2; // 2 minutes for correct answer
} else {
response = '''
❌ **ไม่ถูกต้อง แต่ไม่เป็นไร!** 💪

**คำตอบของคุณ:** $selectedAnswer
**คำตอบที่ถูก:** $correctAnswer

**💡 คำอธิบาย:** ${question.explanation}

**📚 แนะนำ:** ${_getStudyRecommendation(question)}

ลองทำข้อต่อไปดู พิมพ์ "ทดสอบต่อ" 📖
''';
responseType = MessageType.warning;
}

return AIResponse(
text: response,
type: responseType,
category: 'quiz_result',
);
}

String _getStudyRecommendation(QuizQuestion question) {
if (question.relatedCommand != null) {
return 'ลองเรียนรู้คำสั่ง `${question.relatedCommand}` เพิ่มเติม';
}
return 'ศึกษาเพิ่มเติมเกี่ยวกับหัวข้อนี้';
}
}

// Helper class for AI responses
class AIResponse {
final String text;
final MessageType type;
final String? command;
final String? explanation;
final String? category;

AIResponse({
required this.text,
this.type = MessageType.text,
this.command,
this.explanation,
this.category,
});
}import 'dart:math';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../models/linux_command.dart';

class AIService {
static final AIService _instance = AIService._internal();
factory AIService() => _instance;
AIService._internal();

final LinuxCommandDatabase _commandDb = LinuxCommandDatabase();
final Random _random = Random();

// Quiz questions database
final List<QuizQuestion> _quizQuestions = [
QuizQuestion(
id: 'q1',
question: 'คำสั่งใดใช้สำหรับแสดงรายการไฟล์ในไดเรกทอรี?',
options: ['ls', 'cd', 'pwd', 'mkdir'],
correctAnswer: 0,
explanation: 'ls (list) ใช้สำหรับแสดงรายการไฟล์และโฟลเดอร์ในไดเรกทอรี',
difficulty: CommandLevel.beginner,
relatedCommand: 'ls',
),
QuizQuestion(
id: 'q2',
question: 'คำสั่งใดใช้สำหรับเปลี่ยนไดเรกทอรี?',
options: ['ls', 'cd', 'pwd', 'mkdir'],
correctAnswer: 1,
explanation: 'cd (change directory) ใช้สำหรับเปลี่ยนไดเรกทอรีปัจจุบัน',
difficulty: CommandLevel.beginner,
relatedCommand: 'cd',
),
QuizQuestion(
id: 'q3',
question: 'option -r ใน rm มีความหมายว่าอย่างไร?',
options: ['read-only', 'recursive', 'reverse', 'restore'],
correctAnswer: 1,
explanation: '-r หมายถึง recursive คือลบไดเรกทอรีและไฟล์ข้างในทั้งหมด',
difficulty: CommandLevel.intermediate,
relatedCommand: 'rm',
),
QuizQuestion(
id: 'q4',
question: 'คำสั่งใดใช้สำหรับค้นหาข้อความในไฟล์?',