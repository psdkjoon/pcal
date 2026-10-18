import 'calendar_date.dart';
import 'formatting.dart';
import 'gregorian_date.dart';
import 'japanese_era.dart';
import 'pcal_exception.dart';

/// A date in the Japanese calendar, written with an imperial era (nengō).
///
/// A date is made of an [era], the [year] within that era (so Reiwa 1 is the
/// first year of Reiwa), and the month and day. Months and days are the same as
/// in the Gregorian calendar.
///
/// Supported dates start at 1873-01-01 (Meiji 6), the day Japan adopted the
/// Gregorian calendar. Earlier dates used the lunisolar calendar and are not
/// supported.
///
/// ```dart
/// final date = JapaneseDate(JapaneseEra.reiwa, 8, 10, 10);
/// print(date); // Reiwa 8-10-10
/// print(date.toKanjiString()); // 令和8年10月10日
/// print(date.toGregorian()); // 2026-10-10
/// ```
class JapaneseDate extends CalendarDate {
  /// Creates a date from an [era], the [year] within that era, a [month] and a
  /// [day].
  ///
  /// Throws an [InvalidYearException] if [year] is less than `1` or the date is
  /// beyond the supported range, an [InvalidMonthException] if [month] is not
  /// between `1` and `12`, and an [InvalidDayException] if [day] does not exist
  /// in that month. Throws an [InvalidEraException] if the day is not inside
  /// [era], or is before 1873-01-01.
  JapaneseDate(this.era, int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(era, year, month, day));

  /// Creates the Japanese date of the calendar day that [dateTime] falls on.
  ///
  /// The time of day and the time zone of [dateTime] are ignored, so the day is
  /// the one [dateTime] reports in its own time zone.
  ///
  /// Throws an [InvalidDayException] if that day is before 1873-01-01.
  factory JapaneseDate.fromDateTime(DateTime dateTime) =>
      JapaneseDate.fromJulianDayNumber(
        GregorianDate.fromDateTime(dateTime).julianDayNumber,
      );

  /// Creates the Japanese date of today, in the local time zone of the device.
  factory JapaneseDate.now() => JapaneseDate.fromDateTime(DateTime.now());

  /// Creates the date that falls on the given [julianDayNumber].
  ///
  /// Throws an [InvalidDayException] if [julianDayNumber] is before
  /// [minJulianDayNumber] or after [maxJulianDayNumber].
  factory JapaneseDate.fromJulianDayNumber(int julianDayNumber) {
    if (julianDayNumber < minJulianDayNumber ||
        julianDayNumber > maxJulianDayNumber) {
      throw InvalidDayException(
        'Julian day number $julianDayNumber is outside the supported '
        'Japanese range (1873-01-01 to ${GregorianDate.maxYear}-12-31).',
      );
    }
    final era = JapaneseEra.fromJulianDayNumber(julianDayNumber);
    final gregorian = GregorianDate.fromJulianDayNumber(julianDayNumber);
    return JapaneseDate(
      era,
      gregorian.year - era.startYear + 1,
      gregorian.month,
      gregorian.day,
    );
  }

  /// The era of this date.
  ///
  /// [year] is counted from the start of this era.
  final JapaneseEra era;

  /// The Julian day number of 1873-01-01, the first supported day.
  static final int minJulianDayNumber = GregorianDate(
    1873,
    1,
    1,
  ).julianDayNumber;

  /// The Julian day number of 9999-12-31, the last supported day.
  static final int maxJulianDayNumber = GregorianDate.maxJulianDayNumber;

  /// The names of the months in the form `1月` to `12月`.
  ///
  /// The list is indexed by the month number minus one.
  static const List<String> monthNames = [
    '1月',
    '2月',
    '3月',
    '4月',
    '5月',
    '6月',
    '7月',
    '8月',
    '9月',
    '10月',
    '11月',
    '12月',
  ];

  /// The traditional Japanese names of the months, such as `睦月` for the first
  /// month.
  ///
  /// The list is indexed by the month number minus one.
  static const List<String> traditionalMonthNames = [
    '睦月',
    '如月',
    '弥生',
    '卯月',
    '皐月',
    '水無月',
    '文月',
    '葉月',
    '長月',
    '神無月',
    '霜月',
    '師走',
  ];

  /// The Japanese names of the weekdays, such as `月曜日` for Monday.
  ///
  /// The list is indexed by [weekday] minus one, so `weekdayNames[0]` is
  /// `月曜日`.
  static const List<String> weekdayNames = [
    '月曜日',
    '火曜日',
    '水曜日',
    '木曜日',
    '金曜日',
    '土曜日',
    '日曜日',
  ];

  /// The Gregorian year in which this date falls.
  int get gregorianYear => era.startYear + year - 1;

  /// The imperial year (kōki, 皇紀) of this date.
  ///
  /// This is the [gregorianYear] plus 660, counting from the traditional
  /// founding of Japan in 660 BCE.
  int get imperialYear => gregorianYear + 660;

  /// The traditional name of this date's month, such as `睦月` for January.
  String get traditionalMonthName => traditionalMonthNames[month - 1];

  @override
  bool get isLeapYear => GregorianDate.isLeap(gregorianYear);

  @override
  int get daysInMonth => GregorianDate.daysInMonthOf(gregorianYear, month);

  @override
  String get monthName => monthNames[month - 1];

  @override
  String get weekdayName => weekdayNames[weekday - 1];

  @override
  JapaneseDate addDays(int days) =>
      JapaneseDate.fromJulianDayNumber(julianDayNumber + days);

  /// Returns the date written in kanji, for example `令和8年10月10日`.
  ///
  /// The first year of an era is written as `元` instead of `1`.
  String toKanjiString() =>
      '${era.kanjiName}${year == 1 ? '元' : year.toString()}年$month月$day日';

  /// Returns the date as the romaji era name followed by `year-month-day`, for
  /// example `Reiwa 8-10-10`.
  @override
  String toString() =>
      '${era.romajiName} $year-${padNumber(month, 2)}-${padNumber(day, 2)}';

  /// Validates the fields and returns the Julian day number of the date.
  static int _checkedJulianDayNumber(
    JapaneseEra era,
    int year,
    int month,
    int day,
  ) {
    if (year < 1) {
      throw InvalidYearException(
        'Japanese era year $year must be at least 1.',
      );
    }
    if (month < 1 || month > 12) {
      throw InvalidMonthException(
        'Japanese month $month is not in range (1, 12).',
      );
    }
    final gregorianYear = era.startYear + year - 1;
    final lastDay = GregorianDate.daysInMonthOf(gregorianYear, month);
    if (day < 1 || day > lastDay) {
      throw InvalidDayException(
        'Japanese day $day is not in range (1, $lastDay) '
        'for ${era.romajiName} $year-${padNumber(month, 2)}.',
      );
    }
    if (gregorianYear > GregorianDate.maxYear) {
      throw InvalidYearException(
        'Japanese year ${era.romajiName} $year is beyond the supported '
        'range.',
      );
    }
    final julianDayNumber = GregorianDate(
      gregorianYear,
      month,
      day,
    ).julianDayNumber;
    if (julianDayNumber < era.startJulianDayNumber ||
        julianDayNumber > era.endJulianDayNumber) {
      throw InvalidEraException(
        '${era.romajiName} $year-${padNumber(month, 2)}-${padNumber(day, 2)} '
        'is not within the ${era.romajiName} era.',
      );
    }
    if (julianDayNumber < minJulianDayNumber) {
      throw InvalidEraException(
        'Japanese dates before 1873-01-01 use the lunisolar calendar '
        'and are not supported.',
      );
    }
    return julianDayNumber;
  }
}
