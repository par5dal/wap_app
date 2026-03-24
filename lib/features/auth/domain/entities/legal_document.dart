// lib/features/auth/domain/entities/legal_document.dart

class LegalDocument {
  final String id;
  final String version;
  final String type; // "terms" | "privacy"
  final String lang;
  final DateTime effectiveDate;
  final List<LegalSection> sections;

  const LegalDocument({
    required this.id,
    required this.version,
    required this.type,
    required this.lang,
    required this.effectiveDate,
    required this.sections,
  });
}

class LegalSection {
  final String id;
  final String title;
  final String content; // Markdown formatted

  const LegalSection({
    required this.id,
    required this.title,
    required this.content,
  });
}
