class Video {
  int id;
  String title;
  String description;
  String videoFile;
  String thumbnail;
  String order;
  String createdAt;
  String updatedAt;

  Video({
    this.id,
    this.title,
    this.description,
    this.videoFile,
    this.thumbnail,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'] ?? '';
    videoFile = json['video_file'];
    thumbnail = json['thumbnail'];
    order = json['order'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
