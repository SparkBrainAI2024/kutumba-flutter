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

  Album({
    this.id = 0,
    this.name = '',
    this.releaseDate = '',
    this.distributorName = '',
    this.artist = '',
    this.totalTime = '',
    this.label = '',
    this.order = '',
    this.description = '',
    this.coverPhoto = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.trackCount = 0,
    List<Track>? track,
  }) : track = track ?? [];

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      distributorName: json['distributor_name']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      totalTime: json['total_time']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      order: json['order']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverPhoto: json['cover_photo']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      trackCount: _parseInt(json['track_count'] ?? json['track']),
      track: _parseTracks(json['track']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'release_date': releaseDate,
      'distributor_name': distributorName,
      'artist': artist,
      'total_time': totalTime,
      'label': label,
      'order': order,
      'description': description,
      'cover_photo': coverPhoto,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'track_count': trackCount,
      'track': track.map((item) => item.toJson()).toList(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static List<Track> _parseTracks(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => Track.fromJson(item))
        .toList();
  }
}