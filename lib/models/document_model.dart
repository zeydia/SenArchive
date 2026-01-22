
class DocumentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String fileUrl;
  final String? userId;
  final DateTime? createdAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileUrl,
    this.userId,
    this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    category: (json['category'] ?? 'Général').toString(),
    fileUrl: (json['file_url'] ?? '').toString(),
    userId: json['user_id']?.toString(),
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'file_url': fileUrl,
    'user_id': userId,
  };
}
