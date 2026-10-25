class InvoiceModel {
  final String id;
  final String userId;
  final String invoiceNumber;
  final String description;
  final double amount;
  final DateTime date;
  final bool isPaid;
  final String paymentMethod;

  InvoiceModel({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.description,
    required this.amount,
    required this.date,
    this.isPaid = true,
    this.paymentMethod = 'Cash',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'invoiceNumber': invoiceNumber,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'isPaid': isPaid,
      'paymentMethod': paymentMethod,
    };
  }

  factory InvoiceModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return InvoiceModel(
      id: id,
      userId: map['userId'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      isPaid: map['isPaid'] ?? true,
      paymentMethod: map['paymentMethod'] ?? 'Cash',
    );
  }

}