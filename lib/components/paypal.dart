import 'package:flutter/material.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Paypal extends StatefulWidget {
  final Map data;

  const Paypal(this.data, {super.key});

  @override
  State<Paypal> createState() => PaypalState();
}

class PaypalState extends State<Paypal> {
  late final WebViewController _controller;

  String? checkoutUrl;

  final String successURL = 'api/payment/success';
  final String cancelURL = 'api/payment/failure';

  bool _isLoading = true;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();

    checkoutUrl = widget.data['paypal_checkout_redirect_url']?.toString();

    if (checkoutUrl != null && checkoutUrl!.isNotEmpty) {
      _initializeWebView();
    }
  }

  void _initializeWebView() {
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
              'PayPal WebView error: '
                  '${error.errorCode} - ${error.description}',
            );

            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(
        Uri.parse(checkoutUrl!),
      );
  }

  NavigationDecision _handleNavigationRequest(
      NavigationRequest request,
      ) {
    final String url = request.url;

    debugPrint('PayPal navigation URL: $url');

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
    if (checkoutUrl == null || checkoutUrl!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: const HeaderLogo(),
          centerTitle: false,
        ),
        body: const Center(
          child: Text('Unable to initialize PayPal payment.'),
        ),
      );
    }

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