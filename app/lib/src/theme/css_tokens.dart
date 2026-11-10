/// Splits [input] on commas that are not inside parentheses.
///
/// `a(1,2), b` → `['a(1,2)', 'b']`. Used for CSS lists such as layered
/// backgrounds and shadows.
List<String> splitTopLevelCommas(String input) {
  final parts = <String>[];
  final current = StringBuffer();
  var depth = 0;
  for (final char in input.split('')) {
    if (char == '(') depth++;
    if (char == ')') depth--;
    if (char == ',' && depth == 0) {
      parts.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  parts.add(current.toString().trim());
  return List.unmodifiable(parts);
}

/// Parses a CSS length written in px (`24px`) or a bare `0`.
double parsePx(String token) {
  if (token == '0') return 0;
  final match = RegExp(r'^(-?\d+(?:\.\d+)?)px$').firstMatch(token);
  if (match == null) throw FormatException('Expected a px length', token);
  return double.parse(match.group(1)!);
}
