import 'calendar_date.dart';
import 'formatting.dart';
import 'gregorian_date.dart';
import 'jalali_date.dart';
import 'pcal_exception.dart';

class DeylamiDate extends CalendarDate {
  DeylamiDate(int year, int month, int day)
    : super(year, month, day, _checkedJulianDayNumber(year, month, day));

  factory DeylamiDate.fromDateTime(DateTime dateTime) =>
      DeylamiDate.fromJulianDayNumber(
        GregorianDate.fromDateTime(dateTime).julianDayNumber,
      );

  factory DeylamiDate.now() => DeylamiDate.fromDateTime(DateTime.now());

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

  static const int minYear = 195;

  static const int maxYear = 3372;

  static final int minJulianDayNumber = jalaliJulianDayNumber(1, 1, 1);

  static final int maxJulianDayNumber = jalaliJulianDayNumber(3178, 5, 16);

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

  static const List<String> weekdayNames = [
    'شمبه',
    'یکشمبه',
    'دۊشمبه',
    'سۊشمبه',
    'چارشمبه',
    'پئنشمبه',
    'جۊمه',
  ];

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

  static bool isLeap(int year) => JalaliDate.isLeap(year - 195);

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

  @override
  String toString() =>
      '${padNumber(year, 4)}-${padNumber(month, 2)}-${padNumber(day, 2)}';

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

class _FromJalaliRule {
  const _FromJalaliRule(this.pivotDay, this.monthAfterPivot);

  final int pivotDay;

  final int monthAfterPivot;
}
