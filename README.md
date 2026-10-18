# pcal

A dependency-free Dart calendar converter between **Gregorian**, **Jalali** (Persian), **Japanese** (nengō eras) and **Deylami** (Gilaki / Dilami) dates.

Every conversion goes through a single Julian day number, so converting between any two calendars is exact, and converting back always returns the original date.

## Usage

```dart
import 'package:pcal/pcal.dart';

void main() {
  final gregorian = GregorianDate(2026, 10, 10);

  final jalali = gregorian.toJalali();
  final deylami = gregorian.toDeylami();
  final japanese = gregorian.toJapanese();

  print(jalali);
  print(deylami);
  print(japanese);
  print(japanese.toKanjiString());
}
```

Output:

```
1405-07-18
1600-03-04
Reiwa 8-10-10
令和8年10月10日
```

Every date class has the same shape:

| Member | Description |
| --- | --- |
| `year`, `month`, `day` | Fields in that calendar |
| `toGregorian()`, `toJalali()`, `toJapanese()`, `toDeylami()` | Convert to another calendar |
| `toDateTime()` | UTC midnight `DateTime` of the same day |
| `weekday` | `1` (Monday) to `7` (Sunday), like `DateTime.weekday` |
| `weekdayName`, `monthName` | Names in the calendar's own language |
| `isLeapYear`, `daysInMonth` | Calendar rules for the date |
| `addDays(n)`, `daysUntil(other)` | Day arithmetic |
| `julianDayNumber` | The shared pivot used for conversion |

Each class also has `fromDateTime`, `now` and `fromJulianDayNumber` factories. Dates are comparable and have value equality within the same calendar.

### Japanese dates

```dart
final reiwa = JapaneseDate(JapaneseEra.reiwa, 1, 5, 1);
print(reiwa.toGregorian());
print(reiwa.toKanjiString());
print(reiwa.imperialYear);
print(reiwa.traditionalMonthName);
```

Eras are `meiji`, `taisho`, `showa`, `heisei` and `reiwa`. The year is the era year, and months and days are the Gregorian ones. Supported dates start at 1873-01-01 (Meiji 6), the day Japan adopted the Gregorian calendar. Earlier dates used the lunisolar calendar and throw an exception.

### Deylami dates

A Deylami year has twelve 30-day months and the five-day month `0` (Panjik, پنجيک) that sits between months 8 and 9. In a leap year the Panjik gets a sixth day, the Vishak, which is day `0`.

```dart
final vishak = DeylamiDate(1598, 0, 0);
print(vishak.toJalali());
print(vishak.toGregorian());
```

The Deylami year starts on 17 Mordad of the Jalali calendar. Month boundaries follow the [python-dilami-calendar](https://github.com/Jangal/python-dilami-calendar) package. A Deylami year is a leap year when the Jalali year `year - 195` is a leap year, so every day exists in both calendars and converts back and forth exactly.

The Python package instead uses a fixed table of Deylami leap years. That table disagrees with the Jalali calendar in many years (for example 1598), which makes two different days convert to the same Deylami date. pcal does not copy the table, so its results differ from the Python package on those few days around 15 Esfand to 20 Farvardin.

## Supported ranges

| Calendar | Years |
| --- | --- |
| Gregorian | 1 to 9999 |
| Jalali | 1 to 3178 |
| Deylami | 195 to 3372 |
| Japanese | Meiji 6 (1873-01-01) onward |

Jalali dates follow the 33-year arithmetic leap rule, which matches the official calendar for the modern era. Converting a date that does not exist in the target calendar's range throws an `InvalidDayException`.

## Exceptions

All exceptions extend `PcalException`: `InvalidYearException`, `InvalidMonthException`, `InvalidDayException`, `InvalidPanjikException`, `InvalidVishakException` and `InvalidEraException`.

## Development

pcal has no dependencies. The tests are a plain Dart script:

```
dart run test/pcal_test.dart
dart analyze
```
