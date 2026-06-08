import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storatax/screens/support_tickets/widgets/feature_dropdown_widget.dart';
import 'package:storatax/screens/support_tickets/widgets/top_button_widget.dart';

import '../../../res/app_assets.dart';
import '../../../res/components/app_drawer.dart';
import '../../../res/components/app_localization.dart';
import '../../../utils/utils.dart';
import '../../../view_models/rental_property_view_model/rental_property_view_model.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() =>
      _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: CustomAppBar(
        text1:
        AppLocalizations.of(context)!.translate("createTicketSText") ??
            '',
        text2: AppLocalizations.of(context)!.translate("createTicketSText") ?? '',
        drawerTapped: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          try {
            final provider = context.read<RentalPropertyViewModel>();
            provider.getRentalPropertyPlanApi(context);
          } catch (e) {
            debugPrint("Drawer API error: $e");
          }
        }
      },
      body: Stack(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CreateTicketForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
