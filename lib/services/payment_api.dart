import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:kutumba/utils/app_url.dart';
import 'package:kutumba/utils/user_preferences.dart';

class PaymentService {
  Future createBill(String gateway, String type) async {
    String? token = await UserPreferences().getToken();

    Map<String, dynamic> result;
    var url = Uri.parse(AppUrl.createBill);

    final Map<String, dynamic> data = {'gateway': gateway, 'type': type};

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
        return await initiatePayment(
            gateway, responseData['response']['payment_id'].toString(), token);
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

  Future initiatePayment(String gateway, String paymentId, String token) async {
    Map<String, dynamic> result;

    final Map<String, dynamic> data = {
      'gateway': gateway,
      'payment_id': paymentId,
    };
    var url = Uri.parse(AppUrl.initiatePayment);

    return await post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode(data),
    ).then((Response response) async {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        Map data = responseData['response'];
        data['payment_id'] = paymentId;

        result = {
          'status':
              (responseData['status'] == '1' || responseData['status'] == 1),
          'message': responseData['message'],
          'data': data
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

  static onError(error) {
    // print("the error is $error.detail");
    return {'status': false, 'message': 'Something went wrong!', 'data': error};
  }
}
