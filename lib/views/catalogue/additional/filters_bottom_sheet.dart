import 'package:flutter/material.dart';
import 'package:car_showroom/models/catalogue/car_filters.dart';

class FiltersBottomSheet extends StatefulWidget {
  final CarFilters? initialFilters;

  const FiltersBottomSheet({super.key, this.initialFilters});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Значения полей
  String? _priceFromStr, _priceToStr;
  String? _yearFromStr, _yearToStr;
  String? _bodyType;
  String? _fuelType;
  String? _transmission;
  String? _driveType;
  String? _origin;

  final List<String> _bodyTypes = const [
    'Седан',
    'Хэтчбек',
    'Внедорожник',
    'Кроссовер',
    'Универсал',
    'Купе',
    'Минивэн',
    'Пикап',
    'Кабриолет',
    'Лифтбек',
  ];
  final List<String> _fuelTypes = const [
    'Бензин',
    'Дизель',
    'Электро',
    'Гибрид',
    'Газ',
  ];
  final List<String> _transmissions = const [
    'МКПП',
    'АКПП',
    'Робот',
    'Вариатор',
  ];
  final List<String> _driveTypes = const ['Передний', 'Задний', 'Полный'];
  final List<String> _origins = const ['Новый', 'Б/У'];

  @override
  void initState() {
    super.initState();
    // Заполняем из начальных фильтров
    final f = widget.initialFilters;
    _priceFromStr = f?.priceFrom?.toString();
    _priceToStr = f?.priceTo?.toString();
    _yearFromStr = f?.yearFrom?.toString();
    _yearToStr = f?.yearTo?.toString();
    _bodyType = f?.bodyType;
    _fuelType = f?.fuelType;
    _transmission = f?.transmission;
    _driveType = f?.driveType;
    _origin = f?.origin;
  }

  void _applyFilters() {
    if (!_formKey.currentState!.validate()) return;
    final filters = CarFilters(
      priceFrom: _priceFromStr != null && _priceFromStr!.isNotEmpty
          ? int.tryParse(_priceFromStr!)
          : null,
      priceTo: _priceToStr != null && _priceToStr!.isNotEmpty
          ? int.tryParse(_priceToStr!)
          : null,
      yearFrom: _yearFromStr != null && _yearFromStr!.isNotEmpty
          ? int.tryParse(_yearFromStr!)
          : null,
      yearTo: _yearToStr != null && _yearToStr!.isNotEmpty
          ? int.tryParse(_yearToStr!)
          : null,
      bodyType: _bodyType,
      fuelType: _fuelType,
      transmission: _transmission,
      driveType: _driveType,
      origin: _origin,
    );
    Navigator.pop(context, filters);
  }

  void _resetFilters() {
    setState(() {
      _priceFromStr = null;
      _priceToStr = null;
      _yearFromStr = null;
      _yearToStr = null;
      _bodyType = null;
      _fuelType = null;
      _transmission = null;
      _driveType = null;
      _origin = null;
    });
  }

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
              'Фильтры',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Цена от (₽)'),
                    keyboardType: TextInputType.number,
                    initialValue: _priceFromStr,
                    onChanged: (v) => _priceFromStr = v,
                    validator: (v) => _validateNumber(v, 'цена'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Цена до (₽)'),
                    keyboardType: TextInputType.number,
                    initialValue: _priceToStr,
                    onChanged: (v) => _priceToStr = v,
                    validator: (v) => _validateNumber(v, 'цена'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Год от'),
                    keyboardType: TextInputType.number,
                    initialValue: _yearFromStr,
                    onChanged: (v) => _yearFromStr = v,
                    validator: (v) => _validateNumber(v, 'год'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Год до'),
                    keyboardType: TextInputType.number,
                    initialValue: _yearToStr,
                    onChanged: (v) => _yearToStr = v,
                    validator: (v) => _validateNumber(v, 'год'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Тип кузова'),
              value: _bodyType,
              items: _bodyTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _bodyType = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Тип топлива'),
              value: _fuelType,
              items: _fuelTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _fuelType = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Коробка передач'),
              value: _transmission,
              items: _transmissions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _transmission = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Привод'),
              value: _driveType,
              items: _driveTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _driveType = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Состояние'),
              value: _origin,
              items: _origins
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _origin = v),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    child: const Text('Сбросить'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Применить'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) return null;
    if (int.tryParse(value) == null) {
      return 'Введите целое число';
    }
    return null;
  }
}
