import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storatax/utils/app_colors.dart';
import 'package:storatax/view_models/account_client_view_model/accountant_client_view_model.dart';

import '../../res/app_assets.dart';
import '../../res/components/app_localization.dart';
import '../../utils/utils.dart' show Utils;

class SelectTaxProfessionalScreen extends StatefulWidget {
  const SelectTaxProfessionalScreen({super.key});

  @override
  State<SelectTaxProfessionalScreen> createState() =>
      _SelectTaxProfessionalScreenState();
}

class _SelectTaxProfessionalScreenState
    extends State<SelectTaxProfessionalScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int? _connectedAccountantId;
  int? _selectedIndex;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // SEARCH LISTENER
    // ============================================================

    _searchController.addListener(() {
      _onSearchChanged();

      // Rebuild so the clear icon appears/disappears immediately.
      if (mounted) {
        setState(() {});
      }
    });

    // ============================================================
    // INITIAL DATA
    // ============================================================

    Future.delayed(Duration.zero, () async {
      final provider = Provider.of<AccountantClientViewModel>(
        context,
        listen: false,
      );

      await provider.getAccountants(context);

      if (!mounted) return;

      // ==========================================================
      // LOAD SAVED CONNECTED ACCOUNTANT
      // ==========================================================

      final prefs = await SharedPreferences.getInstance();

      final storedId = prefs.getInt('selected_accountant_id');

      if (storedId != null && mounted) {
        final index = provider.accountantData.indexWhere(
          (a) => a.id == storedId,
        );

        if (index != -1) {
          setState(() {
            _connectedAccountantId = storedId;
            _selectedIndex = index;
          });
        }
      }
    });

    // ============================================================
    // PAGINATION
    // ============================================================

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) {
        return;
      }

      final provider = Provider.of<AccountantClientViewModel>(
        context,
        listen: false,
      );

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !provider.isLoading &&
          !provider.isLoadingMore) {
        provider.loadMoreAccountants(context);
      }
    });
  }

  // ==============================================================
  // SEARCH
  // ==============================================================

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final searchValue = _searchController.text.trim();

      Provider.of<AccountantClientViewModel>(
        context,
        listen: false,
      ).refreshAccountants(context, search: searchValue);

      // IMPORTANT:
      // The old selected index may no longer exist after filtering.
      if (mounted) {
        setState(() {
          _selectedIndex = null;
        });
      }
    });
  }

  // ==============================================================
  // CLEAR SEARCH
  // ==============================================================

  Future<void> _clearSearch(AccountantClientViewModel provider) async {
    _searchController.clear();

    setState(() {
      _selectedIndex = null;
    });

    await provider.refreshAccountants(context, search: '');
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();

    super.dispose();
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountantClientViewModel>(
      builder: (context, accountantProvider, _) {
        // ========================================================
        // SAFETY:
        // Make sure selected index still exists after filtering.
        // ========================================================

        if (_selectedIndex != null &&
            (_selectedIndex! < 0 ||
                _selectedIndex! >= accountantProvider.accountantData.length)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            setState(() {
              _selectedIndex = null;
            });
          });
        }

        // ========================================================
        // SAFE SELECTED ACCOUNTANT
        // ========================================================

        dynamic selectedAccountant;

        if (_selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < accountantProvider.accountantData.length) {
          selectedAccountant =
              accountantProvider.accountantData[_selectedIndex!];
        }

        final bool isSelectedConnected =
            selectedAccountant != null &&
            selectedAccountant.id == _connectedAccountantId;

        return Scaffold(
          resizeToAvoidBottomInset: false,

          // ======================================================
          // FLOATING BUTTON
          // ======================================================
          floatingActionButton:
              accountantProvider.accountantData.isEmpty
                  ? null
                  : SizedBox(
                    height: Utils.setHeight(context) * 0.063,
                    child: FloatingActionButton.extended(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      backgroundColor:
                          isSelectedConnected
                              ? Colors.red
                              : AppColors.goldenOrangeColor,

                      onPressed:
                          accountantProvider.connectAccountantLoading
                              ? null
                              : () async {
                                // ==================================
                                // NO ACCOUNTANT SELECTED
                                // ==================================

                                if (_selectedIndex == null ||
                                    _selectedIndex! < 0 ||
                                    _selectedIndex! >=
                                        accountantProvider
                                            .accountantData
                                            .length) {
                                  Utils.toastMessage(
                                    AppLocalizations.of(
                                          context,
                                        )!.translate("selectAccountantText") ??
                                        '',
                                  );

                                  return;
                                }

                                // ==================================
                                // SELECTED ACCOUNTANT
                                // ==================================

                                final selectedAccountant =
                                    accountantProvider
                                        .accountantData[_selectedIndex!];

                                final prefs =
                                    await SharedPreferences.getInstance();

                                final bool isConnected =
                                    selectedAccountant.id ==
                                    _connectedAccountantId;

                                // ==================================
                                // DISCONNECT
                                // ==================================

                                if (isConnected) {
                                  final Map<String, dynamic> data = {
                                    'disconnect': true,
                                  };

                                  await accountantProvider
                                      .disconnectAccountantApi(context, data);

                                  if (!accountantProvider
                                      .connectAccountantLoading) {
                                    await prefs.remove(
                                      'selected_accountant_id',
                                    );

                                    if (!mounted) {
                                      return;
                                    }

                                    setState(() {
                                      _connectedAccountantId = null;
                                      _selectedIndex = null;
                                    });
                                  }
                                }
                                // ==================================
                                // CONNECT
                                // ==================================
                                else {
                                  final Map<String, dynamic> data = {
                                    'accountant_id': selectedAccountant.id,
                                  };

                                  await accountantProvider.connectAccountantApi(
                                    context,
                                    data,
                                  );

                                  if (!accountantProvider
                                      .connectAccountantLoading) {
                                    if (selectedAccountant.id != null) {
                                      await prefs.setInt(
                                        'selected_accountant_id',
                                        selectedAccountant.id!,
                                      );
                                    }

                                    if (!mounted) {
                                      return;
                                    }

                                    setState(() {
                                      _connectedAccountantId =
                                          selectedAccountant.id;
                                    });
                                  }
                                }
                              },

                      // ==========================================
                      // BUTTON LABEL
                      // ==========================================
                      label:
                          accountantProvider.connectAccountantLoading
                              ?  SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  color: AppColors.whiteColor,
                                ),
                              )
                              : Text(
                                isSelectedConnected
                                    ? AppLocalizations.of(
                                          context,
                                        )!.translate("disconnectText") ??
                                        ''
                                    : AppLocalizations.of(
                                          context,
                                        )!.translate("connectText") ??
                                        '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                    ),
                  ),

          // ========================================================
          // BODY
          // ========================================================
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
                  padding: EdgeInsets.only(
                    top: Utils.setHeight(context) * 0.08,
                    right: 20,
                    left: 20,
                  ),

                  child: Column(
                    children: [
                      // ==================================================
                      // HEADER
                      // ==================================================
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                            ),
                          ),

                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )!.translate("selectTxProfessionalText") ??
                                    '',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // SEARCH FIELD
                      // ==================================================
                      TextField(
                        controller: _searchController,

                        style: GoogleFonts.poppins(
                          textStyle:  TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blackColor,
                          ),
                        ),

                        keyboardType: TextInputType.name,

                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(
                                context,
                              )!.translate("searchTaxProfessionalText") ??
                              '',

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:  BorderSide(
                              color: AppColors.blackColor,
                              width: 1,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:  BorderSide(
                              color: AppColors.blackColor,
                              width: 1,
                            ),
                          ),

                          hintStyle: GoogleFonts.poppins(
                            textStyle:  TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.spanishGrayColor,
                            ),
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),

                          prefixIcon: const Icon(Icons.search, size: 20),

                          // ================================================
                          // CLEAR BUTTON
                          // ================================================
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _clearSearch(accountantProvider);
                                    },
                                  )
                                  : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // RESULTS
                      // ==================================================
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              _selectedIndex = null;
                            });

                            await accountantProvider.refreshAccountants(
                              context,
                              search: _searchController.text.trim(),
                            );
                          },

                          child:
                              accountantProvider.isLoading
                                  // ======================================
                                  // LOADING
                                  // ======================================
                                  ? const Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  // ======================================
                                  // EMPTY STATE
                                  // ======================================
                                  : accountantProvider.accountantData.isEmpty
                                  ? Center(
                                    child: Text(
                                      "No tax professional found",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  )
                                  // ======================================
                                  // ACCOUNTANT LIST
                                  // ======================================
                                  : ListView.builder(
                                    controller: _scrollController,

                                    physics:
                                        const AlwaysScrollableScrollPhysics(),

                                    itemCount:
                                        accountantProvider
                                            .accountantData
                                            .length +
                                        (accountantProvider.isLoadingMore
                                            ? 1
                                            : 0),

                                    itemBuilder: (context, index) {
                                      // ==================================
                                      // LOAD MORE INDICATOR
                                      // ==================================

                                      if (index >=
                                          accountantProvider
                                              .accountantData
                                              .length) {
                                        return  Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4,
                                              color: AppColors.blackColor,
                                            ),
                                          ),
                                        );
                                      }

                                      // ==================================
                                      // ACCOUNTANT DATA
                                      // ==================================

                                      final data =
                                          accountantProvider
                                              .accountantData[index];

                                      return Card(
                                        color: AppColors.whiteColor,

                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),

                                        child: Container(
                                          height:
                                              Utils.setHeight(context) * 0.43,

                                          width: double.infinity,

                                          decoration: BoxDecoration(
                                            color: AppColors.whiteColor,

                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),

                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 20,
                                                ),

                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,

                                                  children: [
                                                    const SizedBox(height: 20),

                                                    // ==================================
                                                    // PROFILE IMAGE
                                                    // ==================================
                                                    SizedBox(
                                                      height:
                                                          Utils.setHeight(
                                                            context,
                                                          ) *
                                                          0.15,

                                                      width:
                                                          Utils.setHeight(
                                                            context,
                                                          ) *
                                                          0.15,

                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),

                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              data.avatar ?? '',

                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => const CircleAvatar(
                                                                radius: 12,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 14,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),

                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => const CircleAvatar(
                                                                radius: 12,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                child: Icon(
                                                                  Icons.person,
                                                                  size: 14,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),

                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 10),

                                                    // ==================================
                                                    // NAME
                                                    // ==================================
                                                    Text(
                                                      "${data.firstName ?? ''} ${data.lastName ?? ''}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 20,
                                                          ),
                                                    ),

                                                    const SizedBox(height: 5),

                                                    // ==================================
                                                    // BUSINESS NAME
                                                    // ==================================
                                                    Text(
                                                      data.businessName ?? '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 20,
                                                        color:
                                                            AppColors
                                                                .goldenOrangeColor,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    // ==================================
                                                    // EMAIL + PHONE
                                                    // ==================================
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            data.email ?? "N/A",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          width: 8,
                                                        ),

                                                        const SizedBox(
                                                          height: 12,
                                                          child:
                                                              VerticalDivider(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                thickness: 1,
                                                              ),
                                                        ),

                                                        const SizedBox(
                                                          width: 8,
                                                        ),

                                                        Flexible(
                                                          child: Text(
                                                            data.phone ?? "N/A",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 20),

                                                    // ==================================
                                                    // CITY + COUNTRY
                                                    // ==================================
                                                    Text(
                                                      "${data.city ?? ''}, ${data.country ?? ''}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 15,
                                                            color:
                                                                AppColors
                                                                    .blackColor,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // ======================================
                                              // CHECKBOX
                                              // ======================================
                                              Checkbox(
                                                value: _selectedIndex == index,

                                                onChanged: (_) {
                                                  setState(() {
                                                    _selectedIndex = index;
                                                  });
                                                },

                                                activeColor:
                                                    AppColors.goldenOrangeColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
