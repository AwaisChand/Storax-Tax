import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:storatax/view_models/account_client_view_model/accountant_client_view_model.dart';
import 'package:storatax/view_models/dashboard_view_model/dashboard_view_model.dart';
import 'package:storatax/view_models/gasoline_view_model/gasoline_view_model.dart';
import 'package:storatax/view_models/quebec_view_model/quebec_view_model.dart';
import 'package:storatax/view_models/rental_property_view_model/rental_property_view_model.dart';
import 'package:storatax/view_models/tax_manager_view_model/tax_manager_view_model.dart';
import 'package:storatax/view_models/team_member_view_model/team_member_view_model.dart';
import 'package:storatax/view_models/viewrs_view_model/viewrs_view_model.dart';

import '../view_models/auth_view_model/auth_view_model.dart';
import '../view_models/pricing_plans_view_model/pricing_plans_view_model.dart';

List<SingleChildWidget> providers = [...independentProviders];
List<SingleChildWidget> independentProviders = [
  ChangeNotifierProvider(create: (_) => AuthViewModel()),
  ChangeNotifierProvider(create: (_) => PricingPlansViewModel()),
  ChangeNotifierProvider(create: (_) => AccountantClientViewModel()),
  ChangeNotifierProvider(create: (_) => TaxManagerViewModel()),
  ChangeNotifierProvider(create: (_) => GasolineViewModel()),
  ChangeNotifierProvider(create: (_) => RentalPropertyViewModel()),
  ChangeNotifierProvider(create: (_) => QuebecViewModel()),
  ChangeNotifierProvider(create: (_) => ViewrsViewModel()),
  ChangeNotifierProvider(create: (_) => TeamMemberViewModel()),
  ChangeNotifierProvider(create: (_) => DashboardViewModel()),






];
