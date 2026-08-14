import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Esewa extends StatefulWidget {
  final Map data;

  const Esewa(this.data, {super.key});

  @override
  State<Esewa> createState() => _EsewaState();
}

class _EsewaState extends State<Esewa> {
  late final WebViewController _controller;

  late final Map data;

  bool _isLoading = true;
  bool _hasCompleted = false;

  final String successURL = 'api/payment/success';
  final String cancelURL = 'api/payment/failure';

  @override
  void initState() {
    super.initState();

    data = widget.data;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigationRequest,
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              'eSewa WebView error: '
                  '${error.errorCode} - ${error.description}',
            );

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );

    _loadEsewaPage();
  }

  Future<void> _loadEsewaPage() async {
    final String html = _buildEsewaHtml();

    final String contentBase64 = base64Encode(
      utf8.encode(html),
    );

    await _controller.loadRequest(
      Uri.parse('data:text/html;base64,$contentBase64'),
    );
  }

  String _buildEsewaHtml() {
    final String url = _escapeHtml(data['url']);
    final String tAmt = _escapeHtml(data['tAmt']);
    final String amt = _escapeHtml(data['amt']);
    final String txAmt = _escapeHtml(data['txAmt']);
    final String psc = _escapeHtml(data['psc']);
    final String pdc = _escapeHtml(data['pdc']);
    final String scd = _escapeHtml(data['scd']);
    final String pid = _escapeHtml(data['pid']);
    final String su = _escapeHtml(data['su']);

    final String fu = _escapeHtml(
      '${data['fu']}?pid=${Uri.encodeComponent('${data['payment_id']}')}',
    );

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">

  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background: #ffffff;
    }

    .loader {
      border: 5px solid #f3f3f3;
      border-top: 5px solid #555555;
      border-radius: 50%;
      width: 50px;
      height: 50px;
      position: fixed;
      top: 40%;
      left: 50%;
      margin-left: -25px;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% {
        transform: rotate(0deg);
      }

      100% {
        transform: rotate(360deg);
      }
    }
  </style>
</head>

<body>
  <div class="loader"></div>

  <form
    action="$url"
    id="myform"
    method="POST"
  >
    <input value="$tAmt" name="tAmt" type="hidden">
    <input value="$amt" name="amt" type="hidden">
    <input value="$txAmt" name="txAmt" type="hidden">
    <input value="$psc" name="psc" type="hidden">
    <input value="$pdc" name="pdc" type="hidden">
    <input value="$scd" name="scd" type="hidden">
    <input value="$pid" name="pid" type="hidden">
    <input value="$su" name="su" type="hidden">
    <input value="$fu" name="fu" type="hidden">
  </form>

  <script>
    document.getElementById("myform").submit();
  </script>
</body>
</html>
''';
  }

  String _escapeHtml(dynamic value) {
    if (value == null) {
      return '';
    }

    return const HtmlEscape().convert(value.toString());
  }

  NavigationDecision _handleNavigationRequest(
      NavigationRequest request,
      ) {
    final String url = request.url;

    debugPrint('eSewa navigation URL: $url');

    if (_hasCompleted) {
      return NavigationDecision.prevent;
    }

    if (url.contains(successURL)) {
      _handlePaymentResult(
        success: true,
        url: url,
      );

      return NavigationDecision.prevent;
    }

    if (url.contains(cancelURL)) {
      _handlePaymentResult(
        success: false,
        url: url,
      );

      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _handlePaymentResult({
    required bool success,
    required String url,
  }) {
    if (_hasCompleted || !mounted) {
      return;
    }

    _hasCompleted = true;

    final Uri? uri = Uri.tryParse(url);

    final String? message = uri?.queryParameters['msg'];

    Navigator.of(context).pop({
      'status': success,
      'message': message ??
          (success ? 'Payment Successful!' : 'Payment Failed!'),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}