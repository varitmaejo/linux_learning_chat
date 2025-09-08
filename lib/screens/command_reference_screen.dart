import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/themes.dart';
import '../models/linux_command.dart';

class CommandReferenceScreen extends StatefulWidget {
  const CommandReferenceScreen({Key? key}) : super(key: key);

  @override
  State<CommandReferenceScreen> createState() => _CommandReferenceScreenState();
}

class _CommandReferenceScreenState extends State<CommandReferenceScreen>
    with TickerProviderStateMixin {

  final LinuxCommandDatabase _commandDb = LinuxCommandDatabase();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  List<LinuxCommand> _filteredCommands = [];
  CommandCategory? _selectedCategory;
  CommandLevel? _selectedLevel;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCommands();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCommands() {
    setState(() {
      _filteredCommands = _commandDb.getAllCommands().values.toList();
      _filteredCommands.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterCommands();
    });
  }

  void _filterCommands() {
    var commands = _commandDb.getAllCommands().values.toList();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      commands = _commandDb.searchCommands(_searchQuery);
    }

    // Category filter
    if (_selectedCategory != null) {
      commands = commands.where((cmd) => cmd.category == _selectedCategory).toList();
    }

    // Level filter
    if (_selectedLevel != null) {
      commands = commands.where((cmd) => cmd.level == _selectedLevel).toList();
    }

    // Sort by popularity
    commands.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));

    setState(() {
      _filteredCommands = commands;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedLevel = null;
      _searchController.clear();
      _searchQuery = '';
    });
    _loadCommands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('คำสั่ง Linux'),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'ทั้งหมด', icon: Icon(Icons.list)),
            Tab(text: 'หมวดหมู่', icon: Icon(Icons.category)),
            Tab(text: 'ระดับ', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllCommandsTab(),
                _buildCategoriesTab(),
                _buildLevelsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหาคำสั่ง Linux...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              filled: true,
              fillColor: AppColors.inputBackground,
            ),
          ),

          // Filter chips
          if (_selectedCategory != null || _selectedLevel != null) ...[
            const SizedBox(height: AppConstants.sm),
            Row(
              children: [
                if (_selectedCategory != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppConstants.sm),
                    child: FilterChip(
                      label: Text(_selectedCategory!.displayName),
                      selected: true,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _filterCommands();
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                        _filterCommands();
                      },
                    ),
                  ),

                if (_selectedLevel != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppConstants.sm),
                    child: FilterChip(
                      label: Text(_selectedLevel!.displayName),
                      selected: true,
                      onSelected: (_) {
                        setState(() {
                          _selectedLevel = null;
                        });
                        _filterCommands();
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedLevel = null;
                        });
                        _filterCommands();
                      },
                    ),
                  ),

                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('ล้างตัวกรอง'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllCommandsTab() {
    if (_filteredCommands.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.md),
      itemCount: _filteredCommands.length,
      itemBuilder: (context, index) {
        final command = _filteredCommands[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 50),
              child: Opacity(
                opacity: value,
                child: _buildCommandCard(command),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    final categories = CommandCategory.values;

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppConstants.md,
        mainAxisSpacing: AppConstants.md,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final commandCount = _commandDb.getCommandsByCategory(category).length;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _buildCategoryCard(category, commandCount),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelsTab() {
    final levels = CommandLevel.values;

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.md),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final commands = _commandDb.getCommandsByLevel(level);

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 100)),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, (1 - value) * 30),
              child: Opacity(
                opacity: value,
                child: _buildLevelCard(level, commands),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.md),
          Text(
            'ไม่พบคำสั่งที่ค้นหา',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.sm),
          Text(
            'ลองใช้คำค้นหาอื่น หรือล้างตัวกรอง',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.lg),
          ElevatedButton(
            onPressed: _clearFilters,
            child: const Text('ล้างตัวกรอง'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(LinuxCommand command) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.sm),
      child: InkWell(
        onTap: () => _showCommandDetails(command),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Command name
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.sm,
                      vertical: AppConstants.xs,
                    ),
                    decoration: BoxDecoration(
                      color: command.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      command.name,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.sm),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: command.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          command.category.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          command.category.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: command.category.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Level indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: command.level.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          command.level.emoji,
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          command.level.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: command.level.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.sm),

              // Description
              Text(
                command.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppConstants.sm),

              // Syntax
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.sm),
                decoration: BoxDecoration(
                  color: AppColors.codeBackground.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        command.syntax,
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () => _copyToClipboard(command.syntax),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),

              // Examples preview
              if (command.examples.isNotEmpty) ...[
                const SizedBox(height: AppConstants.sm),
                Text(
                  'ตัวอย่าง: ${command.examples.first}',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CommandCategory category, int commandCount) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
            _tabController.animateTo(0);
          });
          _filterCommands();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withOpacity(0.1),
                category.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.sm),

              // Category name
              Text(
                category.displayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: category.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppConstants.xs),

              // Command count
              Text(
                '$commandCount คำสั่ง',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(CommandLevel level, List<LinuxCommand> commands) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.sm),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLevel = level;
            _tabController.animateTo(0);
          });
          _filterCommands();
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                level.color.withOpacity(0.1),
                level.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              // Level icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: level.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    level.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),

              const SizedBox(width: AppConstants.md),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: level.color,
                      ),
                    ),
                    const SizedBox(height: AppConstants.xs),
                    Text(
                      '${commands.length} คำสั่ง',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.xs),
                    // Popular commands in this level
                    if (commands.isNotEmpty)
                      Text(
                        commands.take(3).map((c) => c.name).join(', '),
                        style: const TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: level.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommandDetails(LinuxCommand command) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.lg),

                // Command header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.sm),
                      decoration: BoxDecoration(
                        color: command.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        command.category.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),

                    const SizedBox(width: AppConstants.md),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            command.name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            command.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.lg),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Syntax
                        _buildDetailSection(
                          'รูปแบบการใช้งาน',
                          Icons.code,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppConstants.md),
                            decoration: BoxDecoration(
                              color: AppColors.codeBackground,
                              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    command.syntax,
                                    style: const TextStyle(
                                      fontFamily: 'JetBrainsMono',
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: Colors.white70),
                                  onPressed: () => _copyToClipboard(command.syntax),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Examples
                        if (command.examples.isNotEmpty)
                          _buildDetailSection(
                            'ตัวอย่างการใช้งาน',
                            Icons.play_arrow,
                            Column(
                              children: command.examples.map((example) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: AppConstants.sm),
                                  padding: const EdgeInsets.all(AppConstants.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.commandHighlight,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          example,
                                          style: const TextStyle(
                                            fontFamily: 'JetBrainsMono',
                                            color: AppColors.primaryBlue,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 16),
                                        onPressed: () => _copyToClipboard(example),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Options
                        if (command.options.isNotEmpty)
                          _buildDetailSection(
                            'ตัวเลือกสำคัญ',
                            Icons.settings,
                            Column(
                              children: command.options.map((option) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: AppConstants.xs),
                                  padding: const EdgeInsets.all(AppConstants.sm),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                  ),
                                  child: Text(
                                    option,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Tips
                        if (command.tips.isNotEmpty)
                          _buildDetailSection(
                            'เคล็ดลับ',
                            Icons.lightbulb,
                            Column(
                              children: command.tips.map((tip) {
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: AppConstants.xs),
                                  padding: const EdgeInsets.all(AppConstants.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.tips_and_updates,
                                        size: 16,
                                        color: AppColors.successGreen,
                                      ),
                                      const SizedBox(width: AppConstants.sm),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.successGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        // Warning
                        if (command.warning != null)
                          _buildDetailSection(
                            'คำเตือน',
                            Icons.warning,
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppConstants.md),
                              decoration: BoxDecoration(
                                color: AppColors.warningOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                                border: Border.all(
                                  color: AppColors.warningOrange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: AppColors.warningOrange,
                                  ),
                                  const SizedBox(width: AppConstants.sm),
                                  Expanded(
                                    child: Text(
                                      command.warning!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.warningOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Related commands
                        if (command.relatedCommands.isNotEmpty)
                          _buildDetailSection(
                            'คำสั่งที่เกี่ยวข้อง',
                            Icons.link,
                            Wrap(
                              spacing: AppConstants.sm,
                              runSpacing: AppConstants.sm,
                              children: command.relatedCommands.map((relatedCmd) {
                                return ActionChip(
                                  label: Text(
                                    relatedCmd,
                                    style: const TextStyle(
                                      fontFamily: 'JetBrainsMono',
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    final relatedCommand = _commandDb.getCommand(relatedCmd);
                                    if (relatedCommand != null) {
                                      _showCommandDetails(relatedCommand);
                                    }
                                  },
                                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                  side: BorderSide(
                                    color: AppColors.primaryBlue.withOpacity(0.3),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: AppConstants.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: AppConstants.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.sm),
        content,
        const SizedBox(height: AppConstants.lg),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: AppConstants.sm),
            Text('คัดลอก "$text" แล้ว'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.successGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
      ),
    );
  }
}