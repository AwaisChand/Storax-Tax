import 'package:flutter/foundation.dart';
import 'package:storatax/models/get_all_team_member_model/get_all_team_member_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class TeamMemberRepository{
  BaseApiServices baseApiServices = NetworkApiService();

  ///Get All Team Members Repository

  Future<GetAllTeamMembers> getAllTeamMembersRepo() async {
    try {
      dynamic response = await baseApiServices.getRequestToken(
        AppUrl.teamMemberEndPoints,
      );
      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.teamMemberEndPoints}");

      return GetAllTeamMembers.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }



  ///Create Team Member Repo

  Future<dynamic> createTeamMemberRep(dynamic data) async {
    try {
      dynamic response = await baseApiServices.postRequest(
        AppUrl.teamMemberEndPoints,
        data,
      );

      debugPrint("Response: $response");
      debugPrint("Api url: ${AppUrl.teamMemberEndPoints}");

      if (response is Map && response["status"] == 0 && response["errors"] != null) {
        String errorMessage = "";
        Map<String, dynamic> errors = response["errors"];
        errors.forEach((key, value) {
          if (value is List) {
            errorMessage += "${value.join("\n")}\n";
          } else {
            errorMessage += "$value\n";
          }
        });

        throw Exception(errorMessage.trim());
      }

      return response;
    } catch (e) {
      debugPrint("Error: $e");
      rethrow;
    }
  }



  Future<dynamic> updateTeamMemberRepo({dynamic data, required int id}) async {
    try {
      final String url = '${AppUrl.teamMemberEndPoints}/$id';

      dynamic response = await baseApiServices.putRequest(url, data);
      debugPrint("response$response");
      debugPrint("Api url: $url");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }



  Future<dynamic> deleteTeamMemberRepo(int id) async {
    try {
      final String urlWithId = "${AppUrl.teamMemberEndPoints}/$id";
      dynamic response = await baseApiServices.deleteApiResponse(urlWithId);
      debugPrint("response$response");
      debugPrint("Api url: ${AppUrl.teamMemberEndPoints}");

      return response;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

}