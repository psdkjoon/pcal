import 'deylami_date.dart';
import 'gregorian_date.dart';
import 'jalali_date.dart';
import 'japanese_date.dart';

/// A single day in one of the supported calendars.
///
/// Every [CalendarDate] stores its [julianDayNumber], which is the pivot that
/// all conversions go through. Converting a date to another calendar and back
/// therefore always returns the original day.
///
/// The concrete calendars are [GregorianDate], [JalaliDate], [JapaneseDate]
/// and [DeylamiDate]. Dates are immutable, can be sorted with [compareTo] and
/// are equal when they are of the same calendar and fall on the same day.
///
/// ```dart
/// final date = GregorianDate(2026, 10, 10);
/// print(date.toJalali()); // 1405-07-18
/// print(date.addDays(30)); // 2026-11-09
/// ```
abstract class CalendarDate implements Comparable<CalendarDate> {
  /// Creates a date from its calendar [year], [month] and [day], together with
  /// the [julianDayNumber] of that day.
  ///
  /// This constructor does not validate its arguments. The concrete calendar
  /// classes validate their fields before calling it.
  const CalendarDate(this.year, this.month, this.day, this.julianDayNumber);

  /// The year in this date's own calendar.
  ///
  /// For a [JapaneseDate] this is the year of the era, starting at `1`.
  final int year;

  /// The month in this date's own calendar.
  ///
  /// Gregorian, Jalali and Japanese months run from `1` to `12`. Deylami
  /// months run from `0` (the Panjik) to `12`.
  final int month;

  /// The day of the [month] in this date's own calendar.
  ///
  /// Days start at `1`, except for the Deylami Vishak, which is day `0` of
  /// month `0`.
  final int day;

  /// The Julian day number of this date.
  ///
  /// This is the number of days since the start of the Julian period, and it
  /// is the shared value used to convert between calendars. Two dates from
  /// different calendars are the same day exactly when their Julian day
  /// numbers are equal.
  final int julianDayNumber;

  /// Whether [year] is a leap year in this date's calendar.
  bool get isLeapYear;

  /// The number of days in this date's [month].
  int get daysInMonth;

  /// The name of this date's [month], in the language of its calendar.
  ///
  /// For example `January` for [GregorianDate], `فروردین` for [JalaliDate] and
  /// `1月` for [JapaneseDate].
  String get monthName;

  /// The name of this date's weekday, in the language of its calendar.
  ///
  /// For example `Monday` for [GregorianDate] and `شنبه` (Saturday) for
  /// [JalaliDate].
  String get weekdayName;

  /// The day of the week, from `1` (Monday) to `7` (Sunday).
  ///
  /// This numbering is the same as [DateTime.weekday], and it does not depend
  /// on the calendar. Use [weekdayName] to get the name in the calendar's own
  /// language.
  int get weekday => julianDayNumber % 7 + 1;

  /// Returns the date [days] days after this one, in the same calendar.
  ///
  /// A negative [days] moves backwards in time.
  ///
  /// Throws an `InvalidDayException` if the result is outside the supported
  /// range of the calendar.
  CalendarDate addDays(int days);

  /// Returns how many days must be added to this date to reach [other].
  ///
  /// The result is negative when [other] is earlier than this date. The two
  /// dates may be in different calendars.
  int daysUntil(CalendarDate other) => other.julianDayNumber - julianDayNumber;

  /// Converts this date to the Gregorian calendar.
  ///
  /// Returns this object itself if it is already a [GregorianDate]. Every day
  /// supported by the other calendars exists in the Gregorian calendar, so
  /// this conversion never fails.
  GregorianDate toGregorian() {
    final self = this;
    if (self is GregorianDate) {
      return self;
    }
    return GregorianDate.fromJulianDayNumber(julianDayNumber);
  }

  /// Converts this date to the Jalali (Persian) calendar.
  ///
  /// Returns this object itself if it is already a [JalaliDate].
  ///
  /// Throws an `InvalidDayException` if the day is outside the supported
  /// Jalali range.
  JalaliDate toJalali() {
    final self = this;
    if (self is JalaliDate) {
      return self;
    }
    return JalaliDate.fromJulianDayNumber(julianDayNumber);
  }

  /// Converts this date to the Japanese (nengō) calendar.
  ///
  /// Returns this object itself if it is already a [JapaneseDate].
  ///
  /// Throws an `InvalidDayException` if the day is before 1873-01-01, the
  /// first day supported by [JapaneseDate].
  JapaneseDate toJapanese() {
    final self = this;
    if (self is JapaneseDate) {
      return self;
    }
    return JapaneseDate.fromJulianDayNumber(julianDayNumber);
  }

  /// Converts this date to the Deylami calendar.
  ///
  /// Returns this object itself if it is already a [DeylamiDate].
  ///
  /// Throws an `InvalidDayException` if the day is outside the supported
  /// Deylami range.
  DeylamiDate toDeylami() {
    final self = this;
    if (self is DeylamiDate) {
      return self;
    }
    return DeylamiDate.fromJulianDayNumber(julianDayNumber);
  }

  /// Converts this date to a [DateTime] at midnight UTC of the same day.
  DateTime toDateTime() {
    final gregorian = toGregorian();
    return DateTime.utc(gregorian.year, gregorian.month, gregorian.day);
  }

  /// Compares this date to [other] by their position on the timeline.
  ///
  /// Returns a negative value if this date is earlier, zero if both are the
  /// same day and a positive value if this date is later. Dates from
  /// different calendars can be compared with each other.
  @override
  int compareTo(CalendarDate other) =>
      julianDayNumber.compareTo(other.julianDayNumber);

  /// Whether [other] is a date of the same calendar on the same day.
  ///
  /// A [GregorianDate] and a [JalaliDate] on the same day are not equal, even
  /// though [compareTo] returns zero for them. Convert one of them first to
  /// compare them with `==`.
  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      other.runtimeType == runtimeType &&
      other.julianDayNumber == julianDayNumber;

  @override
  int get hashCode => Object.hash(runtimeType, julianDayNumber);
}
