import 'calendar_date.dart';
import 'formatting.dart';
import 'gregorian_date.dart';
import 'jalali_date.dart';
import 'pcal_exception.dart';

/// A date in the Deylami (Gilaki / Dilami) calendar.
///
/// A year has twelve months of 30 days, numbered `1` to `12`, and a short month
/// `0`, the Panjik (پنجيک), of five days. The Panjik sits between months 8 and
/// 9. In a leap year the Panjik has a sixth day, the Vishak, which is day `0`
/// of month `0`.
///
/// The year starts on 17 Mordad of the Jalali calendar, and a year is a leap
/// year when the Jalali year [year] - 195 is a leap year. Supported years are
/// [minYear] to [maxYear].
///
/// ```dart
/// final date = DeylamiDate(1600, 3, 4);
/// print(date.monthName); // أرئه ما
/// print(date.toGregorian()); // 2026-10-10
/// ```
class DeylamiDate extends CalendarDate {
  /// Creates a date from a Deylami [year], [month] and [day].
  ///
  /// The [month] is `0` for the Panjik and `1` to `12` for the other months.
  /// The [day] is `1` to `30` (`1` to `5` in the Panjik). The Vishak is day `0`
  /// of month `0`, and exists only in leap years.
  ///
  /// Throws an [InvalidYearException] if [year] is not between [minYear] and
  /// [maxYear], an [InvalidMonthException] if [month] is not between `0` and
  /// `12`, and an [InvalidDayException] if [day] is not between `0` and `30`,
  /// if [day] is `0` outside the Panjik, or if the date is outside the
  /// supported range. Throws an [InvalidPanjikException] if [day] is greater
  /// than `5` in the Panjik, and an [InvalidVishakException] for the Vishak of
  /// a year that is not a leap year.
  DeylamiDate(int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(year, month, day));

  /// Creates the Deylami date of the calendar day that [dateTime] falls on.
  ///
  /// The time of day and the time zone of [dateTime] are ignored, so the day is
  /// the one [dateTime] reports in its own time zone.
  ///
  /// Throws an [InvalidDayException] if that day is outside the supported
  /// Deylami range.
  factory DeylamiDate.fromDateTime(DateTime dateTime) =>
      DeylamiDate.fromJulianDayNumber(
        GregorianDate.fromDateTime(dateTime).julianDayNumber,
      );

  /// Creates the Deylami date of today, in the local time zone of the device.
  factory DeylamiDate.now() => DeylamiDate.fromDateTime(DateTime.now());

  /// Creates the date that falls on the given [julianDayNumber].
  ///
  /// Throws an [InvalidDayException] if [julianDayNumber] is before
  /// [minJulianDayNumber] or after [maxJulianDayNumber].
  factory DeylamiDate.fromJulianDayNumber(int julianDayNumber) {
    if (julianDayNumber < minJulianDayNumber ||
        julianDayNumber > maxJulianDayNumber) {
      throw InvalidDayException(
        'Julian day number $julianDayNumber is outside the supported '
        'Deylami range (years $minYear to $maxYear).',
      );
    }
    final (jalaliYear, jalaliMonth, jalaliDay) =
        jalaliFieldsFromJulianDayNumber(julianDayNumber);
    final (year, month, day) = _fromJalaliFields(
      jalaliYear,
      jalaliMonth,
      jalaliDay,
    );
    return DeylamiDate(year, month, day);
  }

  /// The first supported year, `195`.
  static const int minYear = 195;

  /// The last supported year, `3372`.
  static const int maxYear = 3372;

  /// The Julian day number of 1 Farvardin of Jalali year 1, the first supported
  /// day.
  static final int minJulianDayNumber = jalaliJulianDayNumber(1, 1, 1);

  /// The Julian day number of 16 Mordad of Jalali year 3178, the last supported
  /// day.
  static final int maxJulianDayNumber = jalaliJulianDayNumber(3178, 5, 16);

  /// The Deylami names of the months.
  ///
  /// The list is indexed by the month number, so `monthNames[0]` is the Panjik
  /// (`پنجيک`) and `monthNames[1]` is `نؤرۊز ما`.
  static const List<String> monthNames = [
    'پنجيک',
    'نؤرۊز ما',
    'کۊرچ ٚ ما',
    'أرئه ما',
    'تیر ما',
    'مۊردال ما',
    'شریرما',
    'أمیر ما',
    'آول ما',
    'سیا ما',
    'دیا ما',
    'ورفن ٚ ما',
    'اسفندار ما',
  ];

  /// The Deylami names of the weekdays, starting with Saturday.
  ///
  /// The list is indexed from Saturday at `0`, so `weekdayNames[0]` is `شمبه`
  /// and `weekdayNames[6]` is `جۊمه` (Friday). Note that this is not the same
  /// order as [weekday], which starts on Monday.
  static const List<String> weekdayNames = [
    'شمبه',
    'یکشمبه',
    'دۊشمبه',
    'سۊشمبه',
    'چارشمبه',
    'پئنشمبه',
    'جۊمه',
  ];

  /// How each Deylami month maps to Jalali months, indexed by Deylami month.
  ///
  /// Months 0 and 8 contain the Panjik and the Jalali year boundary, so they
  /// are handled separately and their entries are unused.
  static const List<_ToJalaliRule> _toJalaliRules = [
    _ToJalaliRule(0, 0, 0),
    _ToJalaliRule(15, 5, 16),
    _ToJalaliRule(16, 6, 15),
    _ToJalaliRule(16, 7, 14),
    _ToJalaliRule(16, 8, 14),
    _ToJalaliRule(16, 9, 14),
    _ToJalaliRule(16, 10, 14),
    _ToJalaliRule(16, 11, 14),
    _ToJalaliRule(0, 0, 0),
    _ToJalaliRule(11, 1, 20),
    _ToJalaliRule(12, 2, 19),
    _ToJalaliRule(13, 3, 18),
    _ToJalaliRule(14, 4, 17),
  ];

  /// How each Jalali month maps to Deylami months, indexed by Jalali month.
  ///
  /// Month 1 contains the Panjik, so it is handled separately and its entry is
  /// unused. The entry at index 0 does not belong to any month.
  static const List<_FromJalaliRule> _fromJalaliRules = [
    _FromJalaliRule(0, 0),
    _FromJalaliRule(0, 0),
    _FromJalaliRule(19, 10),
    _FromJalaliRule(18, 11),
    _FromJalaliRule(17, 12),
    _FromJalaliRule(16, 1),
    _FromJalaliRule(15, 2),
    _FromJalaliRule(14, 3),
    _FromJalaliRule(14, 4),
    _FromJalaliRule(14, 5),
    _FromJalaliRule(14, 6),
    _FromJalaliRule(14, 7),
    _FromJalaliRule(14, 8),
  ];

  /// Whether [year] is a Deylami leap year.
  ///
  /// A Deylami year is a leap year when the Jalali year `year - 195` is a leap
  /// year.
  static bool isLeap(int year) => JalaliDate.isLeap(year - 195);

  /// Returns the number of days in the given [month] of the given [year].
  ///
  /// The Panjik (month `0`) has 6 days in a leap year, counting the Vishak, and
  /// 5 days otherwise. Every other month has 30 days.
  static int daysInMonthOf(int year, int month) {
    if (month == 0) {
      return isLeap(year) ? 6 : 5;
    }
    return 30;
  }

  @override
  bool get isLeapYear => isLeap(year);

  @override
  int get daysInMonth => daysInMonthOf(year, month);

  @override
  String get monthName => monthNames[month];

  @override
  String get weekdayName => weekdayNames[(weekday + 1) % 7];

  @override
  DeylamiDate addDays(int days) =>
      DeylamiDate.fromJulianDayNumber(julianDayNumber + days);

  /// Returns the date as `YYYY-MM-DD`, for example `1600-03-04`.
  @override
  String toString() =>
      '${padNumber(year, 4)}-${padNumber(month, 2)}-${padNumber(day, 2)}';

  /// Validates the fields and returns the Julian day number of the date.
  static int _checkedJulianDayNumber(int year, int month, int day) {
    if (year < minYear || year > maxYear) {
      throw InvalidYearException(
        'Deylami year $year is not in range ($minYear, $maxYear).',
      );
    }
    if (month < 0 || month > 12) {
      throw InvalidMonthException(
        'Deylami month $month is not in range (0, 12).',
      );
    }
    if (day < 0 || day > 30) {
      throw InvalidDayException('Deylami day $day is not in range (0, 30).');
    }
    if (month == 0) {
      if (day > 5) {
        throw InvalidPanjikException(
          'Panjik day $day is not in range (0, 5).',
        );
      }
      if (day == 0 && !isLeap(year)) {
        throw InvalidVishakException(
          'Year $year is not a leap year, so it has no Vishak day.',
        );
      }
    } else if (day == 0) {
      throw InvalidDayException(
        'Day 0 is only valid for Vishak in month 0, not in month $month.',
      );
    }
    final (jalaliYear, jalaliMonth, jalaliDay) = _toJalaliFields(
      year,
      month,
      day,
    );
    final julianDayNumber = jalaliJulianDayNumber(
      jalaliYear,
      jalaliMonth,
      jalaliDay,
    );
    if (julianDayNumber < minJulianDayNumber ||
        julianDayNumber > maxJulianDayNumber) {
      throw InvalidDayException(
        'Deylami date $year-${padNumber(month, 2)}-${padNumber(day, 2)} '
        'is outside the supported range.',
      );
    }
    return julianDayNumber;
  }

  /// Converts a Deylami date to a Jalali `(year, month, day)` record.
  static (int, int, int) _toJalaliFields(int year, int month, int day) {
    if (month == 0) {
      return (year - 194, 1, day == 0 ? 15 : day + 15);
    }
    if (month == 8) {
      final extraDay = isLeap(year) ? 1 : 0;
      if (day <= 15 + extraDay) {
        return (year - 195, 12, day + 14);
      }
      return (year - 194, 1, day - 15 - extraDay);
    }
    final jalaliYear = month < 8 ? year - 195 : year - 194;
    final rule = _toJalaliRules[month];
    if (day <= rule.pivotDay) {
      return (jalaliYear, rule.jalaliMonth, day + rule.beforePivotOffset);
    }
    return (jalaliYear, rule.jalaliMonth + 1, day - rule.pivotDay);
  }

  /// Converts a Jalali date to a Deylami `(year, month, day)` record.
  static (int, int, int) _fromJalaliFields(
    int jalaliYear,
    int jalaliMonth,
    int jalaliDay,
  ) {
    final year = (jalaliMonth < 5 || (jalaliMonth == 5 && jalaliDay < 17))
        ? jalaliYear + 194
        : jalaliYear + 195;
    if (jalaliMonth == 1) {
      final leap = isLeap(year);
      if (leap && jalaliDay == 15) {
        return (year, 0, 0);
      }
      if (leap && jalaliDay < 15) {
        return (year, 8, jalaliDay + 16);
      }
      if (!leap && jalaliDay < 16) {
        return (year, 8, jalaliDay + 15);
      }
      if (jalaliDay < 21) {
        return (year, 0, jalaliDay - 15);
      }
      return (year, 9, jalaliDay - 20);
    }
    final rule = _fromJalaliRules[jalaliMonth];
    if (jalaliDay > rule.pivotDay) {
      return (year, rule.monthAfterPivot, jalaliDay - rule.pivotDay);
    }
    final monthBeforePivot = rule.monthAfterPivot == 1
        ? 12
        : rule.monthAfterPivot - 1;
    return (year, monthBeforePivot, jalaliDay + 30 - rule.pivotDay);
  }
}

/// The rule that maps one Deylami month to Jalali months.
class _ToJalaliRule {
  const _ToJalaliRule(
    this.pivotDay,
    this.jalaliMonth,
    this.beforePivotOffset,
  );

  final int pivotDay;

  final int jalaliMonth;

  final int beforePivotOffset;
}

/// The rule that maps one Jalali month to Deylami months.
class _FromJalaliRule {
  const _FromJalaliRule(this.pivotDay, this.monthAfterPivot);

  final int pivotDay;

  final int monthAfterPivot;
}
