import 'dart:core';
import 'package:flutter/material.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Paypal extends StatefulWidget {
  final Map data;
  Paypal(this.data);

  @override
  State<StatefulWidget> createState() {
    return PaypalState();
  }
}

class PaypalState extends State<Paypal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl;
  String message;
  String successURL = 'api/payment/success';
  String cancelURL = 'api/payment/failure';

  @override
  void initState() {
    super.initState();
    checkoutUrl = widget.data['paypal_checkout_redirect_url'];
  }

  @override
  Widget build(BuildContext context) {
    if (checkoutUrl != null) {
      return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).backgroundColor,
        //   leading: GestureDetector(
        //     child: Icon(Icons.arrow_back_ios),
        //     onTap: () => Navigator.pop(context),
        //   ),
        // ),
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: const HeaderLogo(),
          centerTitle: false,
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(successURL)) {
              final uri = Uri.parse(request.url);
              message = uri.queryParameters['msg'];

              Navigator.of(context).pop({
                'status': true,
                'message': message ?? 'Payment Successful!'
              });

              return NavigationDecision.prevent;
            }
            if (request.url.contains(cancelURL)) {
              final uri = Uri.parse(request.url);
              message = uri.queryParameters['msg'];

              Navigator.of(context).pop(
                  {'status': false, 'message': message ?? 'Payment Failed!'});

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: const HeaderLogo(),
          centerTitle: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
