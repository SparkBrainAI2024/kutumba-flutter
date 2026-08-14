class Note {
  final int id;
  final String title;
  final String filePath;
  final String description;

  const Note({
    required this.id,
    required this.title,
    required this.filePath,
    required this.description,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      filePath: json['file_path'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file_path': filePath,
      'description': description,
    };
  }
}