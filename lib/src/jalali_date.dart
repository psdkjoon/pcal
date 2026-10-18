import 'calendar_date.dart';
import 'formatting.dart';
import 'gregorian_date.dart';
import 'pcal_exception.dart';

/// The Julian day number of 1 Farvardin of Jalali year 1.
const int _epochJulianDayNumber = 1948320;

/// The number of days in a 33-year Jalali cycle, which has 8 leap years.
const int _daysInThirtyThreeYears = 12053;

/// Returns the Julian day number of 1 Farvardin of the given Jalali [year].
int _startOfYear(int year) =>
    _epochJulianDayNumber + 365 * (year - 1) + (8 * (year - 1) + 29) ~/ 33;

/// Returns the number of days from the start of a Jalali year to the start of
/// [month].
int _daysBeforeMonth(int month) =>
    month <= 7 ? 31 * (month - 1) : 186 + 30 * (month - 7);

/// Returns the Julian day number of a Jalali date, without validating it.
///
/// The [month] must be between `1` and `12`.
int jalaliJulianDayNumber(int year, int month, int day) =>
    _startOfYear(year) + _daysBeforeMonth(month) + day - 1;

/// Converts a Julian day number to a Jalali `(year, month, day)` record.
///
/// The result is only meaningful for days inside the supported Jalali range.
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

/// A date in the Jalali (Persian, Solar Hijri) calendar.
///
/// Supported years are [minYear] to [maxYear]. Leap years follow the 33-year
/// arithmetic rule (see [isLeap]), which agrees with the official calendar for
/// the modern era. The weeks start on Saturday and the names are in Persian.
///
/// ```dart
/// final date = JalaliDate(1405, 7, 18);
/// print(date.monthName); // مهر
/// print(date.toGregorian()); // 2026-10-10
/// ```
class JalaliDate extends CalendarDate {
  /// Creates a date from a Jalali [year], [month] and [day].
  ///
  /// Throws an [InvalidYearException] if [year] is not between [minYear] and
  /// [maxYear], an [InvalidMonthException] if [month] is not between `1` and
  /// `12`, and an [InvalidDayException] if [day] does not exist in that month.
  JalaliDate(int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(year, month, day));

  /// Creates the Jalali date of the calendar day that [dateTime] falls on.
  ///
  /// The time of day and the time zone of [dateTime] are ignored, so the day is
  /// the one [dateTime] reports in its own time zone.
  ///
  /// Throws an [InvalidDayException] if that day is outside the supported
  /// Jalali range.
  factory JalaliDate.fromDateTime(DateTime dateTime) =>
      JalaliDate.fromJulianDayNumber(
        GregorianDate.fromDateTime(dateTime).julianDayNumber,
      );

  /// Creates the Jalali date of today, in the local time zone of the device.
  factory JalaliDate.now() => JalaliDate.fromDateTime(DateTime.now());

  /// Creates the date that falls on the given [julianDayNumber].
  ///
  /// Throws an [InvalidDayException] if [julianDayNumber] is before
  /// [minJulianDayNumber] or after [maxJulianDayNumber].
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

  /// The first supported year, `1`.
  static const int minYear = 1;

  /// The last supported year, `3178`.
  static const int maxYear = 3178;

  /// The Julian day number of 1 Farvardin of [minYear], the first supported
  /// day.
  static final int minJulianDayNumber = jalaliJulianDayNumber(minYear, 1, 1);

  /// The Julian day number of the last day of [maxYear].
  static final int maxJulianDayNumber =
      jalaliJulianDayNumber(maxYear, 12, daysInMonthOf(maxYear, 12));

  /// The Persian names of the months.
  ///
  /// The list is indexed by the month number minus one, so `monthNames[0]` is
  /// `فروردین`.
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

  /// The Persian names of the weekdays, starting with Saturday.
  ///
  /// The list is indexed from Saturday at `0`, so `weekdayNames[0]` is `شنبه`
  /// and `weekdayNames[6]` is `جمعه` (Friday). Note that this is not the same
  /// order as [weekday], which starts on Monday.
  static const List<String> weekdayNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
  ];

  /// Whether [year] is a Jalali leap year.
  ///
  /// Leap years follow the 33-year arithmetic rule: a year is a leap year when
  /// `(25 * year + 11) % 33 < 8`.
  static bool isLeap(int year) => (25 * year + 11) % 33 < 8;

  /// Returns the number of days in the given [month] of the given [year].
  ///
  /// Months 1 to 6 have 31 days and months 7 to 11 have 30 days. Month 12 has
  /// 30 days in a leap year and 29 days otherwise.
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

  /// Returns the date as `YYYY-MM-DD`, for example `1405-07-18`.
  @override
  String toString() =>
      '${padNumber(year, 4)}-${padNumber(month, 2)}-${padNumber(day, 2)}';

  /// Validates the fields and returns the Julian day number of the date.
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
