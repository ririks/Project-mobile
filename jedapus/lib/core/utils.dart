import 'package:flutter/material.dart';

// Extensions
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  String get initials {
    return split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
  }
  
  bool get isValidNIP {
    return RegExp(r'^\d{8,18}$').hasMatch(this);
  }
}

extension DateTimeExtensions on DateTime {
  String get indonesianFormat {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '$day ${months[month]} $year';
  }
  
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }
}

extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}

// Validators
class Validators {
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }
    return null;
  }
  
  static String? nip(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIP tidak boleh kosong';
    }
    if (!value.isValidNIP) {
      return 'Format NIP tidak valid (8-18 digit)';
    }
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }
  
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'Field'} minimal $minLength karakter';
    }
    return null;
  }
  
  static String? dateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Tanggal tidak boleh kosong';
    }
    if (startDate.isAfter(endDate)) {
      return 'Tanggal mulai tidak boleh setelah tanggal selesai';
    }
    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Tanggal tidak boleh di masa lalu';
    }
    return null;
  }
}

// Utility Functions
class AppUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE83C3C) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return '${start.day} ${_getMonthName(start.month)} ${start.year}';
    }
    return '${start.day} ${_getMonthName(start.month)} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
  }
  
  static String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }
  
  static String formatDuration(int days) {
    if (days == 1) return '1 hari';
    return '$days hari';
  }
  
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
  
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Loading State Mixin
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
  
  Future<R> withLoading<R>(Future<R> Function() operation) async {
    setLoading(true);
    try {
      return await operation();
    } finally {
      setLoading(false);
    }
  }
}