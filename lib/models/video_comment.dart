class VideoComment {
  int id;
  String name;
  String videoId;
  String comment;
  String createdAt;

  VideoComment({
    this.id,
    this.name,
    this.videoId,
    this.comment,
    this.createdAt,
  });

  VideoComment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    videoId = json['video_id'];
    comment = json['comment'];
    createdAt = json['created_at'];
  }
}
