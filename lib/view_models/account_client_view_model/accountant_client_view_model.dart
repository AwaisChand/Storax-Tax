import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storatax/data/network/network_api_service.dart';
import 'package:storatax/models/get_accountants_model/get_accountants_model.dart';
import 'package:storatax/repository/accountant_client_repo/accountant_client_repo.dart';
import '../../utils/utils.dart';

class AccountantClientViewModel extends ChangeNotifier {
  final AccountantClientRepo _accountantClientRepo = AccountantClientRepo();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  bool _connectAccountantLoading = false;


  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get connectAccountantLoading => _connectAccountantLoading;


  int _currentPage = 1;
  int _totalPages = 1;
  int? _selectedAccountantId;
  int? get selectedAccountantId => _selectedAccountantId;




  String? _searchQuery;

  List<AccountantData> _accountantData = [];
  List<AccountantData> get accountantData => _accountantData;

  set loading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set cAccountantLoading(bool value) {
    _connectAccountantLoading = value;
    notifyListeners();
  }

  void selectAccountant(int id) {
    _selectedAccountantId = id;
    notifyListeners();
  }

  ///save accountant id to sp
  Future<void> saveSelectedAccountantId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_accountant_id', id);
  }
  ///get accountant id to sp
  Future<int?> loadSelectedAccountantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selected_accountant_id');
  }
  ///remove accountant id to sp
  Future<bool?> removeAccountantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove('selected_accountant_id');
  }
  /// ✅ Get accountants with pagination and optional search
  Future<void> getAccountants(
      BuildContext context, {
        int page = 1,
        bool isLoadMore = false,
        String? search,
      }) async {
    if (_isLoading || _isLoadingMore) return;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      loading = true;
      _searchQuery = search;
    }

    try {
      final response = await _accountantClientRepo.getAccountantRepo(
        page: page,
        perPage: 10,
        search: _searchQuery,
      );

      if (response.status == 1) {
        _currentPage = response.data?.currentPage ?? 1;
        _totalPages = response.data?.lastPage ?? 1;

        if (isLoadMore) {
          _accountantData.addAll(response.data?.data ?? []);
        } else {
          _accountantData = response.data?.data ?? [];
        }

        _hasMoreData = _currentPage < _totalPages;

        Utils.toastMessage(response.success ?? "Success");
      } else {
        Utils.toastMessage(response.success ?? "Something went wrong");
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint("Get accountant error: $e");
      debugPrint("Stack trace: $stackTrace");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      if (isLoadMore) {
        _isLoadingMore = false;
      } else {
        loading = false;
      }
      notifyListeners();
    }
  }

  /// ✅ Load next page with current search context
  Future<void> loadMoreAccountants(BuildContext context) async {
    if (_hasMoreData && !_isLoading && !_isLoadingMore) {
      await getAccountants(
        context,
        page: _currentPage + 1,
        isLoadMore: true,
        search: _searchQuery,
      );
    }
  }

  /// ✅ Refresh first page with current or new search term
  Future<void> refreshAccountants(BuildContext context, {String? search}) async {
    _currentPage = 1;
    _totalPages = 1;
    _hasMoreData = true;
    _accountantData.clear();
    _searchQuery = search ?? _searchQuery;
    notifyListeners();
    await getAccountants(context, page: 1, search: _searchQuery);
  }

  ///Connect to accountant Api

  Future<void> connectAccountantApi(BuildContext context, dynamic data) async {
    cAccountantLoading = true;
    try {
      debugPrint("Connect Accountant data: $data");

      final response = await _accountantClientRepo.connectAccountantRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        // await saveSelectedAccountantId(data["accountant_id"]);
        notifyListeners();
        // Navigator.pushNamed(context, RoutesName.dashboard);
      } else {
        Utils.toastMessage(response["success"]);
        notifyListeners();
      }
      if (kDebugMode) {
        debugPrint("Connect Accountant API Response: $response");
      }
    } catch (e) {
      debugPrint("Connect Accountant error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      cAccountantLoading = false;
    }
  }

  ///Disconnect to accountant Api

  Future<void> disconnectAccountantApi(BuildContext context, dynamic data) async {
    cAccountantLoading = true;
    try {
      debugPrint("Disconnect Accountant data: $data");

      final response = await _accountantClientRepo.disconnectAccountantRepo(data);

      if (response["status"].toString() == "1") {
        Utils.toastMessage(response["success"]);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('selected_accountant_id');
        notifyListeners();
        // Navigator.pushNamed(context, RoutesName.dashboard);
      } else {
        Utils.toastMessage(response["success"]);
        notifyListeners();
      }
      if (kDebugMode) {
        debugPrint("Disconnect Accountant API Response: $response");
      }
    } catch (e) {
      debugPrint("Disconnect Accountant error: $e");
      Utils.toastMessage("Error: ${e.toString()}");
    } finally {
      cAccountantLoading = false;
    }
  }

}
