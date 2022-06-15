class Partner {
  int id;
  String title;
  String imageFile;
  String link;
  String order;
  String status;
  String createdAt;
  String updatedAt;

  Partner(
      {this.id,
      this.title,
      this.imageFile,
      this.link,
      this.order,
      this.status,
      this.createdAt,
      this.updatedAt});

  Partner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageFile = json['image_file'];
    link = json['link'];
    order = json['order'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
