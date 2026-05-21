class Order {
  final int orderId;
  final int userId;
  final int carId;
  final int? preorderId;
  final String service;
  final String status;
  final int totalAmount;
  final int downPaymentAmount;
  final int termMonths;
  final double interestRate;
  final double monthlyPayment;

  Order({
    required this.orderId,
    required this.userId,
    required this.carId,
    this.preorderId,
    required this.service,
    required this.status,
    required this.totalAmount,
    required this.downPaymentAmount,
    required this.termMonths,
    required this.interestRate,
    required this.monthlyPayment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] as int,
      userId: json['user_id'] as int,
      carId: json['car_id'] as int,
      preorderId: json['preorder_id'] as int?,
      service: json['service'] as String,
      status: json['status'] as String,
      totalAmount: json['total_amount'] as int,
      downPaymentAmount: json['down_payment_amount'] as int,
      termMonths: json['term_months'] as int,
      interestRate: (json['interest_rate'] as num).toDouble(),
      monthlyPayment: (json['monthly_payment'] as num).toDouble(),
    );
  }
}
