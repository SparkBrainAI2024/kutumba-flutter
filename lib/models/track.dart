class Track {
  final int id;
  final String title;
  final String albumId;
  final String genre;
  final String order;
  final String description;
  final String musicFile;
  final String musicUrl;

  const Track({
    required this.id,
    required this.title,
    required this.albumId,
    required this.genre,
    required this.order,
    required this.description,
    required this.musicFile,
    required this.musicUrl,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      albumId: json['album_id']?.toString() ?? '',
      genre: json['genre'] ?? '',
      order: json['order']?.toString() ?? '',
      description: json['description'] ?? '',
      musicFile: json['music_file'] ?? '',
      musicUrl: json['music_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album_id': albumId,
      'genre': genre,
      'order': order,
      'description': description,
      'music_file': musicFile,
      'music_url': musicUrl,
    };
  }
}