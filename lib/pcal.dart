/// A dependency-free calendar converter between the Gregorian, Jalali
/// (Persian), Japanese (nengō eras) and Deylami (Gilaki / Dilami) calendars.
///
/// Every date class extends [CalendarDate] and stores a Julian day number.
/// Conversions go through that number, so converting between any two
/// calendars is exact and converting back returns the original date.
///
/// ```dart
/// import 'package:pcal/pcal.dart';
///
/// void main() {
///   final gregorian = GregorianDate(2026, 10, 10);
///
///   print(gregorian.toJalali()); // 1405-07-18
///   print(gregorian.toDeylami()); // 1600-03-04
///   print(gregorian.toJapanese().toKanjiString()); // 令和8年10月10日
/// }
/// ```
///
/// Invalid dates and conversions outside a calendar's supported range throw a
/// [PcalException].
library;

export 'src/calendar_date.dart' show CalendarDate;
export 'src/deylami_date.dart' show DeylamiDate;
export 'src/gregorian_date.dart' show GregorianDate;
export 'src/jalali_date.dart' show JalaliDate;
export 'src/japanese_date.dart' show JapaneseDate;
export 'src/japanese_era.dart' show JapaneseEra;
export 'src/pcal_exception.dart';
