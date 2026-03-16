import 'package:intl/intl.dart';

/// Formats DateTime to Indonesian locale string
/// Example: DateTime(2024, 11, 15) → "15 Nov 2024"
class DateFormatter {
  DateFormatter._();

  /// Format date to "dd MMM yyyy" (e.g., "15 Nov 2024")
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format date to "dd MMMM yyyy" (e.g., "15 November 2024")
  static String formatDateLong(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format date to "EEEE, dd MMMM yyyy" (e.g., "Jumat, 15 November 2024")
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  /// Format time to "HH:mm" (e.g., "23:59")
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date and time to "dd MMM yyyy, HH:mm"
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)}, ${formatTime(date)}';
  }

  /// Format relative time (e.g., "2 jam yang lalu", "kemarin")
  static String formatRelative(DateTime date, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final difference = currentTime.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return formatDate(date);
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
}
