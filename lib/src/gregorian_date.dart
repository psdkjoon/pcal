import 'calendar_date.dart';
import 'formatting.dart';
import 'pcal_exception.dart';

class GregorianDate extends CalendarDate {
  GregorianDate(int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(year, month, day));

  factory GregorianDate.fromDateTime(DateTime dateTime) =>
      GregorianDate(dateTime.year, dateTime.month, dateTime.day);

  factory GregorianDate.now() => GregorianDate.fromDateTime(DateTime.now());

  factory GregorianDate.fromJulianDayNumber(int julianDayNumber) {
    if (julianDayNumber < minJulianDayNumber ||
        julianDayNumber > maxJulianDayNumber) {
      throw InvalidDayException(
        'Julian day number $julianDayNumber is outside the supported '
        'Gregorian range (years $minYear to $maxYear).',
      );
    }
    final (year, month, day) = _fieldsFromJulianDayNumber(julianDayNumber);
    return GregorianDate(year, month, day);
  }

  static const int minYear = 1;

  static const int maxYear = 9999;

  static final int minJulianDayNumber = _toJulianDayNumber(minYear, 1, 1);

  static final int maxJulianDayNumber = _toJulianDayNumber(maxYear, 12, 31);

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static bool isLeap(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  static int daysInMonthOf(int year, int month) {
    if (month == 2) {
      return isLeap(year) ? 29 : 28;
    }
    return const [4, 6, 9, 11].contains(month) ? 30 : 31;
  }

  @override
  bool get isLeapYear => isLeap(year);

  @override
  int get daysInMonth => daysInMonthOf(year, month);

  @override
  String get monthName => monthNames[month - 1];

  @override
  String get weekdayName => weekdayNames[weekday - 1];

  @override
  GregorianDate addDays(int days) =>
      GregorianDate.fromJulianDayNumber(julianDayNumber + days);

  @override
  String toString() =>
      '${padNumber(year, 4)}-${padNumber(month, 2)}-${padNumber(day, 2)}';

  static int _checkedJulianDayNumber(int year, int month, int day) {
    if (year < minYear || year > maxYear) {
      throw InvalidYearException(
        'Gregorian year $year is not in range ($minYear, $maxYear).',
      );
    }
    if (month < 1 || month > 12) {
      throw InvalidMonthException(
        'Gregorian month $month is not in range (1, 12).',
      );
    }
    final lastDay = daysInMonthOf(year, month);
    if (day < 1 || day > lastDay) {
      throw InvalidDayException(
        'Gregorian day $day is not in range (1, $lastDay) '
        'for $year-${padNumber(month, 2)}.',
      );
    }
    return _toJulianDayNumber(year, month, day);
  }

  static int _toJulianDayNumber(int year, int month, int day) {
    final shift = (month - 14) ~/ 12;
    return (1461 * (year + 4800 + shift)) ~/ 4 +
        (367 * (month - 2 - 12 * shift)) ~/ 12 -
        (3 * ((year + 4900 + shift) ~/ 100)) ~/ 4 +
        day -
        32075;
  }

  static (int, int, int) _fieldsFromJulianDayNumber(int julianDayNumber) {
    var remainder = julianDayNumber + 68569;
    final centuries = (4 * remainder) ~/ 146097;
    remainder = remainder - (146097 * centuries + 3) ~/ 4;
    final yearsPart = (4000 * (remainder + 1)) ~/ 1461001;
    remainder = remainder - (1461 * yearsPart) ~/ 4 + 31;
    final monthsPart = (80 * remainder) ~/ 2447;
    final day = remainder - (2447 * monthsPart) ~/ 80;
    final carry = monthsPart ~/ 11;
    final month = monthsPart + 2 - 12 * carry;
    final year = 100 * (centuries - 49) + yearsPart + carry;
    return (year, month, day);
  }
}
