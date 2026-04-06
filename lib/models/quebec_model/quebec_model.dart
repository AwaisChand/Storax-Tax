class QuebecModel {
  int? id;
  String name;
  String year;
  double grossUberRidesFares;
  double bookingFee;
  double mtqDues;
  double airportFee;
  double splitFare;
  double miscellaneous;
  double tolls;
  double tips;
  double gstCollectedFromRiders;
  double qstCollectedFromRiders;
  double otherTaxableIncome;
  double section1Total;
  double serviceFee;
  double otherAmounts;
  double feeDiscount;
  double gstPaidToUber;
  double qstPaidToUber;
  double section2Total;
  String uberGstRegistrationNumber;
  String uberQstRegistrationNumber;
  double suppliesExcludingGstQst;
  double gstRemittedByUber;
  double qstRemittedByUber;
  double gstCollectedFromRidersSec3;
  double qstCollectedFromRidersSec3;
  String yourGstNumberSec3;
  String yourQstNumberSec3;
  double grossUberEatsFare;
  double eatsTips;
  double gstCollectedFromUber;
  double qstCollectedFromUber;
  double section4Total;
  String yourGstNumberSec4;
  String yourQstNumberSec4;
  double quickAccountingMethod6085;
  double gstCollectedFromUberSec5;
  double qstCollectedFromUberSec5;
  double section5Total;
  String uberGstRegistrationNumberSec5;
  String uberQstRegistrationNumberSec5;
  double onTripMileage;
  double onlineMileage;
  double otherIncomeMiscellaneous;
  String periodFrom;
  String periodTo;
  String dueDate;

  QuebecModel({
    this.id,
    required this.name,
    required this.year,
    required this.grossUberRidesFares,
    required this.bookingFee,
    required this.mtqDues,
    required this.airportFee,
    required this.splitFare,
    required this.miscellaneous,
    required this.tolls,
    required this.tips,
    required this.gstCollectedFromRiders,
    required this.qstCollectedFromRiders,
    required this.otherTaxableIncome,
    required this.section1Total,
    required this.serviceFee,
    required this.otherAmounts,
    required this.feeDiscount,
    required this.gstPaidToUber,
    required this.qstPaidToUber,
    required this.section2Total,
    required this.uberGstRegistrationNumber,
    required this.uberQstRegistrationNumber,
    required this.suppliesExcludingGstQst,
    required this.gstRemittedByUber,
    required this.qstRemittedByUber,
    required this.gstCollectedFromRidersSec3,
    required this.qstCollectedFromRidersSec3,
    required this.yourGstNumberSec3,
    required this.yourQstNumberSec3,
    required this.grossUberEatsFare,
    required this.eatsTips,
    required this.gstCollectedFromUber,
    required this.qstCollectedFromUber,
    required this.section4Total,
    required this.yourGstNumberSec4,
    required this.yourQstNumberSec4,
    required this.quickAccountingMethod6085,
    required this.gstCollectedFromUberSec5,
    required this.qstCollectedFromUberSec5,
    required this.section5Total,
    required this.uberGstRegistrationNumberSec5,
    required this.uberQstRegistrationNumberSec5,
    required this.onTripMileage,
    required this.onlineMileage,
    required this.otherIncomeMiscellaneous,
    required this.periodFrom,
    required this.periodTo,
    required this.dueDate,
  });

  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory QuebecModel.fromJson(Map<String, dynamic> json) {
    return QuebecModel(
      id: json["id"],
      name: json["name"] ?? '',
      year: json["tax_summary_period_year"]?.toString() ?? '',
      grossUberRidesFares: parseDouble(json["gross_uber_rides_fares"]),
      bookingFee: parseDouble(json["booking_fee"]),
      mtqDues: parseDouble(json["mtq_dues"]),
      airportFee: parseDouble(json["airport_fee"]),
      splitFare: parseDouble(json["split_fare"]),
      miscellaneous: parseDouble(json["miscellaneous"]),
      tolls: parseDouble(json["tolls"]),
      tips: parseDouble(json["tips"]),
      gstCollectedFromRiders: parseDouble(json["gst_collected_from_riders"]),
      qstCollectedFromRiders: parseDouble(json["qst_collected_from_riders"]),
      otherTaxableIncome: parseDouble(json["other_taxable_income"]),
      section1Total: parseDouble(json["section_1_total"]),
      serviceFee: parseDouble(json["service_fee"]),
      otherAmounts: parseDouble(json["other_amounts"]),
      feeDiscount: parseDouble(json["fee_discount"]),
      gstPaidToUber: parseDouble(json["gst_paid_to_uber"]),
      qstPaidToUber: parseDouble(json["qst_paid_to_uber"]),
      section2Total: parseDouble(json["section_2_total"]),
      uberGstRegistrationNumber: json["uber_gst_registration_number"] ?? '',
      uberQstRegistrationNumber: json["uber_qst_registration_number"] ?? '',
      suppliesExcludingGstQst: parseDouble(json["supplies_excluding_gst_qst"]),
      gstRemittedByUber: parseDouble(json["gst_remitted_by_uber"]),
      qstRemittedByUber: parseDouble(json["qst_remitted_by_uber"]),
      gstCollectedFromRidersSec3: parseDouble(json["gst_collected_from_riders_sec3"]),
      qstCollectedFromRidersSec3: parseDouble(json["qst_collected_from_riders_sec3"]),
      yourGstNumberSec3: json["your_gst_number_sec3"] ?? '',
      yourQstNumberSec3: json["your_qst_number_sec3"] ?? '',
      grossUberEatsFare: parseDouble(json["gross_uber_eats_fare"]),
      eatsTips: parseDouble(json["eats_tips"]),
      gstCollectedFromUber: parseDouble(json["gst_collected_from_uber"]),
      qstCollectedFromUber: parseDouble(json["qst_collected_from_uber"]),
      section4Total: parseDouble(json["section_4_total"]),
      yourGstNumberSec4: json["your_gst_number_sec4"] ?? '',
      yourQstNumberSec4: json["your_qst_number_sec4"] ?? '',
      quickAccountingMethod6085: parseDouble(json["quick_accounting_method_6085"]),
      gstCollectedFromUberSec5: parseDouble(json["gst_collected_from_uber_sec5"]),
      qstCollectedFromUberSec5: parseDouble(json["qst_collected_from_uber_sec5"]),
      section5Total: parseDouble(json["section_5_total"]),
      uberGstRegistrationNumberSec5: json["uber_gst_registration_number_sec5"] ?? '',
      uberQstRegistrationNumberSec5: json["uber_qst_registration_number_sec5"] ?? '',
      onTripMileage: parseDouble(json["on_trip_mileage"]),
      onlineMileage: parseDouble(json["online_mileage"]),
      otherIncomeMiscellaneous: parseDouble(json["other_income_miscellaneous"]),
      periodFrom: json["period_from"] ?? '',
      periodTo: json["period_to"] ?? '',
      dueDate: json["due_date"] ?? '',
    );
  }

  factory QuebecModel.empty() {
    return QuebecModel(
      id: null,
      name: '',
      year: '',
      grossUberRidesFares: 0.0,
      bookingFee: 0.0,
      mtqDues: 0.0,
      airportFee: 0.0,
      splitFare: 0.0,
      miscellaneous: 0.0,
      tolls: 0.0,
      tips: 0.0,
      gstCollectedFromRiders: 0.0,
      qstCollectedFromRiders: 0.0,
      otherTaxableIncome: 0.0,
      section1Total: 0.0,
      serviceFee: 0.0,
      otherAmounts: 0.0,
      feeDiscount: 0.0,
      gstPaidToUber: 0.0,
      qstPaidToUber: 0.0,
      section2Total: 0.0,
      uberGstRegistrationNumber: '',
      uberQstRegistrationNumber: '',
      suppliesExcludingGstQst: 0.0,
      gstRemittedByUber: 0.0,
      qstRemittedByUber: 0.0,
      gstCollectedFromRidersSec3: 0.0,
      qstCollectedFromRidersSec3: 0.0,
      yourGstNumberSec3: '',
      yourQstNumberSec3: '',
      grossUberEatsFare: 0.0,
      eatsTips: 0.0,
      gstCollectedFromUber: 0.0,
      qstCollectedFromUber: 0.0,
      section4Total: 0.0,
      yourGstNumberSec4: '',
      yourQstNumberSec4: '',
      quickAccountingMethod6085: 0.0,
      gstCollectedFromUberSec5: 0.0,
      qstCollectedFromUberSec5: 0.0,
      section5Total: 0.0,
      uberGstRegistrationNumberSec5: '',
      uberQstRegistrationNumberSec5: '',
      onTripMileage: 0.0,
      onlineMileage: 0.0,
      otherIncomeMiscellaneous: 0.0,
      periodFrom: '',
      periodTo: '',
      dueDate: '',
    );
  }

  QuebecModel copyWith({
    int? id,
    String? name,
    String? year,
    double? grossUberRidesFares,
    double? bookingFee,
    double? mtqDues,
    double? airportFee,
    double? splitFare,
    double? miscellaneous,
    double? tolls,
    double? tips,
    double? gstCollectedFromRiders,
    double? qstCollectedFromRiders,
    double? otherTaxableIncome,
    double? section1Total,
    double? serviceFee,
    double? otherAmounts,
    double? feeDiscount,
    double? gstPaidToUber,
    double? qstPaidToUber,
    double? section2Total,
    String? uberGstRegistrationNumber,
    String? uberQstRegistrationNumber,
    double? suppliesExcludingGstQst,
    double? gstRemittedByUber,
    double? qstRemittedByUber,
    double? gstCollectedFromRidersSec3,
    double? qstCollectedFromRidersSec3,
    String? yourGstNumberSec3,
    String? yourQstNumberSec3,
    double? grossUberEatsFare,
    double? eatsTips,
    double? gstCollectedFromUber,
    double? qstCollectedFromUber,
    double? section4Total,
    String? yourGstNumberSec4,
    String? yourQstNumberSec4,
    double? quickAccountingMethod6085,
    double? gstCollectedFromUberSec5,
    double? qstCollectedFromUberSec5,
    double? section5Total,
    String? uberGstRegistrationNumberSec5,
    String? uberQstRegistrationNumberSec5,
    double? onTripMileage,
    double? onlineMileage,
    double? otherIncomeMiscellaneous,
    String? periodFrom,
    String? periodTo,
    String? dueDate,
  }) {
    return QuebecModel(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      grossUberRidesFares: grossUberRidesFares ?? this.grossUberRidesFares,
      bookingFee: bookingFee ?? this.bookingFee,
      mtqDues: mtqDues ?? this.mtqDues,
      airportFee: airportFee ?? this.airportFee,
      splitFare: splitFare ?? this.splitFare,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      tolls: tolls ?? this.tolls,
      tips: tips ?? this.tips,
      gstCollectedFromRiders: gstCollectedFromRiders ?? this.gstCollectedFromRiders,
      qstCollectedFromRiders: qstCollectedFromRiders ?? this.qstCollectedFromRiders,
      otherTaxableIncome: otherTaxableIncome ?? this.otherTaxableIncome,
      section1Total: section1Total ?? this.section1Total,
      serviceFee: serviceFee ?? this.serviceFee,
      otherAmounts: otherAmounts ?? this.otherAmounts,
      feeDiscount: feeDiscount ?? this.feeDiscount,
      gstPaidToUber: gstPaidToUber ?? this.gstPaidToUber,
      qstPaidToUber: qstPaidToUber ?? this.qstPaidToUber,
      section2Total: section2Total ?? this.section2Total,
      uberGstRegistrationNumber: uberGstRegistrationNumber ?? this.uberGstRegistrationNumber,
      uberQstRegistrationNumber: uberQstRegistrationNumber ?? this.uberQstRegistrationNumber,
      suppliesExcludingGstQst: suppliesExcludingGstQst ?? this.suppliesExcludingGstQst,
      gstRemittedByUber: gstRemittedByUber ?? this.gstRemittedByUber,
      qstRemittedByUber: qstRemittedByUber ?? this.qstRemittedByUber,
      gstCollectedFromRidersSec3: gstCollectedFromRidersSec3 ?? this.gstCollectedFromRidersSec3,
      qstCollectedFromRidersSec3: qstCollectedFromRidersSec3 ?? this.qstCollectedFromRidersSec3,
      yourGstNumberSec3: yourGstNumberSec3 ?? this.yourGstNumberSec3,
      yourQstNumberSec3: yourQstNumberSec3 ?? this.yourQstNumberSec3,
      grossUberEatsFare: grossUberEatsFare ?? this.grossUberEatsFare,
      eatsTips: eatsTips ?? this.eatsTips,
      gstCollectedFromUber: gstCollectedFromUber ?? this.gstCollectedFromUber,
      qstCollectedFromUber: qstCollectedFromUber ?? this.qstCollectedFromUber,
      section4Total: section4Total ?? this.section4Total,
      yourGstNumberSec4: yourGstNumberSec4 ?? this.yourGstNumberSec4,
      yourQstNumberSec4: yourQstNumberSec4 ?? this.yourQstNumberSec4,
      quickAccountingMethod6085: quickAccountingMethod6085 ?? this.quickAccountingMethod6085,
      gstCollectedFromUberSec5: gstCollectedFromUberSec5 ?? this.gstCollectedFromUberSec5,
      qstCollectedFromUberSec5: qstCollectedFromUberSec5 ?? this.qstCollectedFromUberSec5,
      section5Total: section5Total ?? this.section5Total,
      uberGstRegistrationNumberSec5: uberGstRegistrationNumberSec5 ?? this.uberGstRegistrationNumberSec5,
      uberQstRegistrationNumberSec5: uberQstRegistrationNumberSec5 ?? this.uberQstRegistrationNumberSec5,
      onTripMileage: onTripMileage ?? this.onTripMileage,
      onlineMileage: onlineMileage ?? this.onlineMileage,
      otherIncomeMiscellaneous: otherIncomeMiscellaneous ?? this.otherIncomeMiscellaneous,
      periodFrom: periodFrom ?? this.periodFrom,
      periodTo: periodTo ?? this.periodTo,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "year": year,
      "gross_uber_rides_fares": grossUberRidesFares,
      "booking_fee": bookingFee,
      "mtq_dues": mtqDues,
      "airport_fee": airportFee,
      "split_fare": splitFare,
      "miscellaneous": miscellaneous,
      "tolls": tolls,
      "tips": tips,
      "gst_collected_from_riders": gstCollectedFromRiders,
      "qst_collected_from_riders": qstCollectedFromRiders,
      "other_taxable_income": otherTaxableIncome,
      "section_1_total": section1Total,
      "service_fee": serviceFee,
      "other_amounts": otherAmounts,
      "fee_discount": feeDiscount,
      "gst_paid_to_uber": gstPaidToUber,
      "qst_paid_to_uber": qstPaidToUber,
      "section_2_total": section2Total,
      "uber_gst_registration_number": uberGstRegistrationNumber,
      "uber_qst_registration_number": uberQstRegistrationNumber,
      "supplies_excluding_gst_qst": suppliesExcludingGstQst,
      "gst_remitted_by_uber": gstRemittedByUber,
      "qst_remitted_by_uber": qstRemittedByUber,
      "gst_collected_from_riders_sec3": gstCollectedFromRidersSec3,
      "qst_collected_from_riders_sec3": qstCollectedFromRidersSec3,
      "your_gst_number_sec3": yourGstNumberSec3,
      "your_qst_number_sec3": yourQstNumberSec3,
      "gross_uber_eats_fare": grossUberEatsFare,
      "eats_tips": eatsTips,
      "gst_collected_from_uber": gstCollectedFromUber,
      "qst_collected_from_uber": qstCollectedFromUber,
      "section_4_total": section4Total,
      "your_gst_number_sec4": yourGstNumberSec4,
      "your_qst_number_sec4": yourQstNumberSec4,
      "quick_accounting_method_6085": quickAccountingMethod6085,
      "gst_collected_from_uber_sec5": gstCollectedFromUberSec5,
      "qst_collected_from_uber_sec5": qstCollectedFromUberSec5,
      "section_5_total": section5Total,
      "uber_gst_registration_number_sec5": uberGstRegistrationNumberSec5,
      "uber_qst_registration_number_sec5": uberQstRegistrationNumberSec5,
      "on_trip_mileage": onTripMileage,
      "online_mileage": onlineMileage,
      "other_income_miscellaneous": otherIncomeMiscellaneous,
      "period_from": periodFrom,
      "period_to": periodTo,
      "due_date": dueDate,
    };
  }
}
