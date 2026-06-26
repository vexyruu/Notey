import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateFormatter = DateFormat('d MMM yyyy');
  static final _dateTimeFormatter = DateFormat('d MMM yyyy, HH:mm');

  static String formatDate(DateTime date) => _dateFormatter.format(date);

  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }
}
