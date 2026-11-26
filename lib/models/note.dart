class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  int colorIndex; // 0..5 soft pastel indices
  bool pinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    DateTime? updatedAt,
    this.colorIndex = 0,
    this.pinned = false,
  }) : updatedAt = updatedAt ?? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'colorIndex': colorIndex,
        'pinned': pinned,
      };

  factory Note.fromJson(Map<String, dynamic> j) => Note(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        content: j['content'] as String? ?? '',
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: j['updatedAt'] != null
            ? DateTime.parse(j['updatedAt'] as String)
            : DateTime.parse(j['createdAt'] as String),
        colorIndex: j['colorIndex'] as int? ?? 0,
        pinned: j['pinned'] as bool? ?? false,
      );
}
