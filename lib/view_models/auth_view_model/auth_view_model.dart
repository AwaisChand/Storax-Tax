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

import '../../models/login_model/login_model.dart';
import '../../repository/auth_repository/auth_repository.dart';
import '../../screens/bottom_nav_bar/bottom_nav_bar.dart';
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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
          // Future.microtask(() {
          //   context.goNamed("bottomNavBar");
          //   BottomNavBar.of(context)?.switchTab(0);
          // });
          await verifyEmailApi(context, {
            "email": _user!.email,
          }, fromLogin: true);
          // Navigator.pushNamed(context, RoutesNames.dashboard);
          await context.read<PricingPlansViewModel>().myPlansApi(context);
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
    bool fromLogin = false, // ✅ Add this flag
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

          // ✅ Navigate to dashboard
          context.goNamed(
            'bottomNavBar',
            extra: {"initialIndex": 0},
          );
        } else {
          // Forgot password flow
          context.pushNamed(
            'resetPassword',
            extra: email,
          );
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
    VoidCallback? onInvalidAvatar, // ⭐ callback from UI
  }) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("Update Profile fields: $fields");
      debugPrint("Avatar file: ${avatarFile?.path}");

      final response = await authRepository.updateProfileRepo(
        fields: fields,
        avatarFile: avatarFile,
      );

      // ⛔ HANDLE INVALID AVATAR FORMAT FIRST
      if (response["status"].toString() == "0") {
        final msg = response["message"];

        if (msg is Map && msg["avatar"] != null) {
          // 🔥 Reset picked image in UI
          onInvalidAvatar?.call();

          Utils.toastMessage(msg["avatar"][0].toString());
          loading = false;
          notifyListeners();
          return;
        }
      }

      // ✔ SUCCESS
      if (response["status"].toString() == "1") {
        await getUserProfileApi(context);
        Utils.toastMessage(response["message"]);

        Future.microtask(() {
          context.goNamed("bottomNavBar");
          BottomNavBar.of(context)?.switchTab(0);
        });
      }

      // 🔁 DEFAULT MESSAGE HANDLING
      final message = response["message"];
      if (message is String) {
        Utils.toastMessage(message);
      } else if (message is Map<String, dynamic>) {
        final firstKey = message.keys.first;
        final firstError = message[firstKey];
        final errorMessage =
            (firstError is List && firstError.isNotEmpty)
                ? firstError.first.toString()
                : "Something went wrong";
        Utils.toastMessage(errorMessage);
      } else {
        Utils.toastMessage("Unexpected error format.");
      }

      if (kDebugMode) {
        debugPrint("Update Profile API Response: $response");
      }
    } catch (e) {
      debugPrint("Update Profile error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
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

      // No login
      if (!isLoggedIn || userJson == null || userJson.isEmpty) {
        await Future.delayed(const Duration(seconds: 1));
        context.goNamed("login");
        return;
      }

      // Logged in but OTP NOT verified
      if (isLoggedIn && !isOtpVerified) {
        final user = User.fromJson(jsonDecode(userJson));

        await Future.delayed(const Duration(seconds: 1));

        context.goNamed(
          "verifyOtp",
          extra: {
            "email": user.email,
            "fromLogin": true,
          },
        );
        return;
      }

      // Fully authenticated
      _user = User.fromJson(jsonDecode(userJson));
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      context.goNamed("bottomNavBar");
      BottomNavBar.of(context)?.switchTab(0);
    } catch (e) {
      debugPrint("Splash handling error: $e");
      context.goNamed("login");
    }
  }
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Backup language BEFORE clearing everything
      final savedLocale = prefs.getString('saved_locale');
      await clearWebSession();
      // 2. Clear all other user info
      await prefs.clear();

      // 3. Restore language back
      if (savedLocale != null) {
        await prefs.setString('saved_locale', savedLocale);
      }

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
