import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kutumba/components/alert.dart';
import 'package:kutumba/components/header_logo.dart';
import 'package:kutumba/main_drawer.dart';
import 'package:kutumba/services/payment_api.dart';

import 'package:in_app_purchase/in_app_purchase.dart';
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

  const Payment(
      this.type, {
        super.key,
        this.hasBackBtn = false,
        this.redirectPage = '/albums',
      });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final PaymentService _api = PaymentService();

  final InAppPurchase _inAppPurchase =
      InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>?
  _subscription;

  List<String> _notFoundIds = <String>[];
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases =
  <PurchaseDetails>[];
  List<String> _consumables = <String>[];

  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = false;

  String? _queryProductError;

  @override
  void initState() {
    super.initState();

    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    _subscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (Object error) {
        debugPrint(
          'Purchase stream error: $error',
        );
      },
    );

    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    try {
      final bool isAvailable =
      await _inAppPurchase.isAvailable();

      if (!isAvailable) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isAvailable = false;
          _products = <ProductDetails>[];
          _purchases = <PurchaseDetails>[];
          _notFoundIds = <String>[];
          _consumables = <String>[];
          _purchasePending = false;
          _loading = false;
        });

        return;
      }

      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition
        iosPlatformAddition =
        _inAppPurchase.getPlatformAddition<
            InAppPurchaseStoreKitPlatformAddition>();

        await iosPlatformAddition.setDelegate(
          ExamplePaymentQueueDelegate(),
        );
      }

      final ProductDetailsResponse
      productDetailResponse =
      await _inAppPurchase.queryProductDetails(
        _kProductIds.toSet(),
      );

      if (!mounted) {
        return;
      }

      if (productDetailResponse.error != null) {
        setState(() {
          _queryProductError =
              productDetailResponse.error?.message;

          _isAvailable = isAvailable;
          _products =
              productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];
          _notFoundIds =
              productDetailResponse.notFoundIDs;
          _consumables = <String>[];
          _purchasePending = false;
          _loading = false;
        });

        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        setState(() {
          _queryProductError = null;
          _isAvailable = isAvailable;
          _products =
              productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];
          _notFoundIds =
              productDetailResponse.notFoundIDs;
          _consumables = <String>[];
          _purchasePending = false;
          _loading = false;
        });

        return;
      }

      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products =
            productDetailResponse.productDetails;
        _notFoundIds =
            productDetailResponse.notFoundIDs;
        _purchasePending = false;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'In-app purchase initialization error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isAvailable = false;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _notFoundIds = <String>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
        _queryProductError =
        'Unable to initialize payment.';
      });
    }
  }

  void showPendingUI() {
    if (!mounted) {
      return;
    }

    setState(() {
      _purchasePending = true;
    });
  }

  void handleError(IAPError? error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _purchasePending = false;
    });

    debugPrint(
      'Purchase error: ${error?.message}',
    );
  }

  Future<bool> _verifyPurchase(
      PurchaseDetails purchaseDetails,
      ) async {
    // IMPORTANT:
    // In production, verify the purchase on your backend
    // before granting the subscription.
    //
    // This currently keeps the same behavior as your
    // original implementation.
    return true;
  }

  void _handleInvalidPurchase(
      PurchaseDetails purchaseDetails,
      ) {
    debugPrint(
      'Invalid purchase: ${purchaseDetails.productID}',
    );
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList,
      ) async {
    for (final PurchaseDetails purchaseDetails
    in purchaseDetailsList) {
      if (!mounted) {
        return;
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          Alert.successSnackbar(
            context,
            'pending',
            duration:
            const Duration(milliseconds: 500),
          );

          showPendingUI();
          break;

        case PurchaseStatus.error:
          Alert.errorSnackbar(
            context,
            purchaseDetails.error?.message ??
                'Payment failed.',
          );

          handleError(purchaseDetails.error);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          Alert.successSnackbar(
            context,
            purchaseDetails.status ==
                PurchaseStatus.restored
                ? 'restored'
                : 'purchased',
            duration:
            const Duration(milliseconds: 500),
          );

          final bool valid =
          await _verifyPurchase(
            purchaseDetails,
          );

          if (!valid) {
            _handleInvalidPurchase(
              purchaseDetails,
            );
            break;
          }

          debugPrint(
            'Purchase successful: '
                '${purchaseDetails.productID}',
          );

          if (mounted) {
            setState(() {
              _purchasePending = false;
            });
          }

          // TODO:
          // Send purchaseDetails.purchaseID /
          // serverVerificationData to your backend
          // and activate the user's subscription.
          break;

        case PurchaseStatus.canceled:
          if (mounted) {
            setState(() {
              _purchasePending = false;
            });
          }

          debugPrint('Purchase cancelled.');
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        try {
          await _inAppPurchase.completePurchase(
            purchaseDetails,
          );
        } catch (e) {
          debugPrint(
            'Complete purchase error: $e',
          );
        }
      }
    }
  }

  Future<void> _subscribe() async {
    if (_products.isEmpty) {
      Alert.errorSnackbar(
        context,
        'Subscription product is not available.',
      );
      return;
    }

    if (!_isAvailable) {
      Alert.errorSnackbar(
        context,
        'In-app purchases are not available.',
      );
      return;
    }

    if (_purchasePending) {
      return;
    }

    final ProductDetails product =
    _products.firstWhere(
          (ProductDetails product) =>
      product.id == _kMonthlySubscriptionId,
      orElse: () => _products.first,
    );

    final PurchaseParam purchaseParam =
    PurchaseParam(
      productDetails: product,
    );

    try {
      if (!mounted) {
        return;
      }

      setState(() {
        _purchasePending = true;
      });

      await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      debugPrint(
        'Start purchase error: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _purchasePending = false;
      });

      Alert.errorSnackbar(
        context,
        'Unable to start the payment.',
      );
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition
      iosPlatformAddition =
      _inAppPurchase.getPlatformAddition<
          InAppPurchaseStoreKitPlatformAddition>();

      iosPlatformAddition.setDelegate(null);
    }

    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      endDrawer:
      widget.hasBackBtn ? null : const MainDrawer(),
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
                image: AssetImage(
                  'assets/images/kutumba8.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceAround,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Welcome to Kutumba’s digital music archive! '
                        'All our albums are online. We would like '
                        'to share our decades of hard work and more '
                        'to come, on this platform. Stay connected!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Column(
                  children: [
                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        'Contact maharjanpavit002@gmail.com '
                            'if you are face any issues once logged in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(
                            255,
                            248,
                            152,
                            29,
                          ),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_queryProductError != null)
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Text(
                          _queryProductError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    if (_loading)
                      const CircularProgressIndicator()
                    else
                      TextButton(
                        onPressed:
                        _purchasePending ||
                            !_isAvailable ||
                            _products.isEmpty
                            ? null
                            : _subscribe,
                        child: _purchasePending
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Subscribe',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExamplePaymentQueueDelegate
    implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction,
      SKStorefrontWrapper storefront,
      ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}