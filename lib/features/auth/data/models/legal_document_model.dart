// lib/features/auth/data/models/legal_document_model.dart

import 'package:wap_app/features/auth/domain/entities/legal_document.dart';

class LegalDocumentModel {
  final String id;
  final String version;
  final String type;
  final String lang;
  final DateTime effectiveDate;
  final List<LegalSectionModel> sections;

  LegalDocumentModel({
    required this.id,
    required this.version,
    required this.type,
    required this.lang,
    required this.effectiveDate,
    required this.sections,
  });

  factory LegalDocumentModel.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List? ?? [];
    return LegalDocumentModel(
      id: json['id']?.toString() ?? '',
      version: json['version']?.toString() ?? '1.0',
      type: json['type']?.toString() ?? 'terms',
      lang: json['lang']?.toString() ?? 'es',
      effectiveDate: json['effective_date'] != null
          ? DateTime.parse(json['effective_date'] as String)
          : DateTime.now(),
      sections: sectionsJson
          .map(
            (item) => LegalSectionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  LegalDocument toEntity() {
    return LegalDocument(
      id: id,
      version: version,
      type: type,
      lang: lang,
      effectiveDate: effectiveDate,
      sections: sections.map((s) => s.toEntity()).toList(),
    );
  }
}

class LegalSectionModel {
  final String id;
  final String title;
  final String content;

  const LegalSectionModel({
    required this.id,
    required this.title,
    required this.content,
  });

  factory LegalSectionModel.fromJson(Map<String, dynamic> json) {
    return LegalSectionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }

  LegalSection toEntity() {
    return LegalSection(id: id, title: title, content: content);
  }
}
