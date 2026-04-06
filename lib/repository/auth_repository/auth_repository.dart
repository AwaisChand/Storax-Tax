import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:storatax/models/get_user_profile/get_user_profile.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart' show AppUrl;

class AuthRepository{
  BaseApiServices baseApiServices = NetworkApiService();


  ///Login
  Future<dynamic> login(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postLoginRequest(
        AppUrl.loginEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.loginEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Verify email

  Future<dynamic> verifyEmail(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.sendOtpEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.sendOtpEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }


  ///Verify Otp

  Future<dynamic> verifyOtp(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.verifyOtpEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.verifyOtpEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Resend Otp

  Future<dynamic> resendOtp(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.resendOtpEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.resendOtpEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Reset Password

  Future<dynamic> resetPassword(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.resetPasswordEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.resetPasswordEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Tax Professional Registration

  Future<dynamic> taxProfessionalRegRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.taxProfessionalRegEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.taxProfessionalRegEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Client Plan Registration

  Future<dynamic> clientPlanRegRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequestWithoutToken(
        AppUrl.clientPlanRegEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.clientPlanRegEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Get Profile Data

  Future<GetUserProfileModel> getUserProfileRepo() async {
    try {
      dynamic response = await baseApiServices.getRequestToken(
        AppUrl.userProfileEndPoint,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.userProfileEndPoint}");

      return GetUserProfileModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }


  ///Update Profile Data
  Future<dynamic> updateProfileRepo({
    required Map<String, dynamic> fields,
    File? avatarFile,
  }) async {
    try {
      // Use multipart post request instead of JSON
      dynamic response = await baseApiServices.multipartPostRequest(
        AppUrl.updateProfileEndPoint,
        fields: fields,
        files: avatarFile != null ? {'avatar': avatarFile} : null,
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.updateProfileEndPoint}");
      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Update settings

  Future<dynamic> updateSettingsRepo(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.settingsEndPoint,
        data,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.settingsEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  ///Delete Acc

  Future<dynamic> deleteAccountRepo() async {
    try {
      dynamic response = await baseApiServices.deleteApiResponse(
        AppUrl.deleteEndPoint,
      );
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.deleteEndPoint}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}