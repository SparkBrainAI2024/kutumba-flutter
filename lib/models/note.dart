class Note {
  int id;
  String title;
  String filePath;
  String description;

  Note({
    this.id,
    this.title,
    this.filePath,
    this.description,
  });

  Note.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    filePath = json['file_path'];
    description = json['description'];
  }
}
