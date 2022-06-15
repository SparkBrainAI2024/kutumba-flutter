class AppUrl {
  static const String baseURL = "https://www.kutumba8.com/";

  static const String home = baseURL + "api/homepage";
  static const String checkVersion = baseURL + "api/version";

  static const String login = baseURL + "api/customer/login?device_type=ios";
  static const String register = baseURL + "api/customer/signup";
  static const String forgotPassword =
      baseURL + "api/customer/password_reset_link";
  static const String logout = baseURL + "api/customer/logout";

  static const String albumList = baseURL + "api/album/list";
  static const String trackList = baseURL + "api/track/list";
  static const String partnerList = baseURL + "api/partner/list";
  static const String noteList = baseURL + "api/note/list";
  static const String advertisementList = baseURL + "api/advertisement/list";

  static const String videoList = baseURL + "api/video/list";
  static const String videoCommentList = baseURL + "api/video/comment-list";
  static const String videoComment = baseURL + "api/video/comment";

  static const String profile = baseURL + "api/customer/profile";
  static const String editProfile = baseURL + "api/customer/update_profile";
  static const String changePassword = baseURL + "api/customer/change_password";
  static const String checkPaymentStatus = baseURL + "api/check-payment-status";

  static const String createBill = baseURL + "api/create_bill";
  static const String initiatePayment = baseURL + "api/payment/initiate";

  static const String refresh = baseURL + "api/refresh";
  static const String refreshToken = baseURL + "api/refresh-token";
  static const String fcmSubscribe = baseURL + "api/add-customer-token";
  static const String fcmUnsubscribe = baseURL + "api/remove-customer-token";
}
