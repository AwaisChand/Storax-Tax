
import 'package:flutter/cupertino.dart';
import 'package:storatax/models/instructions_model/instructions_model.dart';

import '../../data/network/base_api_service.dart';
import '../../data/network/network_api_service.dart';
import '../../res/app_url.dart';

class InstructionsRepository {
  BaseApiServices baseApiServices = NetworkApiService();

  Future<InstructionsModel> instructionsRepo() async {
    try {
      final response = await baseApiServices.getRequestToken(
        AppUrl.instructionsEndPoint,
      );


      debugPrint("Raw API response JSON: $response");
      debugPrint("Api url: ${AppUrl.instructionsEndPoint}");

      return InstructionsModel.fromJson(response);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }




}
