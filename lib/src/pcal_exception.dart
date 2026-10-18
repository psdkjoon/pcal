/// The base class of every exception thrown by pcal.
///
/// Catch this type to handle any pcal error, or one of its subclasses to
/// handle a specific one.
class PcalException implements Exception {
  /// Creates an exception that describes the problem in [message].
  const PcalException(this.message);

  /// A human-readable description of what went wrong.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a year is outside the supported range of its calendar.
class InvalidYearException extends PcalException {
  /// Creates an exception that describes the invalid year in [message].
  const InvalidYearException(super.message);
}

/// Thrown when a month is outside the valid range of its calendar.
class InvalidMonthException extends PcalException {
  /// Creates an exception that describes the invalid month in [message].
  const InvalidMonthException(super.message);
}

/// Thrown when a day does not exist in its month, or when a Julian day number
/// is outside the supported range of a calendar.
class InvalidDayException extends PcalException {
  /// Creates an exception that describes the invalid day in [message].
  const InvalidDayException(super.message);
}

/// Thrown when a Deylami Panjik day (month `0`) is outside the range `0` to
/// `5`.
class InvalidPanjikException extends PcalException {
  /// Creates an exception that describes the invalid Panjik day in [message].
  const InvalidPanjikException(super.message);
}

/// Thrown when a Deylami Vishak (day `0` of month `0`) is requested in a year
/// that is not a leap year.
class InvalidVishakException extends PcalException {
  /// Creates an exception that describes the invalid Vishak in [message].
  const InvalidVishakException(super.message);
}

/// Thrown when a Japanese date does not belong to its era, or is before the
/// first supported date (see `JapaneseDate`).
class InvalidEraException extends PcalException {
  /// Creates an exception that describes the invalid era in [message].
  const InvalidEraException(super.message);
}
