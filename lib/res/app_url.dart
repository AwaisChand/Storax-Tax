import 'helper.dart';

class AppUrl {
  // static var baseUrl = 'http://stora.thetechnologies.net/';
  static var baseUrl = 'https://storatax.com/';



  ///Auth End Points

  static var loginEndPoint = '${baseUrl}api/auth/signin';

  static var logoutEndPoint = '${baseUrl}api/auth/signout';

  static var sendOtpEndPoint = '${baseUrl}api/password/send-otp';

  static var verifyOtpEndPoint = '${baseUrl}api/password/verify-otp';

  static var resendOtpEndPoint = '${baseUrl}api/password/resend-otp';

  static var resetPasswordEndPoint = '${baseUrl}api/password/reset';

  static var updateProfileEndPoint = '${baseUrl}api/auth/client/profile/update';

  static var settingsEndPoint = '${baseUrl}api/auth/password/update';

  static var taxProfessionalRegEndPoint =
      '${baseUrl}api/auth/register-tax-professionals';

  static var clientPlanRegEndPoint = '${baseUrl}api/auth/register-client';

  static var paymentSuccessfulEndPoint =
      '${baseUrl}api/auth/payment-successfull';

  static var userProfileEndPoint = '${baseUrl}api/get-profile';
  static var deleteEndPoint = '${baseUrl}api/delete-account';
  static var verifyCouponEndPoint = '${baseUrl}api/plans/verify-coupon';
  static var saveSubscriptionEndPoint = '${baseUrl}api/plans/subscribe';
  static var myPlansEndPoint = '${baseUrl}api/plans/my-plans';
  static var unSubscribePlanEndPoint = '${baseUrl}api/auth/plan-unsubscribe';
  static var freePlanSubscriptionEndPoint = '${baseUrl}api/plans/freeSubscribe';

  static String planDetailsUrl(int planId) {
    return '${baseUrl}api/plans/$planId/details';
  }

  ///Accountant Client Api
  static var getAccountantsEndPoint = '${baseUrl}api/accountants';
  static var connectAccountantEndPoint = '${baseUrl}api/accountants/connect';

  ///Tax Manager End Points

  static var createFileEndPoint = '${baseUrl}api/files';
  static var getCategoryEndPoint = '${baseUrl}api/tax-manager-categories';
  static var filesEndPoint = '${baseUrl}api/files';
  static var uploadFileEndPoint = '${baseUrl}api/file';
  static var forwardFileEndPoint = '${baseUrl}api/forward-file';
  static var forwardMultipleFileEndPoint =
      '${baseUrl}api/forward-multiple-files';
  static var scanTaxManagerEndPoint = '${baseUrl}api/scan';
  static var personalInfoEndPoint =
      '${baseUrl}api/income-tax/personal-information';
  static String forwardPersonalFileEndPoint(int id) =>
      '${baseUrl}api/income-tax/personal-information/$id/forward';
  static var previousInfoEndPoint =
      '${baseUrl}api/income-tax/personal-information-previous';

  ///Gasoline End Points
  static var gasolineEndPoint = '${baseUrl}api/gasolines';
  static var scanFileEndPoint = '${baseUrl}api/gasolines/scan';
  static var multipleForwardGasolineEndPoint =
      '${baseUrl}api/gasolines/forward-multiple';
  static var gasolineReportEndPoint = '${baseUrl}api/gasolines/report';
  static var gasolineReportForwardEndPoint =
      '${baseUrl}api/gasoline-report/forward';
  static var printReportEndPoint = '${baseUrl}api/gasoline-report/print';
  static var getTransactionReportReportEndPoint =
      '${baseUrl}api/gasolines/gasoline-transactions/report';
  static var printTransactionReportEndPoint =
      '${baseUrl}api/gasolines/gasoline-transactions/report/print';
  static var forwardEmailReportEndPoint =
      '${baseUrl}api/gasolines/gasoline-transactions/report/forward';

  ///Rental Property End Points
  static var getRentalPropertyPlanEndPoint =
      '${baseUrl}api/rental-property/plans';
  static var rentalPropertyAccountSettingEndPoint =
      '${baseUrl}api/account-settings';
  static var propertyOwnerEndPoint = '${baseUrl}api/property-owner';
  static var incomeTypesEndPoint = '${baseUrl}api/income-types';
  static var entriesEndPoint = '${baseUrl}api/regular-entries';
  static var expenseUpdateEndPoint = '${baseUrl}api/regular-entries-update';
  static var forwardMultipleEntriesEndPoint =
      '${baseUrl}api/regular-entries/forward';
  static var forwardReportEndPoint = '${baseUrl}api/reports/forward';
  static var databaseEntriesEndPoint = '${baseUrl}api/regular-entries/database';
  static var reportScheduleEndPoint = '${baseUrl}api/report/pdf';
  static var allRegularEntriesPrintEndPoint =
      '${baseUrl}api/regular-entry/print';
  static var printT776EndPoint =
      '${baseUrl}api/report/T776/print';
  static var printF1040EndPoint =
      '${baseUrl}api/report/F1040/print';

  ///Uber GST/QST Reporting(Quebec) End Points
  static var quebecEndPoint = '${baseUrl}api/quebec';
  static var quebecScanEndPoint = '${baseUrl}api/quebec/ocr-scan-uber';
  static var forwardGrossIncomeEndPoint = '${baseUrl}api/quebec/gross-income-report/forward';
  static var forwardGSTQSTEndPoint = '${baseUrl}api/quebec/quebec-report/forward';


  ///Viewrs End Points
  static var viewrsEndPoint = '${baseUrl}api/viewers';

  ///Team Members End Points
  static var teamMemberEndPoints = '${baseUrl}api/teams';

  ///Dashboard End Points
  static var dashboardEndPoint = '${baseUrl}api/client-dashboard';

  ///Stripe Integration End Points

  static var createPaymentIntentEndPoint = '${baseUrl}api/stripe/payment-intent/create';
  static var createSetupIntentEndPoint = '${baseUrl}api/stripe/setup-intent/create';
  static var createSubscriptionEndPoint = '${baseUrl}api/stripe/subscription/create';



  static var customerEndPoint = "https://api.stripe.com/v1/customers";
  static var paymentAttachmentEndPoint =
      "https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach";
  static var subscriptionEndPoint = "https://api.stripe.com/v1/subscriptions";
  static var paymentIntentEndPoint =
      "https://api.stripe.com/v1/payment_intents";
}
