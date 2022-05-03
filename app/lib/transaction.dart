class Transaction {
  final String year;

  const Transaction({
    required this.year,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      year: json['거래금액'],
    );
  }
}
