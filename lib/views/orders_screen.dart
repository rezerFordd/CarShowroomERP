import 'package:flutter/material.dart';
import 'package:car_showroom/services/order/orders_service.dart';
import 'package:car_showroom/models/order/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersService _ordersService = OrdersService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _ordersService.getMyOrders();
      if (mounted) setState(() => _orders = orders);
    } catch (e) {
      if (mounted) _showError('Ошибка загрузки заказов');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить заказ?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _ordersService.deleteOrder(orderId);
      if (mounted) {
        setState(() => _orders.removeWhere((o) => o.orderId == orderId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Заказ удалён')));
      }
    } catch (e) {
      if (mounted) _showError('Не удалось удалить заказ');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('У вас пока нет заказов'))
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (ctx, i) {
                  final order = _orders[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text('Заказ №${order.orderId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Авто ID: ${order.carId}'),
                          Text('Сумма: ${order.totalAmount} ₽'),
                          Text('Статус: ${order.status}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteOrder(order.orderId),
                      ),
                      onTap: () {
                        // Можно открыть детали заказа, но пока не требуется
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
