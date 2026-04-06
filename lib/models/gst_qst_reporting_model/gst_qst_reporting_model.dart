class GetGstQstReportingModel {
  int? status;
  String? success;
  List<GstQstReportingData>? data;

  GetGstQstReportingModel({this.status, this.success, this.data});

  GetGstQstReportingModel.fromJson(Map<String, dynamic> json) {
    status = _parseNum(json['status'])?.toInt();
    success = json['success']?.toString();
    if (json['data'] != null) {
      data = <GstQstReportingData>[];
      json['data'].forEach((v) {
        data!.add(GstQstReportingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

class GstQstReportingData {
  int? id;
  int? userId;
  String? name;
  String? year;
  num? grossUberRidesFares;
  num? bookingFee;
  num? mtqDues;
  num? airportFee;
  num? splitFare;
  num? miscellaneous;
  num? tolls;
  num? tips;
  num? gstCollectedFromRiders;
  num? qstCollectedFromRiders;
  String? otherTaxableIncome;
  num? section1Total;
  num? serviceFee;
  num? otherAmounts;
  num? feeDiscount;
  num? gstPaidToUber;
  num? qstPaidToUber;
  num? section2Total;
  String? uberGstRegistrationNumber;
  String? uberQstRegistrationNumber;
  num? suppliesExcludingGstQst;
  num? gstRemittedByUber;
  num? qstRemittedByUber;
  num? gstCollectedFromRidersSec3;
  num? qstCollectedFromRidersSec3;
  String? yourGstNumberSec3;
  String? yourQstNumberSec3;
  num? grossUberEatsFare;
  num? eatsTips;
  num? gstCollectedFromUber;
  num? qstCollectedFromUber;
  num? section4Total;
  String? yourGstNumberSec4;
  String? yourQstNumberSec4;
  num? quickAccountingMethod6085;
  num? gstCollectedFromUberSec5;
  num? qstCollectedFromUberSec5;
  num? section5Total;
  String? uberGstRegistrationNumberSec5;
  String? uberQstRegistrationNumberSec5;
  num? onTripMileage;
  num? onlineMileage;
  num? otherIncomeMis;
  String? periodFrom;
  String? periodTo;
  String? dueDate;
  dynamic gstHstAdjustments104;
  dynamic itcAdjustmentsAndOtherAdjustments107;
  dynamic qstAdjustments204;
  dynamic itrAdjustmentsAndOtherAdjustments207;
  String? createdAt;
  String? updatedAt;

  GstQstReportingData({
    this.id,
    this.userId,
    this.name,
    this.year,
    this.grossUberRidesFares,
    this.bookingFee,
    this.mtqDues,
    this.airportFee,
    this.splitFare,
    this.miscellaneous,
    this.tolls,
    this.tips,
    this.gstCollectedFromRiders,
    this.qstCollectedFromRiders,
    this.otherTaxableIncome,
    this.section1Total,
    this.serviceFee,
    this.otherAmounts,
    this.feeDiscount,
    this.gstPaidToUber,
    this.qstPaidToUber,
    this.section2Total,
    this.uberGstRegistrationNumber,
    this.uberQstRegistrationNumber,
    this.suppliesExcludingGstQst,
    this.gstRemittedByUber,
    this.qstRemittedByUber,
    this.gstCollectedFromRidersSec3,
    this.qstCollectedFromRidersSec3,
    this.yourGstNumberSec3,
    this.yourQstNumberSec3,
    this.grossUberEatsFare,
    this.eatsTips,
    this.gstCollectedFromUber,
    this.qstCollectedFromUber,
    this.section4Total,
    this.yourGstNumberSec4,
    this.yourQstNumberSec4,
    this.quickAccountingMethod6085,
    this.gstCollectedFromUberSec5,
    this.qstCollectedFromUberSec5,
    this.section5Total,
    this.uberGstRegistrationNumberSec5,
    this.uberQstRegistrationNumberSec5,
    this.onTripMileage,
    this.onlineMileage,
    this.otherIncomeMis,
    this.periodFrom,
    this.periodTo,
    this.dueDate,
    this.gstHstAdjustments104,
    this.itcAdjustmentsAndOtherAdjustments107,
    this.qstAdjustments204,
    this.itrAdjustmentsAndOtherAdjustments207,
    this.createdAt,
    this.updatedAt,
  });

  factory GstQstReportingData.fromJson(Map<String, dynamic> json) {
    return GstQstReportingData(
      id: _parseNum(json['id'])?.toInt(),
      userId: _parseNum(json['user_id'])?.toInt(),
      name: json['name']?.toString(),
      year: json['year']?.toString(),
      grossUberRidesFares: _parseNum(json['gross_uber_rides_fares']),
      bookingFee: _parseNum(json['booking_fee']),
      mtqDues: _parseNum(json['mtq_dues']),
      airportFee: _parseNum(json['airport_fee']),
      splitFare: _parseNum(json['split_fare']),
      miscellaneous: _parseNum(json['miscellaneous']),
      tolls: _parseNum(json['tolls']),
      tips: _parseNum(json['tips']),
      gstCollectedFromRiders: _parseNum(json['gst_collected_from_riders']),
      qstCollectedFromRiders: _parseNum(json['qst_collected_from_riders']),
      otherTaxableIncome: json['other_taxable_income']?.toString(),
      section1Total: _parseNum(json['section_1_total']),
      serviceFee: _parseNum(json['service_fee']),
      otherAmounts: _parseNum(json['other_amounts']),
      feeDiscount: _parseNum(json['fee_discount']),
      gstPaidToUber: _parseNum(json['gst_paid_to_uber']),
      qstPaidToUber: _parseNum(json['qst_paid_to_uber']),
      section2Total: _parseNum(json['section_2_total']),
      uberGstRegistrationNumber: json['uber_gst_registration_number']?.toString(),
      uberQstRegistrationNumber: json['uber_qst_registration_number']?.toString(),
      suppliesExcludingGstQst: _parseNum(json['supplies_excluding_gst_qst']),
      gstRemittedByUber: _parseNum(json['gst_remitted_by_uber']),
      qstRemittedByUber: _parseNum(json['qst_remitted_by_uber']),
      gstCollectedFromRidersSec3: _parseNum(json['gst_collected_from_riders_sec3']),
      qstCollectedFromRidersSec3: _parseNum(json['qst_collected_from_riders_sec3']),
      yourGstNumberSec3: json['your_gst_number_sec3']?.toString(),
      yourQstNumberSec3: json['your_qst_number_sec3']?.toString(),
      grossUberEatsFare: _parseNum(json['gross_uber_eats_fare']),
      eatsTips: _parseNum(json['eats_tips']),
      gstCollectedFromUber: _parseNum(json['gst_collected_from_uber']),
      qstCollectedFromUber: _parseNum(json['qst_collected_from_uber']),
      section4Total: _parseNum(json['section_4_total']),
      yourGstNumberSec4: json['your_gst_number_sec4']?.toString(),
      yourQstNumberSec4: json['your_qst_number_sec4']?.toString(),
      quickAccountingMethod6085: _parseNum(json['quick_accounting_method_6085']),
      gstCollectedFromUberSec5: _parseNum(json['gst_collected_from_uber_sec5']),
      qstCollectedFromUberSec5: _parseNum(json['qst_collected_from_uber_sec5']),
      section5Total: _parseNum(json['section_5_total']),
      uberGstRegistrationNumberSec5: json['uber_gst_registration_number_sec5']?.toString(),
      uberQstRegistrationNumberSec5: json['uber_qst_registration_number_sec5']?.toString(),
      onTripMileage: _parseNum(json['on_trip_mileage']),
      onlineMileage: _parseNum(json['online_mileage']),
      otherIncomeMis: _parseNum(json["other_income_miscellaneous"]),
      periodFrom: json['period_from']?.toString(),
      periodTo: json['period_to']?.toString(),
      dueDate: json['due_date']?.toString(),
      gstHstAdjustments104: json['gst_hst_adjustments_104'],
      itcAdjustmentsAndOtherAdjustments107: json['itc_adjustments_and_other_adjustments_107'],
      qstAdjustments204: json['qst_adjustments_204'],
      itrAdjustmentsAndOtherAdjustments207: json['itr_adjustments_and_other_adjustments_207'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['name'] = name;
    data['year'] = year;
    data['gross_uber_rides_fares'] = grossUberRidesFares;
    data['booking_fee'] = bookingFee;
    data['mtq_dues'] = mtqDues;
    data['airport_fee'] = airportFee;
    data['split_fare'] = splitFare;
    data['miscellaneous'] = miscellaneous;
    data['tolls'] = tolls;
    data['tips'] = tips;
    data['gst_collected_from_riders'] = gstCollectedFromRiders;
    data['qst_collected_from_riders'] = qstCollectedFromRiders;
    data['other_taxable_income'] = otherTaxableIncome;
    data['section_1_total'] = section1Total;
    data['service_fee'] = serviceFee;
    data['other_amounts'] = otherAmounts;
    data['fee_discount'] = feeDiscount;
    data['gst_paid_to_uber'] = gstPaidToUber;
    data['qst_paid_to_uber'] = qstPaidToUber;
    data['section_2_total'] = section2Total;
    data['uber_gst_registration_number'] = uberGstRegistrationNumber;
    data['uber_qst_registration_number'] = uberQstRegistrationNumber;
    data['supplies_excluding_gst_qst'] = suppliesExcludingGstQst;
    data['gst_remitted_by_uber'] = gstRemittedByUber;
    data['qst_remitted_by_uber'] = qstRemittedByUber;
    data['gst_collected_from_riders_sec3'] = gstCollectedFromRidersSec3;
    data['qst_collected_from_riders_sec3'] = qstCollectedFromRidersSec3;
    data['your_gst_number_sec3'] = yourGstNumberSec3;
    data['your_qst_number_sec3'] = yourQstNumberSec3;
    data['gross_uber_eats_fare'] = grossUberEatsFare;
    data['eats_tips'] = eatsTips;
    data['gst_collected_from_uber'] = gstCollectedFromUber;
    data['qst_collected_from_uber'] = qstCollectedFromUber;
    data['section_4_total'] = section4Total;
    data['your_gst_number_sec4'] = yourGstNumberSec4;
    data['your_qst_number_sec4'] = yourQstNumberSec4;
    data['quick_accounting_method_6085'] = quickAccountingMethod6085;
    data['gst_collected_from_uber_sec5'] = gstCollectedFromUberSec5;
    data['qst_collected_from_uber_sec5'] = qstCollectedFromUberSec5;
    data['section_5_total'] = section5Total;
    data['uber_gst_registration_number_sec5'] = uberGstRegistrationNumberSec5;
    data['uber_qst_registration_number_sec5'] = uberQstRegistrationNumberSec5;
    data['on_trip_mileage'] = onTripMileage;
    data['online_mileage'] = onlineMileage;
    data['other_income_miscellaneous'] = otherIncomeMis;
    data['period_from'] = periodFrom;
    data['period_to'] = periodTo;
    data['due_date'] = dueDate;
    data['gst_hst_adjustments_104'] = gstHstAdjustments104;
    data['itc_adjustments_and_other_adjustments_107'] = itcAdjustmentsAndOtherAdjustments107;
    data['qst_adjustments_204'] = qstAdjustments204;
    data['itr_adjustments_and_other_adjustments_207'] = itrAdjustmentsAndOtherAdjustments207;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
