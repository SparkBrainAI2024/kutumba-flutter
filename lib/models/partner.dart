class Partner {
  final int id;
  final String title;
  final String imageFile;
  final String link;
  final String order;
  final String status;
  final String createdAt;
  final String updatedAt;

  const Partner({
    required this.id,
    required this.title,
    required this.imageFile,
    required this.link,
    required this.order,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageFile: json['image_file'] ?? '',
      link: json['link'] ?? '',
      order: json['order']?.toString() ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_file': imageFile,
      'link': link,
      'order': order,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}