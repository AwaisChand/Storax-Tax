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
  final _searchController = TextEditingController();
  int? _connectedAccountantId;
  int? _selectedIndex;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      _onSearchChanged();
    });

    Future.delayed(Duration.zero, () async {
      final provider = Provider.of<AccountantClientViewModel>(
        context,
        listen: false,
      );

      await provider.getAccountants(context); // ✅ Wait for data first

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

    _scrollController.addListener(() {
      final provider = Provider.of<AccountantClientViewModel>(
        context,
        listen: false,
      );

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !provider.isLoading) {
        provider.loadMoreAccountants(context);
      }
    });
  }

  // Future<void> _loadSelectedAccountantId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final storedId = prefs.getInt('selected_accountant_id');
  //
  //   if (storedId != null && mounted) {
  //     final provider = Provider.of<AccountantClientViewModel>(
  //       context,
  //       listen: false,
  //     );
  //
  //     final index = provider.accountantData.indexWhere((a) => a.id == storedId);
  //     if (index != -1) {
  //       setState(() {
  //         _connectedAccountantId = storedId;
  //         _selectedIndex = index;
  //       });
  //     }
  //   }
  // }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final searchValue = _searchController.text.trim();
      Provider.of<AccountantClientViewModel>(
        context,
        listen: false,
      ).refreshAccountants(context, search: searchValue);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountantClientViewModel>(
      builder: (context, accountantProvider, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: SizedBox(
            height: Utils.setHeight(context) * 0.063,
            child: FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor:
                  (_selectedIndex != null &&
                          accountantProvider
                                  .accountantData[_selectedIndex!]
                                  .id ==
                              _connectedAccountantId)
                      ? Colors.red
                      : AppColors.goldenOrangeColor,
              onPressed:
                  accountantProvider.connectAccountantLoading
                      ? null
                      : () async {
                        if (_selectedIndex == null) {
                          Utils.toastMessage(
                            AppLocalizations.of(
                                  context,
                                )!.translate("selectAccountantText") ??
                                '',
                          );
                          return;
                        }
                        final selectedAccountant =
                            accountantProvider.accountantData[_selectedIndex!];
                        final prefs = await SharedPreferences.getInstance();

                        final isConnected =
                            selectedAccountant.id == _connectedAccountantId;

                        if (isConnected) {
                          // Disconnect
                          Map<String, dynamic> data = {'disconnect': true};
                          await accountantProvider.disconnectAccountantApi(
                            context,
                            data,
                          );

                          if (!accountantProvider.connectAccountantLoading) {
                            await prefs.remove('selected_accountant_id');

                            setState(() {
                              _connectedAccountantId = null;
                              _selectedIndex = null;
                            });
                          }
                        } else {
                          // Connect
                          Map<String, dynamic> data = {
                            'accountant_id': selectedAccountant.id,
                          };

                          await accountantProvider.connectAccountantApi(
                            context,
                            data,
                          );

                          if (!accountantProvider.connectAccountantLoading) {
                            await prefs.setInt(
                              'selected_accountant_id',
                              selectedAccountant.id!,
                            );

                            setState(() {
                              _connectedAccountantId = selectedAccountant.id;
                            });
                          }
                        }
                      },
              label:
                  accountantProvider.connectAccountantLoading
                      ? SizedBox(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: AppColors.whiteColor,
                        ),
                      )
                      : Text(
                        (_selectedIndex != null &&
                                accountantProvider
                                        .accountantData[_selectedIndex!]
                                        .id ==
                                    _connectedAccountantId)
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
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
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
                      SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
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
                            borderSide: BorderSide(
                              color: AppColors.blackColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.blackColor,
                              width: 1,
                            ),
                          ),
                          hintStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.spanishGrayColor,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          prefixIcon: Icon(Icons.search, size: 20),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      accountantProvider.refreshAccountants(
                                        context,
                                        search: '',
                                      );
                                    },
                                  )
                                  : null,
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await accountantProvider.refreshAccountants(
                              context,
                            );
                          },
                          child:
                              accountantProvider.isLoading
                                  ? Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                  : ListView.builder(
                                    controller: _scrollController,
                                    itemCount:
                                        accountantProvider
                                            .accountantData
                                            .length +
                                        (accountantProvider.isLoadingMore
                                            ? 1
                                            : 0),
                                    itemBuilder: (context, index) {
                                      if (index >=
                                          accountantProvider
                                              .accountantData
                                              .length) {
                                        return Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4,
                                              color: AppColors.blackColor,
                                            ),
                                          ),
                                        );
                                      }

                                      final data =
                                          accountantProvider
                                              .accountantData[index];

                                      return Card(
                                        color: AppColors.whiteColor,
                                        margin: EdgeInsets.only(bottom: 20),
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
                                                    SizedBox(height: 20),
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
                                                    SizedBox(height: 10),
                                                    Text(
                                                      "${data.firstName ?? ''} ${data.lastName ?? ''}",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 20,
                                                          ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      data.businessName ?? '',
                                                      style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 20,
                                                        color:
                                                            AppColors
                                                                .goldenOrangeColor,
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          data.email ?? "N/A",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                          child:
                                                              VerticalDivider(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                                thickness: 1,
                                                              ),
                                                        ),
                                                        Text(
                                                          data.phone ?? "N/A",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      "${data.city}, ${data.country}",
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
                                              Checkbox(
                                                value:
                                                    _selectedIndex ==
                                                    index, // ✅ Just mark this as selected for now
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
