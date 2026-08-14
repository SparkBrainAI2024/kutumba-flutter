class Video {
  final int id;
  final String title;
  final String description;
  final String videoFile;
  final String thumbnail;
  final String order;
  final String createdAt;
  final String updatedAt;

  const Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoFile,
    required this.thumbnail,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoFile: json['video_file'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      order: json['order']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_file': videoFile,
      'thumbnail': thumbnail,
      'order': order,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}