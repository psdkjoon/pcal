import 'calendar_date.dart';
import 'formatting.dart';
import 'gregorian_date.dart';
import 'pcal_exception.dart';

const int _epochJulianDayNumber = 1948320;

const int _daysInThirtyThreeYears = 12053;

int _startOfYear(int year) =>
    _epochJulianDayNumber + 365 * (year - 1) + (8 * (year - 1) + 29) ~/ 33;

int _daysBeforeMonth(int month) =>
    month <= 7 ? 31 * (month - 1) : 186 + 30 * (month - 7);

int jalaliJulianDayNumber(int year, int month, int day) =>
    _startOfYear(year) + _daysBeforeMonth(month) + day - 1;

(int, int, int) jalaliFieldsFromJulianDayNumber(int julianDayNumber) {
  var year =
      (33 * (julianDayNumber - _epochJulianDayNumber)) ~/
          _daysInThirtyThreeYears +
      1;
  while (_startOfYear(year + 1) <= julianDayNumber) {
    year++;
  }
  while (_startOfYear(year) > julianDayNumber) {
    year--;
  }
  final dayOfYear = julianDayNumber - _startOfYear(year);
  var month = 1;
  while (month < 12 && dayOfYear >= _daysBeforeMonth(month + 1)) {
    month++;
  }
  return (year, month, dayOfYear - _daysBeforeMonth(month) + 1);
}

class JalaliDate extends CalendarDate {
  JalaliDate(int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(year, month, day));

  factory JalaliDate.fromDateTime(DateTime dateTime) =>
      JalaliDate.fromJulianDayNumber(
        GregorianDate.fromDateTime(dateTime).julianDayNumber,
      );

  factory JalaliDate.now() => JalaliDate.fromDateTime(DateTime.now());

  factory JalaliDate.fromJulianDayNumber(int julianDayNumber) {
    if (julianDayNumber < minJulianDayNumber ||
        julianDayNumber > maxJulianDayNumber) {
      throw InvalidDayException(
        'Julian day number $julianDayNumber is outside the supported '
        'Jalali range (years $minYear to $maxYear).',
      );
    }
    final (year, month, day) = jalaliFieldsFromJulianDayNumber(
      julianDayNumber,
    );
    return JalaliDate(year, month, day);
  }

  static const int minYear = 1;

  static const int maxYear = 3178;

  static final int minJulianDayNumber = jalaliJulianDayNumber(minYear, 1, 1);

  static final int maxJulianDayNumber =
      jalaliJulianDayNumber(maxYear, 12, daysInMonthOf(maxYear, 12));

  static const List<String> monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const List<String> weekdayNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  static bool isLeap(int year) => (25 * year + 11) % 33 < 8;

  static int daysInMonthOf(int year, int month) {
    if (month <= 6) {
      return 31;
    }
    if (month <= 11) {
      return 30;
    }
    return isLeap(year) ? 30 : 29;
  }

  @override
  bool get isLeapYear => isLeap(year);

  @override
  int get daysInMonth => daysInMonthOf(year, month);

  @override
  String get monthName => monthNames[month - 1];

  @override
  String get weekdayName => weekdayNames[(weekday + 1) % 7];

  @override
  JalaliDate addDays(int days) =>
      JalaliDate.fromJulianDayNumber(julianDayNumber + days);

  @override
  String toString() =>
      '${padNumber(year, 4)}-${padNumber(month, 2)}-${padNumber(day, 2)}';

  static int _checkedJulianDayNumber(int year, int month, int day) {
    if (year < minYear || year > maxYear) {
      throw InvalidYearException(
        'Jalali year $year is not in range ($minYear, $maxYear).',
      );
    }
    if (month < 1 || month > 12) {
      throw InvalidMonthException(
        'Jalali month $month is not in range (1, 12).',
      );
    }
    final lastDay = daysInMonthOf(year, month);
    if (day < 1 || day > lastDay) {
      throw InvalidDayException(
        'Jalali day $day is not in range (1, $lastDay) '
        'for $year-${padNumber(month, 2)}.',
      );
    }
    return jalaliJulianDayNumber(year, month, day);
  }
}
