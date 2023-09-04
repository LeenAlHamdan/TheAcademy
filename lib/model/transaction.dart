class Transaction {
  String id;

  String type;
  double amount;
  String details;
  String createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.details,
    required this.amount,
    required this.createdAt,
  });
}
