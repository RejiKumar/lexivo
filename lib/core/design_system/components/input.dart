import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Text field style.
enum LexivoTextFieldVariant { text, multiline, search }

/// Lexivo text field — auth, search, and chat input base.
class LexivoTextField extends StatefulWidget {
  const LexivoTextField({
    super.key,
    this.variant = LexivoTextFieldVariant.text,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final LexivoTextFieldVariant variant;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  bool get hasError => errorText != null && errorText!.isNotEmpty;

  @override
  State<LexivoTextField> createState() => _LexivoTextFieldState();
}

class _LexivoTextFieldState extends State<LexivoTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocus);
    _controller.addListener(_handleText);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _controller.removeListener(_handleText);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _handleText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final isMultiline = widget.variant == LexivoTextFieldVariant.multiline;
    final isSearch = widget.variant == LexivoTextFieldVariant.search;

    Color borderColor;
    if (!widget.enabled) {
      borderColor = colors.borderDefault;
    } else if (widget.hasError) {
      borderColor = colors.feedbackDanger;
    } else if (_focused) {
      borderColor = colors.borderFocus;
    } else {
      borderColor = colors.borderDefault;
    }

    final field = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: isMultiline ? null : 1,
        minLines: isMultiline ? 3 : 1,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: LexivoTypography.body.copyWith(
          color: widget.enabled ? colors.contentPrimary : colors.contentDisabled,
        ),
        cursorColor: colors.brandPrimary,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          hintStyle: LexivoTypography.body.copyWith(
            color: colors.contentSecondary,
          ),
          filled: true,
          fillColor: colors.backgroundSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LexivoSpacing.md,
            vertical: LexivoSpacing.sm,
          ),
          prefixIcon: isSearch
              ? Icon(Icons.search, color: colors.contentSecondary, size: 20)
              : null,
          suffixIcon: isSearch && _controller.text.isNotEmpty && widget.enabled
              ? IconButton(
                  tooltip: 'Clear',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                    widget.onClear?.call();
                  },
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: colors.contentSecondary,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LexivoRadius.md),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LexivoRadius.md),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LexivoRadius.md),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LexivoRadius.md),
            borderSide: BorderSide(color: colors.borderDefault),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LexivoRadius.md),
            borderSide: BorderSide(color: colors.feedbackDanger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LexivoRadius.md),
            borderSide: BorderSide(color: colors.feedbackDanger, width: 1.5),
          ),
          errorText: null,
        ),
      ),
    );

    final helperOrError = widget.hasError
        ? widget.errorText!
        : (widget.helperText ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: LexivoTypography.label.copyWith(
              color: widget.enabled
                  ? colors.contentPrimary
                  : colors.contentDisabled,
            ),
          ),
          const SizedBox(height: LexivoSpacing.xxs),
        ],
        field,
        if (helperOrError.isNotEmpty) ...[
          const SizedBox(height: LexivoSpacing.xxs),
          Text(
            helperOrError,
            style: LexivoTypography.caption.copyWith(
              color: widget.hasError
                  ? colors.feedbackDanger
                  : colors.contentSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
