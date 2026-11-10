import 'dart:ui';

final _token = RegExp(r'[A-Za-z]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
final _number = RegExp(r'-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');

/// Splits SVG number runs the way browsers do: `2.73.73-4` → 2.73, .73, -4.
List<double> tokenizeSvgNumbers(String input) =>
    List.unmodifiable(_number.allMatches(input).map((m) => double.parse(m[0]!)));

const _arity = {'M': 2, 'L': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'A': 7, 'Z': 0};

/// Parses SVG path data (M L H V C S A Z, absolute and relative) into a [Path].
/// Other commands throw [FormatException]; the icons never need them.
Path parseSvgPath(String data) {
  final builder = _PathBuilder();
  String? command;
  final args = <double>[];
  void flush() {
    if (command != null) builder.run(command, List.unmodifiable(args));
    args.clear();
  }

  for (final match in _token.allMatches(data)) {
    final token = match[0]!;
    if (RegExp(r'^[A-Za-z]$').hasMatch(token)) {
      if (!_arity.containsKey(token.toUpperCase())) {
        throw FormatException('Unsupported SVG path command', token);
      }
      flush();
      command = token;
      if (token.toUpperCase() == 'Z') flush();
    } else {
      if (command == null) throw FormatException('Path data must start with a command', data);
      args.add(double.parse(token));
    }
  }
  flush();
  return builder.path;
}

class _PathBuilder {
  final path = Path();
  Offset _current = Offset.zero;
  Offset _start = Offset.zero;
  Offset? _lastControl;

  void run(String command, List<double> args) {
    final upper = command.toUpperCase();
    final arity = _arity[upper]!;
    if (arity == 0) {
      path.close();
      _current = _start;
      _lastControl = null;
      return;
    }
    if (args.isEmpty || args.length % arity != 0) {
      throw FormatException('Wrong number of arguments for $command', args.toString());
    }
    final relative = command != upper;
    for (var i = 0; i < args.length; i += arity) {
      // After the first pair, extra M/m pairs are implicit L/l.
      final step = upper == 'M' && i > 0 ? 'L' : upper;
      _segment(step, args.sublist(i, i + arity), relative);
    }
  }

  Offset _point(double x, double y, bool relative) =>
      relative ? _current + Offset(x, y) : Offset(x, y);

  void _segment(String c, List<double> a, bool rel) {
    var control = _lastControl;
    _lastControl = null;
    switch (c) {
      case 'M':
        _current = _start = _point(a[0], a[1], rel);
        path.moveTo(_current.dx, _current.dy);
      case 'L':
        _lineTo(_point(a[0], a[1], rel));
      case 'H':
        _lineTo(Offset(rel ? _current.dx + a[0] : a[0], _current.dy));
      case 'V':
        _lineTo(Offset(_current.dx, rel ? _current.dy + a[0] : a[0]));
      case 'C':
        _cubic(_point(a[0], a[1], rel), _point(a[2], a[3], rel), _point(a[4], a[5], rel));
      case 'S':
        control = control == null ? _current : _current * 2 - control;
        _cubic(control, _point(a[0], a[1], rel), _point(a[2], a[3], rel));
      case 'A':
        final end = _point(a[5], a[6], rel);
        path.arcToPoint(end,
            radius: Radius.elliptical(a[0], a[1]),
            rotation: a[2],
            largeArc: a[3] != 0,
            clockwise: a[4] != 0);
        _current = end;
    }
  }

  void _lineTo(Offset p) {
    path.lineTo(p.dx, p.dy);
    _current = p;
  }

  void _cubic(Offset c1, Offset c2, Offset end) {
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    _lastControl = c2;
    _current = end;
  }
}
