import 'package:lexivo/core/entities/document.dart';

/// Presentation-friendly summary view backed by core [Document].
class SummaryView {
  const SummaryView({
    required this.documentId,
    required this.summaryStatus,
    this.title,
    this.shortSummary,
    this.detailedSummary,
  });

  factory SummaryView.fromDocument(Document document) {
    return SummaryView(
      documentId: document.id,
      summaryStatus: document.summaryStatus,
      title: document.title,
      shortSummary: document.shortSummary,
      detailedSummary: document.detailedSummary,
    );
  }

  final String documentId;
  final SummaryStatus summaryStatus;
  final String? title;
  final String? shortSummary;
  final String? detailedSummary;

  bool get hasSummaries {
    final short = shortSummary?.trim() ?? '';
    final detailed = detailedSummary?.trim() ?? '';
    return short.isNotEmpty && detailed.isNotEmpty;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummaryView &&
          documentId == other.documentId &&
          summaryStatus == other.summaryStatus &&
          title == other.title &&
          shortSummary == other.shortSummary &&
          detailedSummary == other.detailedSummary;

  @override
  int get hashCode => Object.hash(
        documentId,
        summaryStatus,
        title,
        shortSummary,
        detailedSummary,
      );
}
