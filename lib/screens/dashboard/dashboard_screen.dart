import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:storatax/res/components/app_drawer.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/utils/utils.dart';
import 'package:storatax/view_models/auth_view_model/auth_view_model.dart';
import 'package:storatax/view_models/dashboard_view_model/dashboard_view_model.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';

import '../../res/app_assets.dart';
import '../../res/components/app_localization.dart';
import '../bottom_nav_bar/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<AuthViewModel>();
      await provider.getUserProfileApi(context);

      if (!mounted) return;
      final dashboard = context.read<DashboardViewModel>();
      dashboard.getDashboardApi(context);
    });
  }

  /// Pull-to-refresh for dashboard only
  Future<void> _onRefresh() async {
    final bottomNavState = BottomNavBar.of(context);
    if (bottomNavState != null) {
      await bottomNavState.refreshTabs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthViewModel>();
    return Consumer<DashboardViewModel>(
      builder: (context, dashboard, _) {
        return Scaffold(
          key: _scaffoldKey,
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              final provider = context.read<RentalPropertyViewModel>();
              provider.getRentalPropertyPlanApi(context);
            }
          },
          drawer: AppDrawer(),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            displacement: 80,
            color: Colors.blue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: Utils.setHeight(context),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAssets.backgroundImg),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Image(image: AssetImage(AppAssets.dashboardColoredImg)),
                    Positioned(
                      top: 40,
                      left: 20,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            child: Image(
                              image: AssetImage(AppAssets.menuIcon),
                              fit: BoxFit.cover,
                              height: 15,
                            ),
                          ),
                          Image(
                            image: AssetImage(AppAssets.storaTaxImg),
                            fit: BoxFit.cover,
                            height: 55,
                          ),
                          PopupMenuButton<int>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            color: Colors.white,
                            elevation: 8,
                            onSelected: (value) {
                              switch (value) {
                                case 1:
                                  context.pushNamed("userProfile");
                                  break;
                                case 2:
                                  context.pushNamed("manageSetting");
                                  break;
                                case 3:
                                  context.pushNamed("selectTaxProfessional");
                                  break;
                                case 4:
                                  authProvider.logout(context);
                                  break;
                              }
                            },
                            itemBuilder: (context) {
                              if (authProvider.user?.role == 'viewer') {
                                return [
                                  PopupMenuItem(
                                    value: 0,
                                    enabled: false,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  authProvider.data?.avatar ??
                                                  '',
                                              placeholder:
                                                  (context, url) =>
                                                      const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          (authProvider.data == null)
                                              ? "Guest User"
                                              : (authProvider.data!.role
                                                              .toLowerCase() ==
                                                          "viewer" ||
                                                      authProvider.data!.role
                                                              .toLowerCase() ==
                                                          "team"
                                                  ? (authProvider
                                                      .data!
                                                      .firstName)
                                                  : "${authProvider.data!.firstName} ${authProvider.data!.lastName ?? ''}"),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 4,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Logout",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ];
                              } else {
                                final List<PopupMenuEntry<int>> items = [
                                  PopupMenuItem(
                                    value: 0,
                                    enabled: false,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  authProvider.data?.avatar ??
                                                  '',
                                              placeholder:
                                                  (context, url) =>
                                                      const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            Colors.grey,
                                                        child: Icon(
                                                          Icons.person,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          authProvider.data != null
                                              ? "${authProvider.data!.firstName} ${authProvider.data!.lastName ?? ''}"
                                              : "Guest User",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate(
                                                "manageProfileText",
                                              ) ??
                                              '',
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate(
                                                "manageSettingsText",
                                              ) ??
                                              '',
                                        ),
                                      ],
                                    ),
                                  ),
                                ];

                                if (authProvider.user?.role == "client") {
                                  items.add(
                                    PopupMenuItem(
                                      value: 3,
                                      child: Row(
                                        children: [
                                          Icon(Icons.groups, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(
                                                  context,
                                                )!.translate(
                                                  "taxProfessionalText",
                                                ) ??
                                                '',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                items.addAll([
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 4,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                                context,
                                              )!.translate("logoutText") ??
                                              '',
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);

                                return items;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: Utils.setHeight(context) * 0.16,
                      left: 20,
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )!.translate("dashboardText") ??
                            '',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Positioned(
                      top: Utils.setHeight(context) * 0.23,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child:
                                dashboard.getDashboardModel == null
                                    ? _shimmerWidget(context)
                                    : _stackWidget(
                                      "${AppLocalizations.of(context)!.translate("filesTotalText") ?? ''} ${dashboard.getDashboardModel?.data?.fileCount}",
                                      AppAssets.filesImg,
                                    ),
                          ),

                          if (authProvider.user?.role != 'viewer' &&
                              authProvider.user?.role != 'team')
                            Expanded(
                              child:
                                  dashboard.getDashboardModel == null
                                      ? _shimmerWidget(context)
                                      : _stackWidget(
                                        "${AppLocalizations.of(context)!.translate("subscTotalText") ?? ''} ${dashboard.getDashboardModel?.data?.subscriptionCount}",
                                        AppAssets.subscriptionsImg,
                                      ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _stackWidget(String text, String img) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: Utils.setHeight(context) * 0.28,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(AppAssets.dashboardBoxImg),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(right: 30, top: 30, child: Image.asset(img, height: 40)),
            Positioned(
              bottom: 16,
              left: 25,
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerWidget(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: Utils.setHeight(context) * 0.28,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.white,
        ),
      ),
    );
  }
}
