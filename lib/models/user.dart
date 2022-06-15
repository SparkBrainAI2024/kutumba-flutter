class User {
  String userId;
  String username;
  String name;
  String address;
  String email;
  String expiryDate;
  bool expired;
  bool reminder;
  bool subscribed;
  String token;
  String expiresAt;

  User(
      {this.userId,
      this.username,
      this.name,
      this.email,
      this.address,
      this.expiryDate,
      this.expired,
      this.reminder,
      this.subscribed,
      this.token,
      this.expiresAt});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        userId: responseData['id'],
        username: responseData['username'],
        name: responseData['name'],
        email: responseData['email'],
        address: responseData['address'],
        expiryDate: responseData['expiry_date'],
        expired: responseData['expired'] == 1,
        reminder: responseData['reminder'] == 1,
        subscribed: responseData['subscribed'] == 1,
        token: responseData['api_token'],
        expiresAt: responseData['expires_at']);
  }
}
