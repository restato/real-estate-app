class Transaction {
  final String amount;
  final String yearOfConstruction;
  // final String type;
  final String dong;
  final String aptName;
  final String year;
  final String month;
  final String day;
  final String dedicatedArea;
  final String jibun;
  final String areaCode;
  final String floor;

  const Transaction(
      {this.amount = "",
      this.yearOfConstruction = "",
      // this.type = "",
      this.dong = "",
      this.aptName = "",
      this.year = "",
      this.month = "",
      this.day = "",
      this.dedicatedArea = "",
      this.jibun = "",
      this.areaCode = "",
      this.floor = ""});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['거래금액'],
      yearOfConstruction: json['건축년도'],
      // type: json['거래유형'],
      dong: json['법정동'],
      aptName: json['아파트'],
      year: json['년'],
      month: json['월'],
      day: json['일'],
      dedicatedArea: json['전용면적'],
      jibun: json['지번'],
      areaCode: json['지역코드'],
      floor: json['층'],
    );
  }
}
