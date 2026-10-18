import 'deylami_date.dart';
import 'gregorian_date.dart';
import 'jalali_date.dart';
import 'japanese_date.dart';

abstract class CalendarDate implements Comparable<CalendarDate> {
  const CalendarDate(this.year, this.month, this.day, this.julianDayNumber);

  final int year;

  final int month;

  final int day;

  final int julianDayNumber;

  bool get isLeapYear;

  int get daysInMonth;

  String get monthName;

  String get weekdayName;

  int get weekday => julianDayNumber % 7 + 1;

  CalendarDate addDays(int days);

  int daysUntil(CalendarDate other) => other.julianDayNumber - julianDayNumber;

  GregorianDate toGregorian() {
    final self = this;
    if (self is GregorianDate) {
      return self;
    }
    return GregorianDate.fromJulianDayNumber(julianDayNumber);
  }

  JalaliDate toJalali() {
    final self = this;
    if (self is JalaliDate) {
      return self;
    }
    return JalaliDate.fromJulianDayNumber(julianDayNumber);
  }

  JapaneseDate toJapanese() {
    final self = this;
    if (self is JapaneseDate) {
      return self;
    }
    return JapaneseDate.fromJulianDayNumber(julianDayNumber);
  }

  DeylamiDate toDeylami() {
    final self = this;
    if (self is DeylamiDate) {
      return self;
    }
    return DeylamiDate.fromJulianDayNumber(julianDayNumber);
  }

  DateTime toDateTime() {
    final gregorian = toGregorian();
    return DateTime.utc(gregorian.year, gregorian.month, gregorian.day);
  }

  @override
  int compareTo(CalendarDate other) =>
      julianDayNumber.compareTo(other.julianDayNumber);

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.runtimeType == runtimeType &&
      other.julianDayNumber == julianDayNumber;

  @override
  int get hashCode => Object.hash(runtimeType, julianDayNumber);
}
