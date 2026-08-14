class Advertisement {
  final int? id;
  final String? title;
  final String? imageFile;
  final String? url;
  final String? status;

  const Advertisement({
    this.id,
    this.title,
    this.imageFile,
    this.url,
    this.status,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as int?,
      title: json['title'] as String?,
      imageFile: json['image_file'] as String?,
      url: json['url'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_file': imageFile,
      'url': url,
      'status': status,
    };
  }
}