import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  return DateFormat('EEE, MMM d').format(dateTime);
}