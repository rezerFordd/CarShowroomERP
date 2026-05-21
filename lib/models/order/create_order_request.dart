class CreateOrderRequest {
  final int carId;
  final String service;
  final int totalAmount;
  final int downPaymentAmount;
  final int termMonths;
  final double interestRate;
  final double monthlyPayment;
  final int? preorderId;

  CreateOrderRequest({
    required this.carId,
    required this.service,
    required this.totalAmount,
    required this.downPaymentAmount,
    required this.termMonths,
    required this.interestRate,
    required this.monthlyPayment,
    this.preorderId,
  });

  Map<String, dynamic> toJson() => {
    'car_id': carId,
    'service': service,
    'total_amount': totalAmount,
    'down_payment_amount': downPaymentAmount,
    'term_months': termMonths,
    'interest_rate': interestRate,
    'monthly_payment': monthlyPayment,
    if (preorderId != null) 'preorder_id': preorderId,
  };
}
