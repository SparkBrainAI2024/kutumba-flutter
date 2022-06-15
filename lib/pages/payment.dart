import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/esewa.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/components/paypal.dart';
import 'package:kutumba/main_drawer.dart';
import 'package:kutumba/services/payment_api.dart';
import 'package:kutumba/utils/refresh_token.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

const String _kMonthlySubscriptionId =
    'Asteriskhubs.Kutumba.subscription.monthly';
const List<String> _kProductIds = <String>[
  _kMonthlySubscriptionId,
];

class Payment extends StatefulWidget {
  final String type;
  final bool hasBackBtn;
  final String redirectPage;

  Payment(this.type, {this.hasBackBtn = false, this.redirectPage = '/albums'});

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  PaymentService _api = PaymentService();
  String _gateway;
  bool loading = false;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        Alert.successSnackbar(context, "pending",
            duration: const Duration(milliseconds: 500));
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          Alert.successSnackbar(context, "error",
              duration: const Duration(milliseconds: 500));
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          Alert.successSnackbar(context, "purchased",
              duration: const Duration(milliseconds: 500));
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            print(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          Alert.successSnackbar(context, "pending complete purchase");
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      endDrawer: widget.hasBackBtn ? null : const MainDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const HeaderLogo(),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Container(
            height: 800,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: const DecorationImage(
                image: AssetImage("assets/images/kutumba8.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(25.0),
                  //   child: Text(
                  //     "Welcome! Please provide payment Information.",
                  //     textAlign: TextAlign.center,
                  //     style: TextStyle(
                  //         color: Color.fromARGB(255, 248, 152, 29),
                  //         fontSize: 19,
                  //         fontWeight: FontWeight.w600),
                  //   ),
                  // ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Welcome to Kutumba’s digital music archive! All our albums are online. We would like to share our decades of hard work and more to come, on this platform. Stay connected!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      const Text(
                        "Contact maharjanpavit002@gmail.com if you are face any issues  once logged in.",
                        style: TextStyle(
                            color: Color.fromARGB(255, 248, 152, 29),
                            fontSize: 19,
                            fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                          onPressed: () => {
                                if (_products.isNotEmpty)
                                  {
                                    _inAppPurchase.buyNonConsumable(
                                      purchaseParam: PurchaseParam(
                                          productDetails: _products.first),
                                    )
                                  }
                              },
                          child: const Text('Subscribe'))
                      // SizedBox(height:20,),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         Radio(
                      //           focusColor: Color.fromARGB(255, 248, 152, 29),
                      //           activeColor: Color.fromARGB(255, 248, 152, 29),
                      //           value: "paypal",
                      //           groupValue: _gateway,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               _gateway = value;
                      //             });
                      //           },
                      //         ),
                      //         GestureDetector(
                      //           child: Image.asset("assets/images/paypal.png"),
                      //           onTap: (){
                      //             setState(() {
                      //               _gateway = 'paypal';
                      //             });
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //     Row(
                      //       children: [
                      //         Radio(
                      //           focusColor: Color.fromARGB(255, 248, 152, 29),
                      //           activeColor: Color.fromARGB(255, 248, 152, 29),
                      //           value: "esewa",
                      //           groupValue: _gateway,
                      //           onChanged: (value) {
                      //             setState(() {
                      //               _gateway = value;
                      //             });
                      //           },
                      //         ),
                      //         GestureDetector(
                      //           child: Image.asset("assets/images/esewa.png"),
                      //           onTap: (){
                      //             setState(() {
                      //               _gateway = 'esewa';
                      //             });
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 10,),

                      // SizedBox(
                      //   width: double.infinity,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: loading ?
                      //       Center(
                      //         child: CircularProgressIndicator(),
                      //       ) :
                      //         MaterialButton(
                      //         color:Color.fromARGB(255, 248, 152, 29),
                      //         child: Text("Continue To Payment"),
                      //         height: 50,
                      //         onPressed: () async {
                      //            String token = await UserPreferences().getToken();
                      //            launch('https://www.kutumba8.com/payment-via-token?token='+token);

                      //             // onPaymentSelect();
                      //         },
                      //       ),

                      //   ),
                      // ),

                      //  SizedBox(height: 20,),

                      // Text(
                      //   "After you have completed payment",
                      //   style: TextStyle(
                      //       color: Color.fromARGB(255, 248, 152, 29),
                      //       fontSize: 19,
                      //       fontWeight: FontWeight.w600),
                      // ),
                      // SizedBox(
                      // width: double.infinity,
                      // child: Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: loading ?
                      //     Center(
                      //       child: CircularProgressIndicator(),
                      //     ) :
                      //       MaterialButton(
                      //       color:Color.fromARGB(255, 248, 152, 29),
                      //       child: Text("Return To Home"),
                      //       height: 50,
                      //       onPressed: () async {
                      //          Navigator.of(context).pushReplacementNamed('/home');

                      //           // onPaymentSelect();
                      //       },
                      //     ),

                      // ),
                      // )
                    ],
                  )
                ]),
          )
        ],
      ),
    );
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
