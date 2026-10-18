/// Returns [value] as a string, padded on the left with zeros to [width]
/// characters.
///
/// A [value] that is already wider than [width] is returned unchanged.
String padNumber(int value, int width) => value.toString().padLeft(width, '0');
