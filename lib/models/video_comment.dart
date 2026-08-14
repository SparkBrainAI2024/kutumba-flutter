class VideoComment {
  final int id;
  final String name;
  final String videoId;
  final String comment;
  final String createdAt;

  const VideoComment({
    required this.id,
    required this.name,
    required this.videoId,
    required this.comment,
    required this.createdAt,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      videoId: json['video_id']?.toString() ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'video_id': videoId,
      'comment': comment,
      'created_at': createdAt,
    };
  }
}