import 'package:intl/intl.dart';

class DateFormater {
  static String dateParser(String dateString) {
    DateTime tempDate = DateFormat('yyyy-MM-dd').parse(dateString);
    String date = DateFormat("dd MMMM, yyyy").format(tempDate);

    return date;
  }
}
