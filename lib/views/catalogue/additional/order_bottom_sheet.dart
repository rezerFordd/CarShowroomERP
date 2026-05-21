import 'package:flutter/material.dart';
import 'package:car_showroom/models/car/car_detail.dart';
import 'package:car_showroom/models/order/create_order_request.dart';
import 'package:car_showroom/services/order/orders_service.dart';

class OrderBottomSheet extends StatefulWidget {
  final CarDetail car;

  const OrderBottomSheet({super.key, required this.car});

  @override
  State<OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<OrderBottomSheet> {
  final OrdersService _ordersService = OrdersService();
  final _formKey = GlobalKey<FormState>();

  String _selectedService = 'Покупка';
  String? _downPaymentStr;
  String? _termMonthsStr;
  String? _interestRateStr;
  bool _isLoading = false;

  final List<String> _services = ['Покупка', 'Кредит'];
  final List<int> _termOptions = [12, 24, 36, 48, 60];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Оформление заказа',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Автомобиль: ${widget.car.brandName} ${widget.car.modelName}'),
            const SizedBox(height: 8),
            Text(
              'Цена: ${widget.car.price} ₽',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: _services
                  .map((s) => ButtonSegment(value: s, label: Text(s)))
                  .toList(),
              selected: {_selectedService},
              onSelectionChanged: (set) =>
                  setState(() => _selectedService = set.first),
            ),
            const SizedBox(height: 16),
            if (_selectedService == 'Кредит') ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Первоначальный взнос (₽)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _downPaymentStr = v,
                validator: (v) => _validateNumber(v, 'взнос'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Срок (мес)'),
                items: _termOptions
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text('$t мес')),
                    )
                    .toList(),
                onChanged: (v) => _termMonthsStr = v?.toString(),
                validator: (v) => v == null ? 'Выберите срок' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Процентная ставка (%)',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _interestRateStr = v,
                validator: (v) => _validateNumber(v, 'ставка'),
              ),
            ] else ...[
              // Покупка: можно добавить поле "Первоначальный взнос", но упростим
              const SizedBox(height: 8),
              Text('Оплата полной стоимости при оформлении.'),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitOrder,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.blue,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Оформить',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String? _validateNumber(String? value, String field) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) {
      return 'Введите целое число';
    }
    return null;
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    int totalAmount = widget.car.price;
    int downPayment = 0;
    int termMonths = 0;
    double interestRate = 0.0;
    double monthlyPayment = 0.0;

    if (_selectedService == 'Покупка') {
      downPayment = totalAmount; // Полная оплата
      termMonths = 0;
      interestRate = 0;
      monthlyPayment = totalAmount.toDouble();
    } else {
      // Кредит
      downPayment = int.tryParse(_downPaymentStr ?? '') ?? 0;
      if (downPayment > totalAmount) {
        _showError('Первоначальный взнос не может быть больше цены');
        setState(() => _isLoading = false);
        return;
      }
      termMonths = int.tryParse(_termMonthsStr ?? '') ?? 0;
      interestRate = double.tryParse(_interestRateStr ?? '') ?? 0.0;
      if (termMonths <= 0 || interestRate <= 0) {
        _showError('Заполните все поля кредита');
        setState(() => _isLoading = false);
        return;
      }
      // Рассчитываем ежемесячный платёж (аннуитет)
      final principal = totalAmount - downPayment;
      final monthlyRate = interestRate / 100 / 12;
      if (monthlyRate == 0) {
        monthlyPayment = principal / termMonths;
      } else {
        monthlyPayment =
            principal *
            monthlyRate *
            (1 + monthlyRate).pow(termMonths) /
            ((1 + monthlyRate).pow(termMonths) - 1);
      }
    }

    final int monthlyPaymentInt = monthlyPayment.round();

    final request = CreateOrderRequest(
      carId: widget.car.carId,
      service: _selectedService,
      totalAmount: totalAmount,
      downPaymentAmount: downPayment,
      termMonths: termMonths,
      interestRate: interestRate,
      monthlyPayment: monthlyPaymentInt,
      preorderId: null,
    );

    try {
      await _ordersService.createOrder(request);
      if (mounted) {
        Navigator.pop(context); // закрыть форму заказа
        Navigator.pop(context); // закрыть детальную модалку
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заказ успешно оформлен!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Ошибка оформления заказа: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// Extension для возведения в степень (pow)
extension on double {
  double pow(int exponent) {
    return _pow(this, exponent);
  }
}

double _pow(double base, int exponent) {
  if (exponent == 0) return 1;
  double result = base;
  for (int i = 1; i < exponent; i++) {
    result *= base;
  }
  return result;
}
