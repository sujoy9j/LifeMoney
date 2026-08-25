import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _inr0 = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _compact = NumberFormat.compactCurrency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 1,
);

String money(num? value) => _inr0.format(value ?? 0);
String compactMoney(num? value) => _compact.format(value ?? 0);

double controllerNumber(TextEditingController controller) =>
    double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;

String percent(num value, {int digits = 0}) => '${value.toStringAsFixed(digits)}%';
