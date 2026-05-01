import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../utils/utils.dart';
import '../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

Map<String, dynamic>? paymentIntentData;
String? paymentMethodId;

Future<String> getCountryCode() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String? country = placemarks.first.isoCountryCode?.toLowerCase();

    if (country == 'ca') return 'ca';
    return 'us';
  } catch (e) {
    return 'us';
  }
}

Future<void> startSubscriptionFlow(
    BuildContext context,
    String userId,
    int planId,
    PricingPlansViewModel provider,
    ) async {
  try {
    debugPrint("🚀 STEP 1: SetupIntent API");

    final setupResponse = await provider.createSetupIntentApi({
      "user_id": userId,
      "plan_id": planId,
    });

    debugPrint("📦 SetupIntent RESPONSE: $setupResponse");

    if (setupResponse == null) {
      Utils.toastMessage("Setup failed");
      return;
    }

    final clientSecret = setupResponse["client_secret"];
    final customerId = setupResponse["customer_id"];
    final ephemeralKey = setupResponse["ephemeral_key"];
    final plan = setupResponse["plan"];
    final priceId = plan?["stripe_price_id"];

    if (clientSecret == null ||
        customerId == null ||
        ephemeralKey == null ||
        priceId == null) {
      Utils.toastMessage("Stripe setup incomplete");
      return;
    }

    debugPrint("🔐 clientSecret: $clientSecret");
    debugPrint("👤 customerId: $customerId");
    debugPrint("🔑 ephemeralKey: $ephemeralKey");
    debugPrint("💲 priceId: $priceId");

    // ✅ STEP 2: Init Payment Sheet (UPDATED)
    debugPrint("🚀 STEP 2: Init Payment Sheet");

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKey,
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: 'Stora Tax',

        // 🔥 APPLE PAY ENABLED
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'CA',
        ),

        // Optional (good UX)
        style: ThemeMode.system,
      ),
    );

    debugPrint("✅ INIT SUCCESS");

    // ✅ STEP 3: Present Payment Sheet
    debugPrint("🚀 STEP 3: Present Payment Sheet");

    await Stripe.instance.presentPaymentSheet();

    debugPrint("✅ PAYMENT METHOD SAVED");

    // ✅ STEP 4: Retrieve SetupIntent
    debugPrint("🚀 STEP 4: Retrieve SetupIntent");

    final setupIntent =
    await Stripe.instance.retrieveSetupIntent(clientSecret);

    final paymentMethodId = setupIntent.paymentMethodId;

    if (paymentMethodId == null) {
      Utils.toastMessage("Payment method not found");
      return;
    }

    debugPrint("💳 PaymentMethodId: $paymentMethodId");

    // ✅ STEP 5: Create Subscription
    debugPrint("🚀 STEP 5: Create Subscription");

    final subPayload = {
      "price_id": priceId,
      "payment_method_id": paymentMethodId,
      "user_id": userId,
      "plan_id": planId,
    };

    debugPrint("📌 SUBSCRIPTION REQUEST PAYLOAD: $subPayload");

    final subResponse = await provider.createSubscriptionApi(subPayload);

    debugPrint("📦 SUB RESPONSE: $subResponse");

    if (subResponse == null) {
      Utils.toastMessage("Subscription failed");
      return;
    }

    final subscriptionId = subResponse["subscription_id"];

    if (subscriptionId == null) {
      Utils.toastMessage("Invalid subscription response");
      return;
    }

    debugPrint("✅ Subscription ID: $subscriptionId");

    // ✅ STEP 6: Call paymentApi
    debugPrint("🚀 STEP 6: Call paymentApi");

    await provider.paymentApi(context, {
      "subscription_id": subscriptionId,
      "user_id": userId,
    });

    debugPrint("✅ FLOW COMPLETED SUCCESSFULLY");

  } on StripeException catch (e) {
    debugPrint("❌ STRIPE ERROR: ${e.error.localizedMessage}");
    Utils.toastMessage(
        e.error.localizedMessage ?? "Payment cancelled");

  } catch (e, s) {
    debugPrint("❌ FINAL ERROR: $e\n$s");
    Utils.toastMessage("Something went wrong");
  }
}


Future<void> saveSubscriptionFlow(
    BuildContext context,
    int userId,
    int planId,
    int? couponId,
    PricingPlansViewModel provider,
    ) async {
  try {
    debugPrint("🚀 STEP 1: Calling SetupIntent API");

    final setupResponse = await provider.createSetupIntentApi({
      "user_id": userId,
      "plan_id": planId,
    });

    debugPrint("📦 RAW RESPONSE: $setupResponse");

    if (setupResponse == null) {
      Utils.toastMessage("Failed to create SetupIntent");
      return;
    }

    final clientSecret = setupResponse["client_secret"];
    final customerId = setupResponse["customer_id"];
    final ephemeralKey = setupResponse["ephemeral_key"];
    final planData = setupResponse["plan"];

    if (clientSecret == null ||
        customerId == null ||
        ephemeralKey == null ||
        planData == null ||
        planData["stripe_price_id"] == null) {
      Utils.toastMessage("Missing Stripe required values");
      return;
    }

    final String priceId = planData["stripe_price_id"];

    debugPrint("🔐 clientSecret: $clientSecret");
    debugPrint("👤 customerId: $customerId");
    debugPrint("🔑 ephemeralKey: $ephemeralKey");
    debugPrint("💲 Price ID: $priceId");

    // ✅ STEP 2: Init Payment Sheet (UPDATED WITH APPLE PAY)
    debugPrint("🚀 STEP 2: Init Payment Sheet");

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKey,
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: 'Stora Tax',

        // 🔥 ADD THIS FOR APPLE PAY
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'CA', // Canada
        ),

        // Optional (recommended)
        style: ThemeMode.system,
      ),
    );

    debugPrint("✅ INIT SUCCESS");

    // ✅ STEP 3: Present Payment Sheet
    debugPrint("🚀 STEP 3: Present Payment Sheet");

    await Stripe.instance.presentPaymentSheet();

    debugPrint("✅ PRESENT SUCCESS");

    // ✅ STEP 4: Retrieve SetupIntent
    debugPrint("🚀 STEP 4: Retrieve SetupIntent");

    final setupIntent =
    await Stripe.instance.retrieveSetupIntent(clientSecret);

    final paymentMethodId = setupIntent.paymentMethodId;

    if (paymentMethodId == null) {
      Utils.toastMessage("Payment method not found");
      return;
    }

    debugPrint("💳 PaymentMethodId: $paymentMethodId");

    // ✅ STEP 5: Create Subscription
    debugPrint("🚀 STEP 5: Create Subscription");

    final subPayload = {
      "price_id": priceId,
      "payment_method_id": paymentMethodId,
      "user_id": userId,
      "plan_id": planId,
      "coupon_id": couponId,
    };

    debugPrint("📌 SUBSCRIPTION REQUEST PAYLOAD: $subPayload");

    final subResponse = await provider.createSubscriptionApi(subPayload);

    debugPrint("📦 SUB RESPONSE: $subResponse");

    if (subResponse == null) {
      Utils.toastMessage("Subscription creation failed");
      return;
    }

    final subscriptionId = subResponse["subscription_id"];

    if (subscriptionId == null) {
      Utils.toastMessage("Invalid subscription response");
      return;
    }

    debugPrint("✅ Subscription ID: $subscriptionId");

    // ✅ STEP 6: Save Subscription
    await provider.saveSubscriptionApi(context, {
      "subscription_id": subscriptionId,
      "user_id": userId,
      "plan_id": planId,
      "coupon_id": couponId,
    });

    debugPrint("✅ saveSubscriptionApi called");

  } on StripeException catch (e) {
    debugPrint("❌ STRIPE ERROR: ${e.error.localizedMessage}");
    Utils.toastMessage(e.error.localizedMessage ?? "Payment cancelled");

  } catch (e, s) {
    debugPrint("❌ FINAL ERROR: $e");
    debugPrint("$s");
    Utils.toastMessage("Something went wrong during subscription");
  }
}



Future<void> saveAppleSubscriptionFlow({
  required BuildContext context,
  required int userId,
  required int planId,
  required String productId,
  required PricingPlansViewModel provider,
}) async {
  final InAppPurchase iap = InAppPurchase.instance;

  try {
    debugPrint("🚀 STEP 1: Check Store Availability");

    final bool isAvailable = await iap.isAvailable();
    if (!isAvailable) {
      Utils.toastMessage("App Store not available");
      return;
    }

    // 🔥 STEP 2: Get Product Details
    debugPrint("🚀 STEP 2: Fetch Product");

    final ProductDetailsResponse response =
    await iap.queryProductDetails({productId});

    if (response.notFoundIDs.isNotEmpty) {
      Utils.toastMessage("Product not found");
      return;
    }

    final productDetails = response.productDetails.first;

    debugPrint("✅ Product Found: ${productDetails.id}");

    // 🔥 STEP 3: Listen to Purchase Updates
    late StreamSubscription<List<PurchaseDetails>> subscription;

    subscription = iap.purchaseStream.listen(
          (List<PurchaseDetails> purchases) async {
        for (final purchase in purchases) {
          debugPrint("📦 Purchase Status: ${purchase.status}");

          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {

            // 🔐 RECEIPT
            final receiptData =
                purchase.verificationData.serverVerificationData;

            final transactionId = purchase.purchaseID ??"";

            debugPrint("🧾 Receipt: $receiptData");
            debugPrint("🆔 TransactionId: $transactionId");

            // 🔥 STEP 4: VERIFY WITH BACKEND
            final verifyPayload = {
              "user_id": userId,
              "plan_id": planId,
              "product_id": productId,
              "transaction_id": transactionId,
              "receipt_data": receiptData,
            };

            debugPrint("📤 VERIFY PAYLOAD: $verifyPayload");

            final verifyResponse =
            await provider.appleVerifyPurchaseApi(verifyPayload);

            debugPrint("📦 VERIFY RESPONSE: $verifyResponse");

            if (verifyResponse != null &&
                verifyResponse["status"] == true) {

              // ✅ SUCCESS
              Utils.toastMessage("Subscription Activated");

              // 🔥 OPTIONAL: COMPLETE TRANSACTION
              if (purchase.pendingCompletePurchase) {
                await iap.completePurchase(purchase);
              }

              await subscription.cancel();
              return;
            } else {
              Utils.toastMessage("Verification failed");
            }
          }

          if (purchase.status == PurchaseStatus.error) {
            debugPrint("❌ Purchase Error: ${purchase.error}");
            Utils.toastMessage("Purchase failed");
          }

          if (purchase.pendingCompletePurchase) {
            await iap.completePurchase(purchase);
          }
        }
      },
      onError: (error) {
        debugPrint("❌ STREAM ERROR: $error");
        Utils.toastMessage("Something went wrong");
      },
    );

    // 🔥 STEP 5: Start Purchase
    debugPrint("🚀 STEP 5: Start Purchase");

    final PurchaseParam purchaseParam =
    PurchaseParam(productDetails: productDetails);

    await iap.buyNonConsumable(purchaseParam: purchaseParam);

  } catch (e, s) {
    debugPrint("❌ FINAL ERROR: $e");
    debugPrint("$s");
    Utils.toastMessage("Something went wrong");
  }
}



