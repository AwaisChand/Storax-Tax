import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:storatax/models/add_sub_status_model/add_sub_status_model.dart';
import 'package:storatax/models/client_plan_model/client_plan_model.dart';
import 'package:storatax/models/get_more_plans/get_more_plans.dart';
import 'package:storatax/models/my_plans_model/my_plans_model.dart';
import 'package:storatax/models/plan_detail_model/plan_detail_model.dart';
import 'package:storatax/models/tax_professional_plans_model/tax_professional_plans_model.dart';
import 'package:storatax/res/helper.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class PricingPlansRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<TaxProfessionalPlansModel> getTaxProfessionalPlansRepo() async {
    try {
      String countryCode = await getCountryCode();

      final url =
          "${AppUrl.baseUrl}api/plans/tax-professionals?country=$countryCode";

      dynamic response = await baseApiServices.getRequestWithoutToken(url);

      debugPrint("Raw API response JSON: $response");
      debugPrint("API URL: $url");

      return TaxProfessionalPlansModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<PlanDetailModel> getPlanDetailRepo(int planId) async {
    try {
      final String url = AppUrl.planDetailsUrl(planId);
      debugPrint("Fetching Plan Detail from: $url");

      dynamic response = await baseApiServices.getRequestWithoutToken(url);

      debugPrint("Raw API response JSON: $response");

      return PlanDetailModel.fromJson(response);
    } catch (e) {
      debugPrint("Error in getPlanDetailRepo: $e");
      rethrow;
    }
  }

  Future<ClientPlanModel> getClientPlanModel() async {
    try {
      String countryCode = await getCountryCode();

      final url = "${AppUrl.baseUrl}api/plans/client?country=$countryCode";

      dynamic response = await baseApiServices.getRequestWithoutToken(url);

      debugPrint("Raw API response JSON: $response");
      debugPrint("API URL: $url");

      return ClientPlanModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> paymentRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.paymentSuccessfulEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.paymentSuccessfulEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Get More Plans
  Future<GetMorePlansModel> getMorePlansRepo(BuildContext context) async {
    try {
      final auth = context.read<AuthViewModel>();
      String? countryCode = auth.user?.regCountry;

      final url = "${AppUrl.baseUrl}api/plans?country=$countryCode";

      dynamic response = await baseApiServices.getRequestToken(url);

      debugPrint("Raw API response JSON: $response");
      debugPrint("API URL: $url");

      return GetMorePlansModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Get More Plans
  Future<GetMyPlansModel> myPlansRepo(BuildContext context) async {
    try {
      final url = AppUrl.myPlansEndPoint;

      dynamic response = await baseApiServices.getRequestToken(url);

      debugPrint("Raw API response JSON: $response");
      debugPrint("API URL: $url");

      return GetMyPlansModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Verify Coupon Plans

  Future<dynamic> verifyCouponRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.verifyCouponEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.verifyCouponEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Create Payment Intent Repo

  Future<dynamic> createPaymentIntentRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.createPaymentIntentEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.createPaymentIntentEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Create Setup Intent Repo

  Future<dynamic> createSetupIntentRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.createSetupIntentEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.createSetupIntentEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Create subscription Repo

  Future<dynamic> createSubscriptionRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.createSubscriptionEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.createSubscriptionEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Apple Verify Purchase Repo

  Future<dynamic> appleVerifyPurchaseRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.verifyPurchaseApiEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.verifyPurchaseApiEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Get Sub Status Repo

  Future<AppleSubscriptionStatusModel> getSubStatusRepo(
    BuildContext context,
  ) async {
    try {
      final url = AppUrl.subStatusEndPoint;

      dynamic response = await baseApiServices.getRequestToken(url);

      debugPrint("Raw API response JSON: $response");
      debugPrint("API URL: $url");

      return AppleSubscriptionStatusModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> saveSubscriptionRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.saveSubscriptionEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.saveSubscriptionEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Unsubscribe plan

  Future<dynamic> unSubscribePlanRepo(int id) async {
    try {
      dynamic response = await baseApiServices.postApiResponse(
        "${AppUrl.unSubscribePlanEndPoint}/$id",
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.unSubscribePlanEndPoint}/$id");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Free Plan Subscribe

  Future<dynamic> freePlanSubscriptionRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.freePlanSubscriptionEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.freePlanSubscriptionEndPoint}");

      return response;
    } catch (e, stackTrace) {
      debugPrint("e.toString(),$stackTrace");
      rethrow;
    }
  }
}
