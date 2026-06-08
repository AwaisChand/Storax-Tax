import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:storatax/models/get_single_ticket_model/get_single_ticket_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../models/ticket_support_model/ticket_support_model.dart';
import '../../res/app_url.dart';
import '../../utils/scan_flow_log.dart';
import '../../utils/scan_upload_file.dart';

class TicketSupportRepo {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<ListTicketModel> listTicketRepo({int page = 1}) async {
    try {
      final response = await baseApiServices.getRequestToken(
        "${AppUrl.listTicketSupportEndPoint}?page=$page",
      );

      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.listTicketSupportEndPoint}?page=$page");

      return ListTicketModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<dynamic> createTicketSupportRepo({
    required Map<String, dynamic> fields,
    required List<File> files,
  }) async {
    try {
      final Map<String, File> fileMap = {};

      for (int i = 0; i < files.length; i++) {
        final original = files[i];

        taxManagerScanLog(
          'TicketSupportCreated: file[$i] incoming path=${original.path}',
        );

        final normalized = await normalizeScanUploadToJpegIfNeeded(
          original,
          logFlow: 'TicketSupportCreate',
        );

        try {
          final len = await normalized.length();
          taxManagerScanLog(
            'TicketSupportCreated: file[$i] after normalize path=${normalized.path} bytes=$len',
          );
        } catch (_) {}

        // ⚠️ IMPORTANT FIX
        // We still keep backend compatibility using SAME KEY STYLE
        fileMap['attachments[$i]'] = normalized;
      }

      final response = await baseApiServices.multipartPostRequest(
        AppUrl.createTicketEndPoint,
        fields: fields,
        files: fileMap,
      );

      debugPrint("Raw API response JSON: $response");
      return response;
    } catch (e, st) {
      taxManagerScanLog('createTicketSupportRepo ERROR: $e');
      debugPrint('$st');
      rethrow;
    }
  }


  /// Reply to Ticket

  Future<dynamic> replyTicketRepo(dynamic data, int ticketId) async {
    try {
      final String url = AppUrl.replyTicket(ticketId);
      debugPrint("Reply Ticket Url: $url");

      dynamic response = await baseApiServices.postRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
