import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/app_assets.dart';
import '../../res/components/app_drawer.dart';
import '../../res/components/app_localization.dart';
import '../../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

import '../dashboard/dashboard_screen.dart';
import 'bottom_nav_bar_screens/Gasoline/gasoline_screens/gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';
import 'bottom_nav_bar_screens/rental_property/rental_property_screens/rental_property_tab_screen/rental_property_tab_screen.dart';
import 'bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/gst_qst_reporting_screen/gst_qst_reporting_screen.dart';
import '../files/get_files/get_files_screen.dart';

class BottomNavBar extends StatefulWidget {
  static final GlobalKey<_BottomNavBarState> globalKey =
      GlobalKey<_BottomNavBarState>();

  final int initialIndex;

  const BottomNavBar({super.key, this.initialIndex = 0});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();

  static _BottomNavBarState? of(BuildContext context) {
    return globalKey.currentState ??
        context.findAncestorStateOfType<_BottomNavBarState>();
  }
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  late int _selectedIndex;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [];

  List<String> activePlans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshTabs();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground
      refreshTabs();
    }
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    refreshTabs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Refresh tabs dynamically
  Future<void> refreshTabs() async {
    final plansVM = context.read<PricingPlansViewModel>();

    // 1️⃣ Load plans if not loaded
    if (plansVM.myPlans.isEmpty) {
      await plansVM.myPlansApi(context);
      if (!mounted) return;
    }

    final plans = plansVM.myPlans;

    // 2️⃣ Normalize plan names (lowercase + trimmed)
    final List<String> planNames =
        plans
            .map(
              (p) =>
                  (p.name ?? "")
                      .toLowerCase()
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim(),
            )
            .where((name) => name.isNotEmpty)
            .toList();

    // 3️⃣ Construct activePlans cleanly
    final List<String> newActivePlans = [];

    // --- GAS RECEIPTS MANAGER ---
    final hasGas = planNames.any((n) => n.contains("gas receipts manager"));
    if (hasGas) {
      if (planNames.any(
        (n) => n.contains("free version") || n.contains("basic"),
      )) {
        newActivePlans.add("gas receipts manager - basic");
      } else if (planNames.any(
        (n) => n.contains("business version") || n.contains("enterprise"),
      )) {
        newActivePlans.add("gas receipts manager - enterprise");
      } else if (planNames.any(
        (n) => n.contains("unlimited version") || n.contains("pro"),
      )) {
        newActivePlans.add("gas receipts manager - pro");
      } else {
        newActivePlans.add("gas receipts manager");
      }
    }

    // --- TAX MANAGER ---
    final businessTax = planNames.any(
      (n) => n.contains("business tax manager"),
    );
    final normalTax = planNames.any((n) => n.contains("tax manager"));
    if (businessTax) {
      newActivePlans.add("business tax manager");
    } else if (normalTax) {
      newActivePlans.add("tax manager");
    }

    // --- QUEBEC REPORTING ---
    if (planNames.any(
      (n) =>
          n.contains("quebec") ||
          n.contains("qst reporting") ||
          n.contains("uber gst/qst reporting"),
    )) {
      newActivePlans.add("quebec reporting");
    }

    // --- RENTAL PROPERTY ---
    if (planNames.any((n) => n.contains("rental property manager"))) {
      newActivePlans.add("rental property manager");
    }

    // 4️⃣ Reset navigator keys if plans changed
    if (!listEquals(activePlans, newActivePlans)) {
      _navigatorKeys.clear();
      for (int i = 0; i < newActivePlans.length + 1; i++) {
        _navigatorKeys.add(GlobalKey<NavigatorState>());
      }
      // Reset selected index to first tab
      _selectedIndex = 0;
    }

    setState(() {
      activePlans = newActivePlans;
    });

    if (_selectedIndex >= activePlans.length + 1) {
      _selectedIndex = activePlans.length;
    }
  }

  void switchTab(int index) {
    final navigator = _navigatorKeys[index].currentState;
    if (navigator != null) {
      navigator.popUntil((route) => route.isFirst);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Call this from Drawer to reset to Dashboard
  void goToDashboard() {
    switchTab(0);
  }

  @override
  Widget build(BuildContext context) {
    // Screens
    final List<Widget> screens = [const DashboardScreen()];
    final List<String> labels = [
      AppLocalizations.of(context)!.translate("dashboardText") ?? '',
    ];
    final List<String> icons = [AppAssets.gasolineIcon];

    for (final plan in activePlans) {
      final planLower = plan.toLowerCase();

      if (planLower.contains("gas receipts manager")) {
        screens.add(const GasolineListScreen());

        String gasLabel = "Gasoline";

        if (planLower.contains("free version") || planLower.contains("basic")) {
          gasLabel =
              AppLocalizations.of(context)!.translate("gasolineBasicText") ??
              '';
        } else if (planLower.contains("business version") ||
            planLower.contains("enterprise")) {
          gasLabel =
              AppLocalizations.of(
                context,
              )!.translate("gasolineEnterpriseText") ??
              '';
        } else if (planLower.contains("unlimited version") ||
            planLower.contains("pro")) {
          gasLabel =
              AppLocalizations.of(context)!.translate("gasolineProText") ?? '';
        }

        labels.add(gasLabel);
        icons.add(AppAssets.gasolineIcon);
      }

      if (planLower.contains("tax manager")) {
        screens.add(const GetFilesScreen());

        if (planLower.contains("business tax manager")) {
          labels.add(
            AppLocalizations.of(context)!.translate("businessTaxManagerText") ??
                '',
          );
        } else {
          labels.add(
            AppLocalizations.of(context)!.translate("taxManagerText") ?? '',
          );
        }

        icons.add(AppAssets.businessTaxIcon);
      }

      if (planLower.contains("quebec") ||
          planLower.contains("qst reporting") ||
          planLower.contains("uber gst/qst reporting")) {
        screens.add(const GstQstReportingScreen());
        labels.add(AppLocalizations.of(context)!.translate("quebecText") ?? '');
        icons.add(AppAssets.businessTaxIcon);
      }

      if (planLower.contains("rental property manager")) {
        screens.add(const RentalPropertyTabScreen());
        labels.add(
          AppLocalizations.of(context)!.translate("rentalPropertyText") ?? '',
        );
        icons.add(AppAssets.rentalPropertyIcon);
      }
    }

    _selectedIndex = _selectedIndex.clamp(0, screens.length - 1);

    while (_navigatorKeys.length < screens.length) {
      _navigatorKeys.add(GlobalKey<NavigatorState>());
    }

    return WillPopScope(
      onWillPop: () async {
        final navigator = _navigatorKeys[_selectedIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        drawer: const AppDrawer(),
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(
            screens.length,
            (i) => Navigator(
              key: _navigatorKeys[i],
              onGenerateInitialRoutes:
                  (_, __) => [MaterialPageRoute(builder: (_) => screens[i])],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB5E0F7), Color(0xFF38A7DB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(labels.length, (index) {
                  final isSelected = _selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onItemTapped(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Image.asset(
                              icons[index],
                              height: 24,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2), // reduced spacing
                          Flexible(
                            child: Text(
                              labels[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                              maxLines: 1, // prevent overflow
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              height: 2,
                              width: 30,
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetState() {
    setState(() {
      activePlans = [];
      _navigatorKeys.clear();
      _selectedIndex = 0;
    });
  }
}
