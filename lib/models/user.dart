class User {
  String? userId;
  String? username;
  String? name;
  String? address;
  String? email;
  String? expiryDate;
  bool? expired;
  bool reminder;
  bool subscribed;
  String? token;
  String? expiresAt;

  User({
    this.userId,
    this.username,
    this.name,
    this.address,
    this.email,
    this.expiryDate,
    this.expired,
    this.reminder = false,
    this.subscribed = false,
    this.token,
    this.expiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      expiryDate: json['expiry_date']?.toString() ?? '',
      expired: _parseBool(json['expired']),
      reminder: _parseBool(json['reminder']),
      subscribed: _parseBool(json['subscribed']),
      token: json['api_token']?.toString() ?? '',
      expiresAt: json['expires_at']?.toString() ?? '',
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is int) {
      return value == 1;
    }

    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'username': username,
      'name': name,
      'address': address,
      'email': email,
      'expiry_date': expiryDate,
      'expired': expired,
      'reminder': reminder,
      'subscribed': subscribed,
      'api_token': token,
      'expires_at': expiresAt,
    };
  }
}