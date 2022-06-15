import 'package:kutumba/models/track.dart';

class Album {
  int id;
  String name;
  String releaseDate;
  String distributorName;
  String artist;
  String totalTime;
  String label;
  String order;
  String description;
  String coverPhoto;
  String createdAt;
  String updatedAt;
  int trackCount;
  List<Track> track;

  Album(
      {this.id,
      this.name,
      this.releaseDate,
      this.distributorName,
      this.artist,
      this.totalTime,
      this.label,
      this.order,
      this.description,
      this.coverPhoto,
      this.createdAt,
      this.updatedAt,
      this.trackCount});

  Album.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    releaseDate = json['release_date'];
    distributorName = json['distributor_name'];
    artist = json['artist'] ?? '';
    totalTime = json['total_time'] ?? '';
    label = json['label'] ?? '';
    order = json['order'];
    description = json['description'];
    coverPhoto = json['cover_photo'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    trackCount = json['track'];
    // if (json['track'] != null) {
    //   track = List<Track>.from(json['track'].map((model)=> Track.fromJson(model)));
    // }
  }
}
