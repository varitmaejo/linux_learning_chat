import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import '../utils/themes.dart';

class MarkdownWidget extends StatelessWidget {
  final String data;
  final TextStyle? textStyle;
  final bool selectable;

  const MarkdownWidget({
    Key? key,
    required this.data,
    this.textStyle,
    this.selectable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildFormattedText(context);
  }

  Widget _buildFormattedText(BuildContext context) {
    final spans = <InlineSpan>[];
    final lines = data.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n'));
        continue;
      }

      // Handle headers
      if (line.startsWith('# ')) {
        spans.add(_buildHeaderSpan(context, line.substring(2), 1));
      } else if (line.startsWith('## ')) {
        spans.add(_buildHeaderSpan(context, line.substring(3), 2));
      } else if (line.startsWith('### ')) {
        spans.add(_buildHeaderSpan(context, line.substring(4), 3));
      }
      // Handle bold text **text**
      else if (line.contains('**')) {
        spans.addAll(_parseBoldText(context, line));
      }
      // Handle code blocks ```
      else if (line.startsWith('```')) {
        // Skip opening ```
        continue;
      }
      // Handle bullet points
      else if (line.startsWith('• ') || line.startsWith('- ')) {
        spans.add(_buildBulletSpan(context, line.substring(2)));
      }
      // Handle numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
        spans.add(_buildNumberedSpan(context, line));
      }
      // Handle inline code `code`
      else if (line.contains('`')) {
        spans.addAll(_parseInlineCode(context, line));
      }
      // Regular text
      else {
        spans.add(_buildTextSpan(context, line));
      }

      // Add line break if not last line
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    if (selectable) {
      return SelectableText.rich(
        TextSpan(children: spans),
        style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      );
    } else {
      return Text.rich(
        TextSpan(children: spans),
        style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      );
    }
  }

  TextSpan _buildHeaderSpan(BuildContext context, String text, int level) {
    TextStyle style;
    switch (level) {
      case 1:
        style = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ) ?? const TextStyle();
        break;
      case 2:
        style = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ) ?? const TextStyle();
        break;
      case 3:
        style = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ) ?? const TextStyle();
        break;
      default:
        style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ?? const TextStyle();
    }

    return TextSpan(
      text: text,
      style: style,
    );
  }

  List<InlineSpan> _parseBoldText(BuildContext context, String line) {
    final spans = <InlineSpan>[];
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(line)) {
      // Add text before bold
      if (match.start > lastIndex) {
        spans.add(_buildTextSpan(context, line.substring(lastIndex, match.start)));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < line.length) {
      spans.add(_buildTextSpan(context, line.substring(lastIndex)));
    }

    return spans;
  }

  List<InlineSpan> _parseInlineCode(BuildContext context, String line) {
    final spans = <InlineSpan>[];
    final codeRegex = RegExp(r'`([^`]+)`');
    int lastIndex = 0;

    for (final match in codeRegex.allMatches(line)) {
      // Add text before code
      if (match.start > lastIndex) {
        spans.add(_buildTextSpan(context, line.substring(lastIndex, match.start)));
      }

      // Add inline code
      spans.add(WidgetSpan(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.codeBackground.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            match.group(1) ?? '',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < line.length) {
      spans.add(_buildTextSpan(context, line.substring(lastIndex)));
    }

    return spans;
  }

  TextSpan _buildBulletSpan(BuildContext context, String text) {
    return TextSpan(
      children: [
        TextSpan(
          text: '• ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildTextSpan(context, text),
      ],
    );
  }

  TextSpan _buildNumberedSpan(BuildContext context, String text) {
    final match = RegExp(r'^(\d+\.\s)(.*)').firstMatch(text);
    if (match != null) {
      return TextSpan(
        children: [
          TextSpan(
            text: match.group(1),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildTextSpan(context, match.group(2) ?? ''),
        ],
      );
    }
    return _buildTextSpan(context, text);
  }

  TextSpan _buildTextSpan(BuildContext context, String text) {
    return TextSpan(
      text: text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }
}

// Widget for rendering code blocks
class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String? language;

  const CodeBlockWidget({
    Key? key,
    required this.code,
    this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppConstants.sm),
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Stack(
        children: [
          SelectableText(
            code.trim(),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (language != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      language!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: AppConstants.xs),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code.trim()));
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Rich text renderer for complex markdown
class RichTextRenderer {
  static List<Widget> renderMarkdown(BuildContext context, String markdown) {
    final widgets = <Widget>[];
    final lines = markdown.split('\n');
    List<String> codeBlockLines = [];
    bool inCodeBlock = false;
    String? codeLanguage;

    for (final line in lines) {
      if (line.startsWith('```')) {
        if (inCodeBlock) {
          // End of code block
          widgets.add(CodeBlockWidget(
            code: codeBlockLines.join('\n'),
            language: codeLanguage,
          ));
          codeBlockLines.clear();
          inCodeBlock = false;
          codeLanguage = null;
        } else {
          // Start of code block
          inCodeBlock = true;
          codeLanguage = line.substring(3).trim();
          if (codeLanguage?.isEmpty ?? true) codeLanguage = null;
        }
        continue;
      }

      if (inCodeBlock) {
        codeBlockLines.add(line);
        continue;
      }

      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: AppConstants.sm));
        continue;
      }

      // Handle special formatting
      if (line.startsWith('> ')) {
        widgets.add(_buildQuoteWidget(context, line.substring(2)));
      } else if (line.startsWith('---') || line.startsWith('***')) {
        widgets.add(_buildDividerWidget());
      } else {
        widgets.add(MarkdownWidget(data: line));
      }

      widgets.add(const SizedBox(height: AppConstants.xs));
    }

    return widgets;
  }

  static Widget _buildQuoteWidget(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.md),
      margin: const EdgeInsets.symmetric(vertical: AppConstants.sm),
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border(
          left: BorderSide(
            color: AppColors.infoBlue,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote,
            color: AppColors.infoBlue,
            size: 20,
          ),
          const SizedBox(width: AppConstants.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.infoBlue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDividerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.md),
      child: const Divider(
        color: AppColors.textSecondary,
        thickness: 1,
      ),
    );
  }
}