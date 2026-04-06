// class Dependent {
//   String? childName;
//   String? hasDisability;
//   String? birthDate;
//   String? country;
//   int? monthsLivedWithYou;
//   double? income;
//
//   Dependent({
//     this.childName,
//     this.hasDisability,
//     this.birthDate,
//     this.country,
//     this.monthsLivedWithYou,
//     this.income,
//   });
//
//   Map<String, dynamic> toJson() => {
//     "child_name": childName,
//     "disability": hasDisability,
//     "birth_date": birthDate,
//     "country": country,
//     "months_lived_with_you": monthsLivedWithYou,
//     "income": income,
//   };
//
//   factory Dependent.fromJson(Map<String, dynamic> json) => Dependent(
//     childName: json["child_name"],
//     hasDisability: json["disability"],
//     birthDate: json["birth_date"],
//     country: json["country"],
//     monthsLivedWithYou: json["months_lived_with_you"],
//     income: (json["income"] is num)
//         ? (json["income"] as num).toDouble()
//         : double.tryParse(json["income"].toString()),
//   );
// }
