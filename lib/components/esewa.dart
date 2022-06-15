import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Esewa extends StatefulWidget {
  final Map data;
  const Esewa(this.data);

  @override
  _EsewaState createState() => _EsewaState();
}

class _EsewaState extends State<Esewa> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  String esewaUI;
  Map data;
  String checkoutUrl;
  String message;
  String successURL = 'api/payment/success';
  String cancelURL = 'api/payment/failure';

  @override
  void initState() {
    super.initState();

    data = widget.data;

    esewaUI = '''<html>
      <head>
      <style>
        .loader {
            border: 5px solid #f3f3f3;
            -webkit-animation: spin 1s linear infinite;
            animation: spin 1s linear infinite;
            border-top: 5px solid #555;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            top: 30%;
            left: 40%;
            position: fixed;
        }
        /* Safari */
        @-webkit-keyframes spin {
          0% { -webkit-transform: rotate(0deg); }
          100% { -webkit-transform: rotate(360deg); }
        }
        
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      </style>
      </head>
      <body>
        <div class="loader"></div>
    
        <form action = "${data['url']}" id="myform" method="POST">
          <input value="${data['tAmt']}" name="tAmt" type="hidden">
          <input value="${data['amt']}" name="amt" type="hidden">
          <input value="${data['txAmt']}" name="txAmt" type="hidden">
          <input value="${data['psc']}" name="psc" type="hidden">
          <input value="${data['pdc']}" name="pdc" type="hidden">
          <input value="${data['scd']}" name="scd" type="hidden">
          <input value='${data['pid']}' name="pid" type="hidden">
          <input value="${data['su']}" type="hidden" name="su">
          <input value="${data['fu']}?pid=${data['payment_id']}" type="hidden" name="fu">
        </form>
      </body>
      <script>
            var form = document.getElementById("myform");
            form.submit();
      </script>
      </html>`;

    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: 'about:blank',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) async {
            final String contentBase64 =
                base64Encode(const Utf8Encoder().convert(esewaUI));
            await webViewController
                .loadUrl('data:text/html;base64,$contentBase64');
            _controller.complete(webViewController);
          },
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
          onPageStarted: (String url) {
            // print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            // print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
    );
  }
}
