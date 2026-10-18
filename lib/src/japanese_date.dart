import 'calendar_date.dart';
import 'formatting.dart';
import 'gregorian_date.dart';
import 'japanese_era.dart';
import 'pcal_exception.dart';

class JapaneseDate extends CalendarDate {
  JapaneseDate(this.era, int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(era, year, month, day));

  factory JapaneseDate.fromDateTime(DateTime dateTime) =>
      JapaneseDate.fromJulianDayNumber(
        GregorianDate.fromDateTime(dateTime).julianDayNumber,
      );

  factory JapaneseDate.now() => JapaneseDate.fromDateTime(DateTime.now());

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

  final JapaneseEra era;

  static final int minJulianDayNumber = GregorianDate(
    1873,
    1,
    1,
  ).julianDayNumber;

  static final int maxJulianDayNumber = GregorianDate.maxJulianDayNumber;

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

  static const List<String> weekdayNames = [
    '月曜日',
    '火曜日',
    '水曜日',
    '木曜日',
    '金曜日',
    '土曜日',
    '日曜日',
  ];

  int get gregorianYear => era.startYear + year - 1;

  int get imperialYear => gregorianYear + 660;

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

  String toKanjiString() =>
      '${era.kanjiName}${year == 1 ? '元' : year.toString()}年$month月$day日';

  @override
  String toString() =>
      '${era.romajiName} $year-${padNumber(month, 2)}-${padNumber(day, 2)}';

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
