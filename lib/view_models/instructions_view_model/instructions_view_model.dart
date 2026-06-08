
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storatax/models/instructions_model/instructions_model.dart';
import 'package:storatax/repository/instructions_repository/instructions_repository.dart';
import '../../utils/utils.dart';

class InstructionsViewModel extends ChangeNotifier {
  final InstructionsRepository instructionsRepository = InstructionsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<InstructionData> _instructions = [];
  List<InstructionData> get instructions => _instructions;


  /// Get Instructions Api

  Future<void> getInstructionsApi(BuildContext context) async {
    loading = true;
    try {
      final response = await instructionsRepository.instructionsRepo();

      if (response.status == 1) {
        _instructions = response.data!;
        Utils.toastMessage(response.success.toString());
      } else {
        Utils.toastMessage(response.success.toString());
      }

      if (kDebugMode) {
        debugPrint("Get All Instructions Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get All Instructions data error: $e $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      loading = false;
    }
  }

}
