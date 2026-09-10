import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storatax/models/get_user_profile/get_user_profile.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart' show AppUrl;
import '../../utils/scan_upload_file.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path_helper;

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
      File? uploadFile = avatarFile;

      // Convert the selected image into a guaranteed-valid JPEG.
      if (avatarFile != null) {
        uploadFile = await normalizeAvatarToJpeg(
          avatarFile,
        );
      }

      debugPrint('==========================================');
      debugPrint('PROFILE AVATAR');
      debugPrint('Original: ${avatarFile?.path}');
      debugPrint('Upload:   ${uploadFile?.path}');

      if (uploadFile != null) {
        debugPrint(
          'Upload filename: '
              '${path_helper.basename(uploadFile.path)}',
        );

        debugPrint(
          'Upload size: '
              '${await uploadFile.length()} bytes',
        );
      }

      debugPrint('==========================================');

      final response =
      await baseApiServices.multipartPostRequest(
        AppUrl.updateProfileEndPoint,
        fields: fields,
        files: uploadFile != null
            ? {'avatar': uploadFile}
            : null,
      );

      debugPrint(
        "Raw API response JSON: $response",
      );

      debugPrint(
        "Api url: ${AppUrl.updateProfileEndPoint}",
      );

      return response;
    } catch (e, st) {
      debugPrint(
        "Update profile repository error: $e",
      );

      debugPrint(
        "$st",
      );

      rethrow;
    }
  }


  Future<File> normalizeAvatarToJpeg(
      File originalFile,
      ) async {
    try {
      debugPrint('==========================================');
      debugPrint('NORMALIZING AVATAR');
      debugPrint('Original path: ${originalFile.path}');
      debugPrint('Original name: '
          '${path_helper.basename(originalFile.path)}');
      debugPrint(
        'Original size: ${await originalFile.length()} bytes',
      );
      debugPrint('==========================================');

      // Read original bytes
      final bytes = await originalFile.readAsBytes();

      debugPrint(
        'Read ${bytes.length} bytes from original image',
      );

      // Decode the actual image.
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception(
          'Selected file is not a valid image.',
        );
      }

      debugPrint(
        'Image decoded successfully.',
      );

      debugPrint(
        'Image width: ${decodedImage.width}',
      );

      debugPrint(
        'Image height: ${decodedImage.height}',
      );

      // Encode as REAL JPEG bytes.
      final jpegBytes = img.encodeJpg(
        decodedImage,
        quality: 90,
      );

      debugPrint(
        'JPEG encoded successfully.',
      );

      debugPrint(
        'JPEG size: ${jpegBytes.length} bytes',
      );

      // Create a temporary JPEG file.
      final tempDirectory =
      await getTemporaryDirectory();

      final fileName =
          'profile_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final outputFile = File(
        path_helper.join(
          tempDirectory.path,
          fileName,
        ),
      );

      await outputFile.writeAsBytes(
        jpegBytes,
        flush: true,
      );

      debugPrint('==========================================');
      debugPrint('NORMALIZED AVATAR CREATED');
      debugPrint('Output path: ${outputFile.path}');
      debugPrint(
        'Output name: '
            '${path_helper.basename(outputFile.path)}',
      );
      debugPrint(
        'Output size: ${await outputFile.length()} bytes',
      );
      debugPrint('==========================================');

      return outputFile;
    } catch (e, st) {
      debugPrint(
        'Avatar JPEG normalization failed: $e',
      );

      debugPrint(
        '$st',
      );

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