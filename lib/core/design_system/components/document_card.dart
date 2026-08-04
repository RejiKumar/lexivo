import 'package:flutter/material.dart';

import '../tokens/color.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'badge.dart';
import 'card.dart';

/// Document processing status for [LexivoDocumentCard] — display-only.
enum LexivoDocumentStatus { processing, ready, failed }

/// Document list/grid card composing [LexivoCard] + [LexivoBadge].
class LexivoDocumentCard extends StatelessWidget {
  const LexivoDocumentCard({
    super.key,
    required this.name,
    required this.status,
    required this.timestamp,
    this.thumbnail,
    this.onTap,
  });

  final String name;
  final LexivoDocumentStatus status;
  final String timestamp;

  /// Optional thumbnail; falls back to a document icon when null.
  final Widget? thumbnail;
  final VoidCallback? onTap;

  (String, LexivoBadgeVariant) get _badge {
    switch (status) {
      case LexivoDocumentStatus.processing:
        return ('Processing', LexivoBadgeVariant.warning);
      case LexivoDocumentStatus.ready:
        return ('Ready', LexivoBadgeVariant.success);
      case LexivoDocumentStatus.failed:
        return ('Failed', LexivoBadgeVariant.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LexivoColors>()!;
    final (label, badgeVariant) = _badge;

    return LexivoCard(
      variant: onTap != null
          ? LexivoCardVariant.interactive
          : LexivoCardVariant.elevated,
      onTap: onTap,
      padding: const EdgeInsets.all(LexivoSpacing.sm),
      child: Row(
        children: [
          _Thumbnail(thumbnail: thumbnail, colors: colors),
          const SizedBox(width: LexivoSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LexivoTypography.bodyStrong.copyWith(
                    color: colors.contentPrimary,
                  ),
                ),
                const SizedBox(height: LexivoSpacing.xxs),
                Text(
                  timestamp,
                  style: LexivoTypography.caption.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: LexivoSpacing.sm),
          LexivoBadge(label: label, variant: badgeVariant),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.thumbnail, required this.colors});

  final Widget? thumbnail;
  final LexivoColors colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(LexivoRadius.sm),
      child: SizedBox(
        width: 48,
        height: 48,
        child: thumbnail ??
            ColoredBox(
              color: colors.backgroundDefault,
              child: Icon(
                Icons.description_outlined,
                color: colors.contentSecondary,
              ),
            ),
      ),
    );
  }
}
