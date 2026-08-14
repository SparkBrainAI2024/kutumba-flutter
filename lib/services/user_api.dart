import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:kutumba/models/user.dart';
import 'package:kutumba/services/push_nofitications.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/user_preferences.dart';

class UserService {
  Future checkPaymentStatus() async {
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.checkPaymentStatus);

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token!
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message']
        };
      } else {
        result = {
          'status': false,
          'data': responseData['response'],
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future fetchProfile() async {
    User user;
    String? token = await UserPreferences().getToken();
    if (token == null) {
      return {
        'status': false,
        'message': 'Token not found',
      };
    }

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.profile);

    return await get(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token!
    }).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        user = User.fromJson(responseData['response']);
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': user
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future editProfile(String name, String address) async {
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.editProfile);

    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
    };

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token!
      },
      body: json.encode(data),
    ).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // await UserPreferences().saveData('username', name);

        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message']
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future changePassword(String prevPsw, String newPsw) async {
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.changePassword);

    final Map<String, dynamic> data = {
      'prev_psw': prevPsw,
      'new_psw': newPsw,
    };

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token!
      },
      body: json.encode(data),
    ).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message']
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future addCommentInVideo(int videoId, String comment) async {
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.videoComment);

    final Map<String, dynamic> data = {
      'video_id': videoId,
      'comment': comment,
    };

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token!
      },
      body: json.encode(data),
    ).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message']
        };
      } else {
        result = {
          'status': false,
          'statusCode': response.statusCode,
          'message': responseData['message']
        };
      }
      return result;
    }).catchError(onError);
  }

  Future subscribe(String token) async {
    String fcmToken = await PushNotificationsManager().getToken();

    Map<String, bool> result;
    var url = Uri.parse(AppUrl.fcmSubscribe);

    final Map<String, dynamic> data = {'firebase_token': fcmToken};

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data),
    ).then((Response response) async {
      // final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        result = {
          'status': true,
        };
      } else {
        result = {'status': false};
      }
      return result;
    }).catchError(onError);
  }

  Future unsubscribe() async {
    // String token = await UserPreferences().getToken();
    String fcmToken = await PushNotificationsManager().getToken();

    Map<String, bool> result;
    var url = Uri.parse(AppUrl.fcmUnsubscribe);

    final Map<String, dynamic> data = {'firebase_token': fcmToken};

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization': 'Bearer '+ token
      },
      body: json.encode(data),
    ).then((Response response) async {
      if (response.statusCode == 200) {
        result = {
          'status': true,
        };
      } else {
        result = {
          'status': false,
        };
      }
      return result;
    }).catchError(onError);
  }

  static onError(error) {
    // print("the error is $error.detail");
    return {'status': false, 'message': 'Something went wrong!', 'data': error};
  }
}
