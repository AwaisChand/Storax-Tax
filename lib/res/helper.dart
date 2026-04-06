
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


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

    // 1️⃣ SetupIntent
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

    // 2️⃣ Init Payment Sheet
    debugPrint("🚀 STEP 2: Init Payment Sheet");

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKey,
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: 'Stora Tax',
      ),
    );

    debugPrint("✅ INIT SUCCESS");

    // 3️⃣ Present Payment Sheet
    debugPrint("🚀 STEP 3: Present Payment Sheet");

    await Stripe.instance.presentPaymentSheet();

    debugPrint("✅ PAYMENT METHOD SAVED");

    // 4️⃣ Retrieve PaymentMethod
    debugPrint("🚀 STEP 4: Retrieve SetupIntent");

    final setupIntent =
    await Stripe.instance.retrieveSetupIntent(clientSecret);

    final paymentMethodId = setupIntent.paymentMethodId;

    if (paymentMethodId == null) {
      Utils.toastMessage("Payment method not found");
      return;
    }

    debugPrint("💳 PaymentMethodId: $paymentMethodId");

    // 5️⃣ Create Subscription
    debugPrint("🚀 STEP 5: Create Subscription");

    final subPayload = {
      "price_id": priceId,
      "payment_method_id": paymentMethodId,
      "user_id": userId,
      "plan_id": planId,
      // "coupon_id": couponId, // optional here
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

    // 6️⃣ ✅ CALL paymentApi (NO coupon_id here)
    debugPrint("🚀 STEP 6: Call paymentApi");

    await provider.paymentApi(context, {
      "subscription_id": subscriptionId,
      "user_id": userId,
    });

    debugPrint("✅ FLOW COMPLETED SUCCESSFULLY");

  } catch (e, s) {
    debugPrint("❌ FINAL ERROR: $e\n$s");
    Utils.toastMessage("Something went wrong");
  }
}

// Future<void> saveSubscriptionFlow(
//     String amount,
//     String priceId,
//     String? customerId,
//     BuildContext context,
//     int? couponId,
//     int? planId,
//     PricingPlansViewModel pricingProvider,
//     ) async {
//   try {
//     // 1️⃣ Create customer
//     customerId = await createCustomer();
//
//     // 2️⃣ Create payment intent
//     paymentIntentData = await createPaymentIntent(amount, 'USD');
//
//     // 3️⃣ Initialize Stripe Payment Sheet
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: paymentIntentData?['client_secret'],
//         style: ThemeMode.light,
//         merchantDisplayName: 'Stora Tax',
//       ),
//     );
//
//     // 4️⃣ Present Payment Sheet
//     await Stripe.instance.presentPaymentSheet();
//
//     // ✅ Payment successful
//     String paymentIntentId = paymentIntentData!['id'];
//
//     // 5️⃣ Get payment intent details
//     var response = await http.get(
//       Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
//       headers: {'Authorization': 'Bearer ${Utils.secretKey}'},
//     );
//
//     var paymentIntent = jsonDecode(response.body);
//     paymentMethodId = paymentIntent['payment_method'];
//
//     // 6️⃣ Attach payment method and update default
//     await attachPaymentMethod(customerId!, paymentMethodId!);
//     await updateCustomerDefaultPaymentMethod(customerId, paymentMethodId!);
//
//     // 7️⃣ Create subscription
//     final subscription = await createSubscription(customerId, priceId);
//     final subId = subscription?['id'];
//
//     if (subId != null) {
//       Utils.toastMessage("Subscription Created: $subId");
//       debugPrint("✅ Subscription ID: $subId");
//
//       pricingProvider.saveSubscriptionApi(context, {
//         "subscription_id": subId,
//         "coupon_id": couponId,
//         "plan_id": planId,
//       });
//
//       debugPrint("payment data: $subId $couponId");
//     }
//   } on StripeException catch (e) {
//     // 🔒 User canceled or Stripe-specific errors
//     debugPrint("⚠ StripeException: ${e.error.localizedMessage}");
//     Utils.toastMessage("Payment canceled");
//   } catch (e, s) {
//     // 🔥 Other errors
//     debugPrint("❌ ERROR: $e\n$s");
//     Utils.toastMessage("Payment failed");
//   }
// }

Future<void> saveSubscriptionFlow(
    BuildContext context,
    int userId,
    int planId,
    int? couponId,
    PricingPlansViewModel provider,
    ) async {
  try {
    debugPrint("🚀 STEP 1: Calling SetupIntent API");
    debugPrint("📤 SetupIntent Payload: ${{
      "user_id": userId,
      "plan_id": planId,
    }}");
    // 1️⃣ SetupIntent API
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

    // 2️⃣ Init Payment Sheet
    debugPrint("🚀 STEP 2: Init Payment Sheet");

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKey,
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: 'Stora Tax',
      ),
    );

    debugPrint("✅ INIT SUCCESS");

    // 3️⃣ Present Payment Sheet
    debugPrint("🚀 STEP 3: Present Payment Sheet");

    await Stripe.instance.presentPaymentSheet();

    debugPrint("✅ PRESENT SUCCESS");

    // 4️⃣ Retrieve SetupIntent
    debugPrint("🚀 STEP 4: Retrieve SetupIntent");

    final setupIntent =
    await Stripe.instance.retrieveSetupIntent(clientSecret);

    final paymentMethodId = setupIntent.paymentMethodId;

    if (paymentMethodId == null) {
      Utils.toastMessage("Payment method not found");
      return;
    }

    debugPrint("💳 PaymentMethodId: $paymentMethodId");

    // 5️⃣ Create Subscription
    debugPrint("🚀 STEP 5: Create Subscription");

    final subPayload = {
      "price_id": priceId,
      "payment_method_id": paymentMethodId,
      "user_id": userId,
      "plan_id": planId,
      "coupon_id": couponId, // ✅ included
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

    // 6️⃣ 🔥 CALL YOUR SAVE SUBSCRIPTION API
    await provider.saveSubscriptionApi(context, {
      "subscription_id": subscriptionId,
      "user_id": userId,
      "plan_id": planId,
      "coupon_id": couponId,
    });

    debugPrint("✅ saveSubscriptionApi called");

  } catch (e, s) {
    debugPrint("❌ FINAL ERROR: $e");
    debugPrint("$s");
    Utils.toastMessage("Something went wrong during subscription");
  }
}



