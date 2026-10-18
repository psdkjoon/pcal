import 'calendar_date.dart';
import 'formatting.dart';
import 'pcal_exception.dart';

/// A date in the Gregorian calendar.
///
/// Supported years are [minYear] to [maxYear]. The calendar rules are applied
/// to every year in that range, including the years before the calendar was
/// introduced (the proleptic Gregorian calendar).
///
/// ```dart
/// final date = GregorianDate(2026, 10, 10);
/// print(date); // 2026-10-10
/// print(date.weekdayName); // Saturday
/// print(date.toJalali()); // 1405-07-18
/// ```
class GregorianDate extends CalendarDate {
  /// Creates a date from a Gregorian [year], [month] and [day].
  ///
  /// Throws an [InvalidYearException] if [year] is not between [minYear] and
  /// [maxYear], an [InvalidMonthException] if [month] is not between `1` and
  /// `12`, and an [InvalidDayException] if [day] does not exist in that month.
  GregorianDate(int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(year, month, day));

  /// Creates the date with the same year, month and day as [dateTime].
  ///
  /// The time of day and the time zone of [dateTime] are ignored, so the result
  /// is the calendar day exactly as [dateTime] reports it.
  ///
  /// Throws an [InvalidYearException] if the year of [dateTime] is outside the
  /// supported range.
  factory GregorianDate.fromDateTime(DateTime dateTime) =>
      GregorianDate(dateTime.year, dateTime.month, dateTime.day);

  /// Creates the date of today, in the local time zone of the device.
  factory GregorianDate.now() => GregorianDate.fromDateTime(DateTime.now());

  /// Creates the date that falls on the given [julianDayNumber].
  ///
  /// Throws an [InvalidDayException] if [julianDayNumber] is before
  /// [minJulianDayNumber] or after [maxJulianDayNumber].
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

  /// The first supported year, `1`.
  static const int minYear = 1;

  /// The last supported year, `9999`.
  static const int maxYear = 9999;

  /// The Julian day number of 0001-01-01, the first supported day.
  static final int minJulianDayNumber = _toJulianDayNumber(minYear, 1, 1);

  /// The Julian day number of 9999-12-31, the last supported day.
  static final int maxJulianDayNumber = _toJulianDayNumber(maxYear, 12, 31);

  /// The English names of the months.
  ///
  /// The list is indexed by the month number minus one, so `monthNames[0]` is
  /// `January`.
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

  /// The English names of the weekdays.
  ///
  /// The list is indexed by [weekday] minus one, so `weekdayNames[0]` is
  /// `Monday`.
  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Whether [year] is a Gregorian leap year.
  ///
  /// A year is a leap year when it is divisible by 4, except for years
  /// divisible by 100 that are not also divisible by 400.
  static bool isLeap(int year) =>
      year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);

  /// Returns the number of days in the given [month] of the given [year].
  ///
  /// The [month] must be between `1` and `12`.
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

  /// Returns the date as `YYYY-MM-DD`, for example `2026-10-10`.
  @override
  String toString() =>
      '${padNumber(year, 4)}-${padNumber(month, 2)}-${padNumber(day, 2)}';

  /// Validates the fields and returns the Julian day number of the date.
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

  /// Converts a Gregorian date to a Julian day number, without validating it.
  static int _toJulianDayNumber(int year, int month, int day) {
    final shift = (month - 14) ~/ 12;
    return (1461 * (year + 4800 + shift)) ~/ 4 +
        (367 * (month - 2 - 12 * shift)) ~/ 12 -
        (3 * ((year + 4900 + shift) ~/ 100)) ~/ 4 +
        day -
        32075;
  }

  /// Converts a Julian day number to a Gregorian `(year, month, day)` record.
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
