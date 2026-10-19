
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:storatax/models/instructions_model/instructions_model.dart';
import 'package:storatax/repository/instructions_repository/instructions_repository.dart';
import '../../utils/utils.dart';

class InstructionsViewModel extends ChangeNotifier {
  final InstructionsRepository instructionsRepository = InstructionsRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  set loading(bool setLoading) {
    _isLoading = setLoading;
    notifyListeners();
  }

  List<InstructionData> _instructions = [];
  List<InstructionData> get instructions => _instructions;

  InstructionData? bySlug(String slug) {
    for (final item in _instructions) {
      if (item.slug == slug) return item;
    }
    return null;
  }

  Future<void> ensureInstructionsLoaded(BuildContext context) async {
    if (_hasFetched || _isLoading) return;
    await getInstructionsApi(context, showSuccessToast: false);
  }

  Future<void> getInstructionsApi(
    BuildContext context, {
    bool showSuccessToast = true,
  }) async {
    loading = true;
    try {
      final response = await instructionsRepository.instructionsRepo();

      if (response.status == 1) {
        _instructions = response.data ?? [];
      }
      _hasFetched = true;
      if (showSuccessToast && context.mounted) {
        Utils.toastMessage(_localizedSuccess(context, response));
      }

      if (kDebugMode) {
        debugPrint("Get All Instructions Data API Response: $response");
      }
    } catch (e, stackTrace) {
      debugPrint("Get All Instructions data error: $e $stackTrace");
      Utils.toastMessage(Utils.friendlyError(e));
    } finally {
      loading = false;
    }
  }

  String _localizedSuccess(BuildContext context, InstructionsModel response) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'fr' && (response.successFr ?? '').isNotEmpty) {
      return response.successFr!;
    }
    return response.success ?? '';
  }
}
