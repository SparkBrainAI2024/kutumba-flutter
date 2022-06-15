class Artist {
  String firstName;
  String name;
  String photo;
  String specialization;
  String about;
  String sliderText;

  Artist(
      {this.firstName,
      this.name,
      this.photo,
      this.specialization,
      this.about,
      this.sliderText});

  Artist.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    photo = json['photo'];
    specialization = json['specialization'];
    about = json['about'];
    sliderText = json['slider_text'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['photo'] = photo;
    data['specialization'] = specialization;
    data['about'] = about;
    data['slider_text'] = sliderText;
    data['name'] = name;
    return data;
  }
}
