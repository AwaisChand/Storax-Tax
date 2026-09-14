import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storatax/models/get_user_profile/get_user_profile.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../models/login_model/login_model.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../screens/bottom_nav_bar/bottom_nav_bar.dart';
import '../../screens/plan_summary_screen/plan_summary_screen.dart';
import '../../utils/utils.dart';
import '../pricing_plans_view_model/pricing_plans_view_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository = AuthRepository();

  User? _user;
  User? get user => _user;

  Data? _data;
  Data? get data => _data;

  File? _pickedImage;
  File? _tempPickedImage;
  File? get pickedImage => _pickedImage ?? _tempPickedImage;

  List<XFile> _pickedImages = [];
  List<XFile> get pickedImages => _pickedImages;

  final ImagePicker _picker = ImagePicker();

  String? _pickedFileName;
  String? get pickedFileName => _pickedFileName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _resendLoading = false;
  bool get resendLoading => _resendLoading;

  bool _settings = false;
  bool get settings => _settings;

  bool _deleteLoading = false;
  bool get deleteLoading => _deleteLoading;

  String? pendingSubStatus;
  int? pendingPlanId;
  String? pendingUserId;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  set resend(bool setLoading) {
    _resendLoading = setLoading;
    notifyListeners();
  }

  set updateSettings(bool setLoading) {
    _settings = setLoading;
    notifyListeners();
  }

  set delete(bool setLoading) {
    _deleteLoading = setLoading;
    notifyListeners();
  }

  void clearPickedImages() {
    _pickedImages.clear();
    notifyListeners();
  }

  void setPickedImage(File? file) {
    _pickedImage = file;
    notifyListeners();
  }

  ///Save User Data
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
    _user = user;
    notifyListeners();
  }

  ///Clean picked image
  void clearPickedImage() {
    _pickedImage = null;
    notifyListeners();
  }

  ///Saved Picked image

  void savePickedImage() {
    if (_tempPickedImage != null) {
      _pickedImage = _tempPickedImage;
      _tempPickedImage = null;
      notifyListeners();
    }
  }

  ///Remove pikced image
  void removeImage(int index) {
    _pickedImages.removeAt(index);
    notifyListeners();
  }

  ///Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _tempPickedImage = File(image.path);
        notifyListeners();
        debugPrint("Image picked: ${_tempPickedImage!.path}");
        return _tempPickedImage; // return the file
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    return null;
  }

  Future<File?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        return file;
      }
    } catch (e) {
      debugPrint("Error picking PDF: $e");
    }
    return null;
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        final file = File(image.path);

        _pickedImage = file;
        notifyListeners();

        debugPrint("Image picked: ${file.path}");
        debugPrint("Image size: ${file.lengthSync()} bytes");

        return file; // ✅ IMPORTANT
      } else {
        debugPrint("No image selected.");
        return null; // ✅ IMPORTANT
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      return null; // ✅ IMPORTANT
    }
  }

  Future<void> pickSingleImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _pickedImages.clear();
        _pickedImages.add(image);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future pickSingleImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        _pickedImages.clear();
        _pickedImages.add(image);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  ///Pick Multiple Images from gallery
  Future<void> pickMultipleImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        _pickedImages.addAll(images);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking multiple images: $e");
    }
  }

  Future<File?> sanitizeToJpeg(File rawFile) async {
    try {
      // 1. Read bytes & decode original image (handles HEIC, WebP, PNG, etc.)
      final bytes = await rawFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) return null;

      // 2. Force re-encode to true JPG standard
      final jpgBytes = img.encodeJpg(decodedImage, quality: 85);

      // 3. Save to a clean temporary file with a clear .jpg extension
      final tempDir = await getTemporaryDirectory();
      final sanitizedFile = File('${tempDir.path}/clean_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg');

      return await sanitizedFile.writeAsBytes(jpgBytes);
    } catch (e) {
      debugPrint("Failed to sanitize image: $e");
      return rawFile; // Fallback to raw file if decoding fails
    }
  }

  ///Login Api
  Future<void> loginApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      final response = await authRepository.login(data);

      final status = response["status"].toString();
      final success = response["success"] ?? "Login failed";

      if (status == "1") {
        Utils.toastMessage(success);

        _user = LoginModel.fromJson(response).user;
        if (_user != null) {
          await saveUserData(_user!);
          debugPrint("User data: $_user");

          // Save pending status info locally inside Provider state
          pendingSubStatus = _user!.status.toString().toLowerCase();
          pendingPlanId = _user!.planId;
          pendingUserId = _user!.id.toString();

          if (context.mounted) {
            await verifyEmailApi(context, {
              "email": _user!.email,
            }, fromLogin: true);
          }
        }
      } else {
        Utils.toastMessage(success);
      }
    } catch (e, stackTrace) {
      debugPrint("Login error: $e\n$stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Verify Email

  Future<void> verifyEmailApi(
    BuildContext context,
    dynamic data, {
    bool fromLogin = false,
  }) async {
    loading = true;
    try {
      debugPrint("Send OTP data: $data");

      final response = await authRepository.verifyEmail(data);
      debugPrint("Send OTP API Response: $response");

      if (response["status"].toString() == "1") {
        // ✅ Success
        Utils.toastMessage(response["success"]);
        final String email = data['email'];

        context.goNamed(
          'verifyOtp',
          extra: {"email": email, "fromLogin": fromLogin},
        );
      } else {
        String message = "";
        if (response["success"] is String) {
          message = response["success"];
        } else if (response["success"] is Map) {
          final errors = response["success"];
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          } else {
            message = firstError.toString();
          }
        } else {
          message = "Something went wrong.";
        }
        Utils.toastMessage(message);
      }
    } catch (e, stackTrace) {
      debugPrint("Send OTP error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///verify otp

  Future<void> verifyOtpApi(
    BuildContext context,
    dynamic data, {
    bool fromLogin = false,
  }) async {
    loading = true;
    try {
      debugPrint("Verify OTP data: $data");

      final response = await authRepository.verifyOtp(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        final String email = data['email'];

        if (fromLogin) {
          // ✅ Save login state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isLoggedIn", true);
          await prefs.setBool("isOtpVerified", true);

          // Extract subStatus, planId, and userId
          final String subStatus =
              pendingSubStatus ??
              _user?.status.toString().toLowerCase() ??
              'unpaid';

          final int planId = pendingPlanId ?? _user?.planId ?? 1;
          final String? userId = pendingUserId ?? _user?.id.toString();

          if (context.mounted) {
            if (subStatus == 'unpaid') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PlanSummaryScreen(planId: planId, userId: userId),
                ),
                (route) => false,
              );
            } else {
              // 🟢 ACTIVE/PAID: Fetch plan details and navigate to dashboard
              await context.read<PricingPlansViewModel>().myPlansApi(context);

              if (context.mounted) {
                context.goNamed('bottomNavBar', extra: {"initialIndex": 0});
              }
            }
          }
        } else {
          // Forgot password flow
          context.pushNamed('resetPassword', extra: email);
        }
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("Verify OTP API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Verify OTP error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Resend Otp
  Future<void> resendOtpApi(BuildContext context, dynamic data) async {
    resend = true;
    try {
      debugPrint("resend otp  data: $data");

      final response = await authRepository.resendOtp(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Resend Otp API Response: $response");
      }
    } catch (e) {
      debugPrint("Resend Otp error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      resend = false;
    }
  }

  ///Reset Password

  Future<void> resetPasswordApi(BuildContext context, dynamic data) async {
    loading = true;
    try {
      debugPrint("Reset Password  data: $data");

      final response = await authRepository.resetPassword(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        context.pushNamed('login');
      } else {
        Utils.toastMessage(response["success"]);
      }
      if (kDebugMode) {
        debugPrint("Reset password  API Response: $response");
      }
    } catch (e) {
      debugPrint("Reset password Otp error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Tax Professional Reg Api

  Future<void> taxProfessionalRegApi(
    BuildContext context,
    dynamic data,
    Function(String userId)? onSuccess,
  ) async {
    loading = true;
    try {
      debugPrint("Reset Password data: $data");

      final response = await authRepository.taxProfessionalRegRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        final userId = response["user"]["id"].toString();
        if (onSuccess != null) {
          onSuccess(userId);
        }
      } else {
        // ✅ Handle string or map error formats properly
        final success = response["success"];
        if (success is String) {
          Utils.toastMessage(success);
        } else if (success is Map<String, dynamic>) {
          final firstKey = success.keys.first;
          final firstError = success[firstKey];
          final message =
              (firstError is List && firstError.isNotEmpty)
                  ? firstError.first.toString()
                  : "Something went wrong";
          Utils.toastMessage(message);
        } else {
          Utils.toastMessage("Unexpected error format.");
        }
      }

      if (kDebugMode) {
        debugPrint("Tax Professional API Response: $response");
      }
    } catch (e) {
      debugPrint("Tax Professional error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Client Plan Reg Api

  Future<void> clientPlanRegApi(
    BuildContext context,
    dynamic data,
    Function(String userId)? onSuccess,
  ) async {
    loading = true;
    try {
      debugPrint("client plan reg data: $data");

      final response = await authRepository.clientPlanRegRepo(data);

      if (response["status"].toString() == "1") {
        // ✅ Success case
        Utils.toastMessage(response["success"]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", false);
        await prefs.remove("user");
        final userId = response["user"]["id"].toString();
        if (onSuccess != null) {
          onSuccess(userId);
        }
      } else {
        // ✅ Error handling for all cases
        if (response.containsKey("success")) {
          final success = response["success"];
          if (success is String) {
            Utils.toastMessage(success);
          } else if (success is Map<String, dynamic>) {
            final firstKey = success.keys.first;
            final firstError = success[firstKey];
            final message =
                (firstError is List && firstError.isNotEmpty)
                    ? firstError.first.toString()
                    : "Something went wrong";
            Utils.toastMessage(message);
          } else {
            Utils.toastMessage("Unexpected error format.");
          }
        } else if (response is Map<String, dynamic>) {
          // ✅ Laravel-style validation errors (e.g. {email: [ ... ]})
          final firstKey = response.keys.first;
          final firstError = response[firstKey];
          final message =
              (firstError is List && firstError.isNotEmpty)
                  ? firstError.first.toString()
                  : firstError.toString();
          Utils.toastMessage(message);
        } else {
          Utils.toastMessage("Unexpected error format.");
        }
      }

      if (kDebugMode) {
        debugPrint("Client plan reg API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Client plan reg error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  ///Get User Profile Api

  Future<String?> getUserProfileApi(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      final response = await authRepository.getUserProfileRepo();

      if (response.status == 1) {
        _data = response.data;

        notifyListeners();

        return response.message;
      } else {
        return response.message;
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Update User Profile Api

  Future<void> updateProfileApi(
      BuildContext context,
      Map<String, dynamic> fields,
      File? avatarFile, {
        VoidCallback? onInvalidAvatar,
      }) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("==========================================");
      debugPrint("UPDATE PROFILE");
      debugPrint("Fields: $fields");
      debugPrint("Avatar: ${avatarFile?.path}");
      debugPrint("==========================================");

      final response =
      await authRepository.updateProfileRepo(
        fields: fields,
        avatarFile: avatarFile,
      );

      debugPrint(
        "Update Profile Response: $response",
      );


      // ============================================================
      // SAFETY CHECK
      // ============================================================

      if (response is! Map) {
        Utils.toastMessage(
          "Unexpected server response.",
        );
        return;
      }


      // ============================================================
      // RESPONSE STATUS
      // ============================================================

      final status =
      response["status"]?.toString();


      // ============================================================
      // ERROR RESPONSE
      // ============================================================

      if (status == "0") {
        final message = response["message"];


        // ----------------------------------------------------------
        // Avatar validation error
        // ----------------------------------------------------------

        if (message is Map &&
            message["avatar"] != null) {
          final avatarError =
          message["avatar"];

          String errorText =
              "Invalid avatar.";

          if (avatarError is List &&
              avatarError.isNotEmpty) {
            errorText =
                avatarError.first.toString();
          } else if (avatarError is String) {
            errorText = avatarError;
          }

          // Reset selected image in UI
          onInvalidAvatar?.call();

          Utils.toastMessage(
            errorText,
          );

          return;
        }


        // ----------------------------------------------------------
        // Other validation errors
        // ----------------------------------------------------------

        if (message is Map) {
          String? errorText;

          for (final value in message.values) {
            if (value is List &&
                value.isNotEmpty) {
              errorText =
                  value.first.toString();
              break;
            }

            if (value is String &&
                value.isNotEmpty) {
              errorText = value;
              break;
            }
          }

          Utils.toastMessage(
            errorText ?? "Something went wrong.",
          );

          return;
        }


        // ----------------------------------------------------------
        // String error
        // ----------------------------------------------------------

        if (message is String &&
            message.isNotEmpty) {
          Utils.toastMessage(
            message,
          );

          return;
        }


        Utils.toastMessage(
          "Something went wrong.",
        );

        return;
      }


      // ============================================================
      // SUCCESS
      // ============================================================

      if (status == "1") {
        await getUserProfileApi(context);

        final successMessage =
        response["message"];

        if (successMessage is String &&
            successMessage.isNotEmpty) {
          Utils.toastMessage(
            successMessage,
          );
        }


        // Navigate after profile update
        Future.microtask(() {
          if (!context.mounted) {
            return;
          }

          context.goNamed(
            "bottomNavBar",
          );

          BottomNavBar.of(context)
              ?.switchTab(0);
        });

        return;
      }


      // ============================================================
      // UNKNOWN STATUS
      // ============================================================

      final message =
      response["message"];

      if (message is String &&
          message.isNotEmpty) {
        Utils.toastMessage(
          message,
        );
      } else {
        Utils.toastMessage(
          "Unexpected server response.",
        );
      }
    } catch (e, st) {
      debugPrint(
        "Update Profile error: $e",
      );

      debugPrint(
        "$st",
      );

      Utils.toastMessage(
        "Error: ${e.toString()}",
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  ///Update settings api

  Future<void> updateSettingsApi(BuildContext context, dynamic data) async {
    updateSettings = true;
    try {
      debugPrint("Update Settings  data: $data");

      final response = await authRepository.updateSettingsRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);
        context.goNamed("bottomNavBar");
        BottomNavBar.of(context)?.switchTab(0);
      } else {
        Utils.toastMessage(response["message"]);
      }
      if (kDebugMode) {
        debugPrint("Update settings  API Response: $response");
      }
    } catch (e) {
      debugPrint("Update settings error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      updateSettings = false;
    }
  }

  ///Delete Account

  Future<void> deleteApi(BuildContext context) async {
    delete = true;
    try {
      final response = await authRepository.deleteAccountRepo();

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["message"]);

        // IMPORTANT: Clear login data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user');
        await prefs.setBool('isLoggedIn', false);

        // Or use prefs.clear() if you want to remove all data
        // await prefs.clear();

        context.goNamed("login");
      } else {
        Utils.toastMessage(response["message"]);
      }

      if (kDebugMode) {
        debugPrint("Delete API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Delete Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      delete = false;
    }
  }

  Future<void> handleSplash(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? userJson = prefs.getString('user');
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final bool isOtpVerified = prefs.getBool('isOtpVerified') ?? false;

      if (!isLoggedIn || userJson == null || userJson.isEmpty) {
        context.goNamed("login");
        return;
      }

      if (!isOtpVerified) {
        final user = User.fromJson(jsonDecode(userJson));
        context.goNamed(
          "verifyOtp",
          extra: {"email": user.email, "fromLogin": true},
        );
        return;
      }

      // Set local instance
      _user = User.fromJson(jsonDecode(userJson));

      // Optional: Fetch fresh profile status from API to guarantee accurate state
      // await getProfileApi();

      notifyListeners();

      final String subStatus = _user?.status?.toString().toLowerCase() ?? 'unpaid';

      if (subStatus == 'unpaid') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PlanSummaryScreen(
              planId: _user?.planId ?? 1,
              userId: _user?.id.toString(),
            ),
          ),
              (route) => false,
        );
      } else {
        await context.read<PricingPlansViewModel>().myPlansApi(context);

        if (context.mounted) {
          context.goNamed("bottomNavBar");
          BottomNavBar.of(context)?.switchTab(0);
        }
      }
    } catch (e) {
      debugPrint("Splash handling error: $e");
      context.goNamed("login");
    }
  }

  // Future<void> handleSplash(BuildContext context) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     final String? userJson = prefs.getString('user');
  //
  //     final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //
  //     final bool isOtpVerified = prefs.getBool('isOtpVerified') ?? false;
  //
  //     debugPrint("isLoggedIn: $isLoggedIn");
  //
  //     debugPrint("isOtpVerified: $isOtpVerified");
  //
  //     debugPrint("userJson: $userJson");
  //
  //     /// ❌ Not logged in
  //
  //     if (!isLoggedIn || userJson == null || userJson.isEmpty) {
  //       context.goNamed("login");
  //
  //       return;
  //     }
  //
  //     /// ⚠️ OTP not verified
  //
  //     if (!isOtpVerified) {
  //       final user = User.fromJson(jsonDecode(userJson));
  //
  //       context.goNamed(
  //         "verifyOtp",
  //
  //         extra: {"email": user.email, "fromLogin": true},
  //       );
  //
  //       return;
  //     }
  //
  //     /// ✅ Fully logged in
  //
  //     _user = User.fromJson(jsonDecode(userJson));
  //
  //     notifyListeners();
  //
  //     context.goNamed("bottomNavBar");
  //
  //     BottomNavBar.of(context)?.switchTab(0);
  //   } catch (e) {
  //     debugPrint("Splash handling error: $e");
  //
  //     context.goNamed("login");
  //   }
  // }

  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Backup persistent app flags BEFORE clearing
      final savedLocale = prefs.getString('saved_locale');
      final isFirstLaunch = prefs.getBool('firstLaunch') ?? false;

      await clearWebSession();

      // 2. Clear all user info
      await prefs.clear();

      // 3. Restore non-session app settings
      if (savedLocale != null) {
        await prefs.setString('saved_locale', savedLocale);
      }
      await prefs.setBool('firstLaunch', isFirstLaunch);

      // Reset bottom nav state
      BottomNavBar.globalKey.currentState?.resetState();

      debugPrint("User logged out successfully");
      Utils.toastMessage("Logged out successfully");

      // Navigate to login page
      context.goNamed("login");
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  Future<void> clearWebSession() async {
    final cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
  }
}
