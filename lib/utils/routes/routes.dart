import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:storatax/screens/auth_screens/login_screen/login_screen.dart';
import 'package:storatax/screens/auth_screens/manage_setting/manage_setting_screen.dart';
import 'package:storatax/screens/auth_screens/reset_password/reset_password_screen.dart';
import 'package:storatax/screens/auth_screens/user_profile/user_profile_screen.dart';
import 'package:storatax/screens/auth_screens/verify_email/verify_email_screen.dart';
import 'package:storatax/screens/auth_screens/verify_otp/verify_otp_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/Gasoline/gasoline_screens/gasoline_list_screen/gasoline_list_screen/gasoline_list_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/team_members/team_member_screens/create_team_member/create_team_member_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/team_members/team_member_screens/view_team_members/view_team_member_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/uber_quebec/uber_quebec_screens/quebec_create_screens/form_submitted_screen.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/viewrs_permission/create_new_viewrs_permission/create_new_viewrs_permission.dart';
import 'package:storatax/screens/bottom_nav_bar/bottom_nav_bar_screens/viewrs_permission/view_list_permission/view_list_permission_screen.dart';
import 'package:storatax/screens/plan_summary_screen/my_plans_screen.dart';
import 'package:storatax/screens/dashboard/dashboard_screen.dart';
import 'package:storatax/screens/plan_summary_screen/more_plan_summary_screen.dart';
import 'package:storatax/screens/pricing_plans/get_more_plans/get_more_plans_screen.dart';
import 'package:storatax/screens/select_tax_professional/select_tax_professional_screen.dart';
import 'package:storatax/screens/files/create_tax_manager/create_tax_manager_screen.dart';
import 'package:storatax/screens/files/get_files/get_files_screen.dart';
import 'package:storatax/screens/splash_screen/splash_screen.dart';

import '../../screens/bottom_nav_bar/bottom_nav_bar_screens/rental_property/rental_property_screens/entry/entry_screens/all_regular_entry_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashScreen(),
      ),

      /// Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verifyEmail',
        builder:
            (context, state) =>
                VerifyEmailScreen(fromLogin: state.extra as bool),
      ),
      GoRoute(
        path: '/verify-otp',
        name: 'verifyOtp',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return VerifyOtpScreen(
            fromLogin: args["fromLogin"] ?? false,
            email: args["email"] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder:
            (context, state) =>
                ResetPasswordScreen(email: state.extra as String),
      ),
      GoRoute(
        path: '/user-profile',
        name: 'userProfile',
        builder: (context, state) => UserProfileScreen(),
      ),
      GoRoute(
        path: '/manage-setting',
        name: 'manageSetting',
        builder: (context, state) => ManageSettingScreen(),
      ),
      GoRoute(
        path: '/select-tax-professional',
        name: 'selectTaxProfessional',
        builder: (context, state) => SelectTaxProfessionalScreen(),
      ),
      // GoRoute(
      //   path: '/tax-professional',
      //   name: 'taxProfessional',
      //   builder: (context, state) => TaxProfessionalScreen(),
      // ),
      GoRoute(
        path: '/more-plans',
        name: 'morePlans',
        builder: (context, state) => GetMorePlansScreen(),
      ),
      GoRoute(
        path: '/my-plans',
        name: 'myPlans',
        builder: (context, state) => MyPlansScreen(),
      ),
      GoRoute(
        path: '/more-plan-summary',
        name: 'morePlanSummary',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return MorePlanSummaryScreen(
            planId: args['plan_id'],
            couponId: args['coupon_code'],
          );
        },
      ),

      GoRoute(
        path: '/plan-summary',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;

          return MorePlanSummaryScreen(
            planId: data?['planId'],
            couponId: data?['couponId'],
            discountedPrice: data?['discountedPrice'],
            discountAmount: data?['discountAmount'],
            code: data?['code'],
            discountedValue: data?['discountedValue'],
          );
        },
      ),
      GoRoute(
        name: "allRegularEntries",
        path: '/regular-entries',
        builder: (context, state) {
          final planId = state.extra as int;
          return AllRegularEntryScreen(planId: planId);
        },
      ),

      /// BottomNavBar as a parent route
      GoRoute(
        path: '/bottom-nav',
        name: 'bottomNavBar',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return BottomNavBar(initialIndex: args?['initialIndex'] ?? 0);
        },
        routes: [
          // Nested routes inside BottomNavBar
          GoRoute(
            path: 'dashboard',
            name: 'dashboard',
            builder: (context, state) => DashboardScreen(),
          ),
          GoRoute(
            path: 'team-members',
            name: 'viewTeamMember',
            builder: (context, state) => ViewTeamMembersScreen(),
          ),
          GoRoute(
            path: 'view-permissions',
            name: 'allViewrs',
            builder: (context, state) => ViewListPermissionScreen(),
          ),
          GoRoute(
            path: 'create-viewrs',
            name: 'createViewrs',
            builder: (context, state) => CreateNewViewrPermissionScreen(),
          ),
          GoRoute(
            path: 'create-team',
            name: 'createTeam',
            builder: (context, state) => CreateTeamMemberScreen(),
          ),
          GoRoute(
            path: 'team-member',
            name: 'teamMember',
            builder: (context, state) => ViewTeamMembersScreen(),
          ),
          GoRoute(
            path: 'my-plans',
            name: 'myPlansNested',
            builder: (context, state) => MyPlansScreen(),
          ),
          GoRoute(
            path: 'gasoline-screen', // ✅ no leading slash
            name: 'gasolineScreen',
            builder: (context, state) => GasolineListScreen(),
          ),
        ],
      ),

      /// Other independent routes
      GoRoute(
        path: '/create-tax-manager',
        name: 'createTaxManager',
        builder: (context, state) => CreateTaxManagerScreen(),
      ),
      GoRoute(
        path: '/get-files',
        name: 'getFiles',
        builder: (context, state) => GetFilesScreen(),
      ),
      GoRoute(
        path: '/form-submitted',
        name: 'formSubmitted',
        builder: (context, state) => FormSubmittedScreen(),
      ),
    ],
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('No route defined'))),
  );
}
