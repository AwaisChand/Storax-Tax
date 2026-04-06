import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:storatax/models/get_all_team_member_model/get_all_team_member_model.dart';
import 'package:storatax/repository/team_member_repository/team_member_repository.dart';

import '../../utils/utils.dart';

class TeamMemberViewModel extends ChangeNotifier {
  final TeamMemberRepository teamMemberRepository = TeamMemberRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<TeamMemberData> _allData = [];
  List<TeamMemberData> get allData => _allData;

  ///Get all Team Member api

  Future<Map<String, dynamic>> getAllTeamMemberApi() async {
    loading = true;
    try {
      final response = await teamMemberRepository.getAllTeamMembersRepo();

      if (response.status == 1) {
        _allData = response.data!;
        return {
          "success": true,
          "message": response.success ?? "Fetched successfully",
        };
      } else {
        return {
          "success": false,
          "message": response.success ?? "Something went wrong",
        };
      }
    } catch (e, stackTrace) {
      debugPrint("Get All Team Member data error: $e $stackTrace");
      return {"success": false, "message": "Error: ${e.toString()}"};
    } finally {
      loading = false;
    }
  }

  ///Create Team Member Api

  Future<void> createTeamMemberApi(BuildContext context, dynamic data) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("create team member data: $data");

      final response = await teamMemberRepository.createTeamMemberRep(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);

        context.pushNamed("teamMember");
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("create team member API Response: $response");
      }
    } catch (e) {
      debugPrint("create team member error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> updateTeamMemberApi(
    BuildContext context,
    int id,
    dynamic data,
  ) async {
    loading = true;
    notifyListeners();

    try {
      debugPrint("Update team member data: $data");

      final response = await teamMemberRepository.updateTeamMemberRepo(
        id: id,
        data: data,
      );

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        context.pushNamed("viewTeamMember");
      } else {
        Utils.toastMessage(response["success"]);
      }

      if (kDebugMode) {
        debugPrint("update team member API Response: $response");
      }
    } catch (e) {
      debugPrint("update team member error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTeamMemberApi(BuildContext context, int id) async {
    loading = true;
    try {
      final response = await teamMemberRepository.deleteTeamMemberRepo(id);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        if (kDebugMode) {
          debugPrint("Delete team member API Response: $response");
        }
        return true;
      } else {
        Utils.toastMessage(response["success"]);
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("Delete team member Api error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
      return false;
    } finally {
      loading = false;
    }
  }
}
