class Artist {
  final String firstName;
  final String name;
  final String photo;
  final String specialization;
  final String about;
  final String sliderText;

  const Artist({
    required this.firstName,
    required this.name,
    required this.photo,
    required this.specialization,
    required this.about,
    required this.sliderText,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      firstName: json['first_name'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
      specialization: json['specialization'] ?? '',
      about: json['about'] ?? '',
      sliderText: json['slider_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'name': name,
      'photo': photo,
      'specialization': specialization,
      'about': about,
      'slider_text': sliderText,
    };
  }
}