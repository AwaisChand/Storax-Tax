import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_version_plus/model/version_status.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';
import 'package:storatax/res/app_assets.dart';
import 'package:storatax/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../view_models/auth_view_model/auth_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VersionStatus? _versionStatus;
  bool _forceUpdate = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  /// 🔥 VERSION CHECK
  Future _checkVersion() async {
    final newVersion = NewVersionPlus(
      androidId: "com.storatax.app",
      iOSId: "123456789",
    );

    try {
      final status = await newVersion.getVersionStatus();

      // 👉 ADD PRINTS HERE
      print("Store Version: ${status?.storeVersion}");
      print("Local Version: ${status?.localVersion}");

      if (!mounted) return;

      if (status != null && status.canUpdate) {
        _versionStatus = status;

        final localVersion = status.localVersion;
        final storeVersion = status.storeVersion;

        final isForceUpdate =
        _shouldForceUpdate(localVersion, storeVersion);

        if (isForceUpdate) {
          setState(() {
            _forceUpdate = true;
          });
        } else {
          _showSoftUpdateDialog();
        }
      } else {
        _goNext();
      }
    } catch (e) {
      print("Version check error: $e");
      _goNext();
    }
  }

  /// Helper to check if a major update is required
  bool _shouldForceUpdate(String local, String store) {
    try {
      final localParts = local.split('.').map(int.parse).toList();
      final storeParts = store.split('.').map(int.parse).toList();

      // If the major version (first number) on store is higher, force the update
      if (storeParts.isNotEmpty && localParts.isNotEmpty) {
        if (storeParts[0] > localParts[0]) {
          return true;
        }
      }
    } catch (_) {
      // If parsing fails, default to soft update safety
    }
    return false;
  }

  /// ✅ NORMAL FLOW
  void _goNext() {
    context.read<AuthViewModel>().handleSplash(context);
  }

  /// 🔴 OPEN STORE
  Future<void> _openStore() async {
    if (_versionStatus == null) return;

    final url = Uri.parse(_versionStatus!.appStoreLink);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// 💬 SOFT UPDATE POPUP
  void _showSoftUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Update Available",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            "A new version of the app is available. Update for better experience.",
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _goNext();
              },
              child: Text(
                "Later",
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              onPressed: _openStore,
              child: Text(
                "Update",
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _forceUpdate ? _buildForceUpdateUI() : _buildSplashUI(),
    );
  }

  /// ✅ SPLASH UI
  Widget _buildSplashUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundImg),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Image(
          image: AssetImage(AppAssets.appLogo),
          height: Utils.setHeight(context) * 0.2,
        ),
      ),
    );
  }

  /// 🚨 FORCE UPDATE UI
  Widget _buildForceUpdateUI() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundImg),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                "Update Required",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "A new version of the app is available.\nPlease update to continue.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openStore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Update Now",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}