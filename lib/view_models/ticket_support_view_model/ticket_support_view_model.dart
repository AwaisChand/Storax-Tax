import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storatax/models/ticket_support_model/ticket_support_model.dart';
import 'package:storatax/repository/ticket_support_repo/ticket_support_repo.dart';
import 'package:storatax/screens/support_tickets/view_support_ticket/view_support_ticket.dart';
import '';
import '../../models/get_single_ticket_model/get_single_ticket_model.dart';
import '../../utils/utils.dart';

class TicketSupportViewModel extends ChangeNotifier {
  final TicketSupportRepo ticketSupportRepo = TicketSupportRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<TicketSupport> _ticketSupport = [];
  List<TicketSupport> get ticketSupport => _ticketSupport;

  SingleTicketData? _singleTicketData;
  SingleTicketData? get singleTicketData => _singleTicketData;

  Future<void> getAllTicketSupports(
    BuildContext context, {
    int page = 1,
  }) async {
    loading = true;
    try {
      final response = await ticketSupportRepo.listTicketRepo(page: page);

      if (response.status == 1) {
        if (page == 1) {
          _ticketSupport = response.data ?? [];
        } else {
          _ticketSupport.addAll(response.data ?? []);
        }

        Utils.toastMessage(response.success!);
      } else {
        Utils.toastMessage(response.success!);
      }

      if (kDebugMode) {
        debugPrint("Get All ticket support system: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get All ticket support system error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

  Future<void> createTicketApi(
      BuildContext context,
      Map<String, dynamic> fields,
      List<File> files,
      ) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("Create ticket fields: $fields");

      final response = await ticketSupportRepo.createTicketSupportRepo(
        fields: fields,
        files: files,
      );

      debugPrint("Create Ticket API Response: $response");

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"] ?? "Ticket created");

        final ticketData = response["data"];

        if (ticketData != null) {
          final newTicket = TicketSupport.fromJson(ticketData);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ViewSupportTicket(
                ticketSupport: newTicket,
              ),
            ),
          );
        }

        return;
      }

      // error handling
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
    } catch (e) {
      debugPrint("Create Ticket error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Reply Ticket Api

  Future<void> replyTicketApi(
      BuildContext context,
      dynamic data,
      int ticketId,
      ) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("Reply Ticket data: $data");

      final locale = Localizations.localeOf(context).languageCode;

      final response = await ticketSupportRepo.replyTicketRepo(data, ticketId);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(
          locale == 'fr'
              ? response["success_fr"]
              : response["success"],
        );
      } else {
        Utils.toastMessage(
          locale == 'fr'
              ? response["success_fr"]
              : response["success"],
        );
      }

      debugPrint("reply ticket API Response: $response");
    } catch (e) {
      debugPrint("reply ticket error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
