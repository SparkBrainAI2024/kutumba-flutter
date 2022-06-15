class Advertisement {
  int id;
  String title;
  String imageFile;
  String url;
  String status;

  Advertisement({
    this.id,
    this.title,
    this.imageFile,
    this.url,
    this.status,
  });

  Advertisement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageFile = json['image_file'];
    url = json['url'];
    status = json['status'];
  }
}
