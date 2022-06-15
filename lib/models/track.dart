class Track {
  int id;
  String title;
  String albumId;
  String genre;
  String order;
  String description;
  String musicFile;
  String musicUrl;

  Track({
    this.id,
    this.title,
    this.albumId,
    this.genre,
    this.order,
    this.description,
    this.musicFile,
    this.musicUrl,
  });

  Track.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    albumId = json['album_id'];
    genre = json['genre'];
    order = json['order'];
    description = json['description'];
    musicFile = json['music_file'];
    musicUrl = json['music_url'];
  }
}
