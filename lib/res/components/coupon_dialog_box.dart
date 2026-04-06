// // lib/res/components/coupon_dialog_box.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:storatax/utils/app_colors.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:storatax/view_models/pricing_plans_view_model/pricing_plans_view_model.dart';
//
// class CouponCodeDialog extends StatefulWidget {
//   final int planId;
//   final BuildContext rootContext; // 👈 Add this
//
//   const CouponCodeDialog({
//     super.key,
//     required this.planId,
//     required this.rootContext,
//   });
//
//   @override
//   State<CouponCodeDialog> createState() => _CouponCodeDialogState();
// }
//
// class _CouponCodeDialogState extends State<CouponCodeDialog> {
//   final TextEditingController _couponController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       contentPadding: const EdgeInsets.all(20),
//       title: Text(
//         'Enter Coupon Code',
//         style: GoogleFonts.montserrat(
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//         ),
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _couponController,
//             decoration: InputDecoration(
//               hintText: 'Coupon Code',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.blackColor,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             ),
//             onPressed: () {
//               final code = _couponController.text.trim();
//               if (code.isNotEmpty) {
//                 final data = {
//                   "coupon_code": code,
//                   "plan_id": widget.planId,
//                 };
//
//                 Navigator.of(context).pop(); // close the dialog
//
//                 // Use the passed-in rootContext directly here
//                 final provider = Provider.of<PricingPlansViewModel>(
//                   widget.rootContext, // ✅ stable context
//                   listen: false,
//                 );
//                 provider.verifyCouponApi(widget.rootContext, data); // ✅ use here too
//               }
//             },
//
//
//             child: Text(
//               'Apply',
//               style: GoogleFonts.poppins(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
