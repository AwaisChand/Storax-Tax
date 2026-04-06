import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storatax/models/get_more_plans/get_more_plans.dart';
import 'package:storatax/models/my_plans_model/my_plans_model.dart';
import 'package:storatax/models/plan_detail_model/plan_detail_model.dart';
import 'package:storatax/models/tax_professional_plans_model/tax_professional_plans_model.dart';
import 'package:storatax/repository/pricing_plans_repository/pricing_plans_repository.dart';
import 'package:storatax/models/client_plan_model/client_plan_model.dart'
    as client;

import '../../screens/bottom_nav_bar/bottom_nav_bar.dart';
import '../../utils/routes/routes_name.dart';
import '../../utils/utils.dart';

class PricingPlansViewModel extends ChangeNotifier {
  final PricingPlansRepository pricingPlansRepository =
      PricingPlansRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<Plans> _taxProfessionalPlans = [];
  List<Plans> get taxProfessionalPlans => _taxProfessionalPlans;

  List<client.Plans> _clientPlans = [];
  List<client.Plans> get clientPlans => _clientPlans;

  List<client.Features> _features = [];
  List<client.Features> get features => _features;

  PlanDetailModel? _planDetailModel;
  PlanDetailModel? get planDetailModel => _planDetailModel;

  List<MorePlans> _morePlans = [];
  List<MorePlans> get morePlans => _morePlans;

  List<MyPlans> _myPlans = [];
  List<MyPlans> get myPlans => _myPlans;

  Future<void> getTaxProfessionalPlansApi(BuildContext context) async {
    loading = true;
    try {
      final response =
          await pricingPlansRepository.getTaxProfessionalPlansRepo();

      if (response.status == 1) {
        _taxProfessionalPlans = response.plans!;

        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get Tax Professional API  Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get Tax Professional data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> getPlanDetailApi(BuildContext context, int planId) async {
    loading = true;
    try {
      final response = await pricingPlansRepository.getPlanDetailRepo(planId);

      if (response.status == 1) {
        _planDetailModel = response;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get plan detail API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get plan detail data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> getClientPlansApi(BuildContext context) async {
    loading = true;
    try {
      final response = await pricingPlansRepository.getClientPlanModel();

      if (response.status == 1) {
        _clientPlans = response.plans!;
        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get Client Plan API  Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get Client Plan data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> paymentApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Payment data: $data");

      final response = await pricingPlansRepository.paymentRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        context.pushNamed('login');
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Payment API Response: $response");
      }
    } catch (e) {
      debugPrint("Payment error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> getMorePlansApi(BuildContext context) async {
    loading = true;
    try {
      final response = await pricingPlansRepository.getMorePlansRepo(context);

      if (response.status == 1) {
        _morePlans = response.data!.plans!;
        Utils.toastMessage(response.message!);
      } else {
        Utils.toastMessage(response.message!);
      }

      if (kDebugMode) {
        debugPrint("Get More Plans API  Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get More Plans data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<Map<String, dynamic>> myPlansApi(BuildContext context) async {
    loading = true;
    try {
      final response = await pricingPlansRepository.myPlansRepo(context);

      if (response.status == 1) {
        _myPlans = response.plans!;
        return {
          "success": true,
          "message": response.success ?? "Plans loaded successfully",
        };
      } else {
        return {
          "success": false,
          "message": response.success ?? "Something went wrong",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error: ${e.toString()}",
      };
    } finally {
      loading = false;
    }
  }

  ///Verify Coupon Api

  Future<Map<String, dynamic>> verifyCouponApi(
    String couponCode,
    int planId,
  ) async {
    loading = true;
    try {
      final data = {"coupon_code": couponCode, "plan_id": planId};

      final response = await pricingPlansRepository.verifyCouponRepo(data);

      if (response["status"].toString() == "1") {
        final coupon = response["data"]["coupon"];
        final discountedPrice = response["data"]["discounted_price"];
        final discountAmount = response["data"]["discount_amount"];
        final discountValue = response["data"]["discount_value"];

        debugPrint("Data: $data");

        return {
          "success": true,
          "message": response["message"],
          "couponCode": coupon["code"],
          "id": coupon["id"],
          "planId": planId,
          "discounted_price": discountedPrice,
          "discount_amount": discountAmount,
          "discount_value": discountValue,
        };
      } else {
        return {"success": false, "message": response["message"]};
      }
    } catch (e, stackTrace) {
      debugPrint("Coupon verify error: $e\n$stackTrace");
      return {"success": false, "message": "Error: ${e.toString()}"};
    } finally {
      loading = false;
    }
  }

  ///Create Payment Intent Api

  Future<bool> createPaymentIntentApi(dynamic data) async {
    loading = true;
    notifyListeners();

    try {
      final response = await pricingPlansRepository.createPaymentIntentRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        return true;
      } else {
        Utils.toastMessage(response["message"]);
        return false;
      }

    } catch (e, st) {
      Utils.toastMessage("Error: ${e.toString()}, $st");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }



  ///Create Setup Intent Api

  Future<Map<String, dynamic>?> createSetupIntentApi(dynamic data) async {
    loading = true;
    notifyListeners();

    try {
      final response = await pricingPlansRepository.createSetupIntentRepo(data);

      if (response["status"].toString() == "1") {
        // ✅ Correct: return the whole response
        return response;
      } else {
        Utils.toastMessage(response["message"]);
        return null;
      }
    } catch (e, st) {
      Utils.toastMessage("Error: ${e.toString()}");
      print("Catch Error: $st}");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }


  ///Create Subscription Api

  Future<Map<String, dynamic>?> createSubscriptionApi(dynamic data) async {
    loading = true;
    notifyListeners();

    try {
      final response =
      await pricingPlansRepository.createSubscriptionRepo(data);

      if (response["status"].toString() == "1") {
        return response; // ✅ RETURN FULL RESPONSE
      } else {
        Utils.toastMessage(response["success"]);
        return null;
      }
    } catch (e, st) {
      Utils.toastMessage("Error: ${e.toString()}");
      debugPrint("sub cre error: $st");
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  /// Save Subscription

  Future<void> saveSubscriptionApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Save Sub data: $data");

      final response = await pricingPlansRepository.saveSubscriptionRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);

        // 🔥 STEP 1: Refresh plans from API
        await myPlansApi(context);

        // 🔥 STEP 2: Navigate to BottomNavBar
        Future.microtask(() {
          context.goNamed("bottomNavBar");
        });

        // 🔥 STEP 3: After navigation is complete, force refresh BottomNavBar
        Future.delayed(const Duration(milliseconds: 300), () {
          final navState = BottomNavBar.globalKey.currentState;

          navState?.resetState();      // clears screens & keys
          navState?.refreshTabs();     // rebuilds tabs based on new plan
          navState?.switchTab(0);      // go to dashboard
        });
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Save Sub API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Save Sub error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///un subscribe plan api

  Future<bool> unSubscribePlanApi(BuildContext context, int id) async {
    loading = true;
    notifyListeners(); // Make sure UI shows loading indicator

    try {
      final response = await pricingPlansRepository.unSubscribePlanRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);

        // STEP 1: Refresh plans via Provider
        await myPlansApi(context); // myPlansApi should update the `myPlans` list

        // STEP 2: Navigate safely after the current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          // Navigate to BottomNavBar
          context.goNamed("bottomNavBar");

          // STEP 3: After slight delay, force BottomNavBar to rebuild
          Future.delayed(const Duration(milliseconds: 200), () {
            final navState = BottomNavBar.globalKey.currentState;
            if (navState != null) {
              navState.resetState();   // Clear old screens
              navState.refreshTabs();  // Rebuild tabs based on new plan
              navState.switchTab(0);   // Go to default tab (dashboard)
            }
          });
        });

        return true;
      } else {
        Utils.toastMessage(response["message"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("un subscribe error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
      notifyListeners(); // Stop loading indicator
    }
  }

  ///free plan subscription api

  Future<bool> freePlanSubscribeApi(dynamic data) async {
    loading = true;
    notifyListeners();

    try {
      final response = await pricingPlansRepository.freePlanSubscriptionRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        return true;
      } else {
        Utils.toastMessage(response["message"]);
        return false;
      }

    } catch (e, st) {
      Utils.toastMessage("Error: ${e.toString()}, $st");
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
