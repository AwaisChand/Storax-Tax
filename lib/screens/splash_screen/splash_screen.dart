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

  /// VERSION CHECK
  Future<void> _checkVersion() async {
    final newVersion = NewVersionPlus(
      androidId: "com.storatax.app",
      iOSId: "6760159336",
    );

    try {
      final status = await newVersion.getVersionStatus();

      debugPrint("Store Version: ${status?.storeVersion}");
      debugPrint("Local Version: ${status?.localVersion}");

      if (!mounted) return;

      // Forces update for ANY version increment (1.0.0 -> 1.0.1, 1.1.0, 2.0.0, etc.)
      if (status != null && status.canUpdate) {
        _versionStatus = status;
        setState(() {
          _forceUpdate = true;
        });
      } else {
        _goNext();
      }
    } catch (e) {
      debugPrint("Version check error: $e");
      _goNext();
    }
  }

  /// NORMAL FLOW
  void _goNext() {
    context.read<AuthViewModel>().handleSplash(context);
  }

  /// OPEN STORE (Cross-platform safe)
  Future<void> _openStore() async {
    if (_versionStatus == null) return;

    final url = Uri.parse(_versionStatus!.appStoreLink);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for strict iOS URL schemes
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Could not open store link: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _forceUpdate ? _buildForceUpdateUI() : _buildSplashUI(),
    );
  }

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

  Widget _buildForceUpdateUI() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundImg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const Spacer(),
                // Central Icon + Text Container
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.system_update,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Time to Update!",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "To ensure your account stays secure and up to date, please install the latest version of Storatax.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Bottom Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openStore,
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: Text(
                      "Update Application",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}