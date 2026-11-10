import 'dart:ui';

final _number = RegExp(r'-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?');
final _separators = RegExp(r'[\s,]*');
final _numberStart = RegExp(r'[-+.\d]');

/// Splits SVG number runs the way browsers do: `2.73.73-4` → 2.73, .73, -4.
List<double> tokenizeSvgNumbers(String input) => List.unmodifiable(
  _number.allMatches(input).map((m) => double.parse(m[0]!)),
);

const _arity = {'M': 2, 'L': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'A': 7, 'Z': 0};

/// Parses SVG path data (M L H V C S A Z, absolute and relative) into a [Path].
/// Other commands throw [FormatException]; the icons never need them.
Path parseSvgPath(String data) {
  final scanner = _Scanner(data);
  final builder = _PathBuilder();
  while (scanner.hasMore()) {
    final command = scanner.readCommand();
    final upper = command.toUpperCase();
    final arity = _arity[upper]!;
    final args = <double>[];
    if (arity > 0) {
      do {
        for (var i = 0; i < arity; i++) {
          // Arc flags are single characters and may be packed: "a5 5 0 0010 0".
          final isFlag = upper == 'A' && (i == 3 || i == 4);
          args.add(isFlag ? scanner.readFlag() : scanner.readNumber());
        }
      } while (scanner.nextIsNumber());
    }
    builder.run(command, List.unmodifiable(args));
  }
  return builder.path;
}

/// Reads SVG path data left to right, one command, number or flag at a time.
class _Scanner {
  _Scanner(this._data);

  final String _data;
  int _pos = 0;

  void _skip() => _pos += _separators.matchAsPrefix(_data, _pos)!.end - _pos;

  bool hasMore() {
    _skip();
    return _pos < _data.length;
  }

  bool nextIsNumber() => hasMore() && _numberStart.hasMatch(_data[_pos]);

  String readCommand() {
    final c = _data[_pos];
    if (!_arity.containsKey(c.toUpperCase()) ||
        c.toUpperCase() == c.toLowerCase()) {
      throw FormatException(
        'Expected a supported SVG path command',
        _data,
        _pos,
      );
    }
    _pos++;
    return c;
  }

  double readNumber() {
    _skip();
    final m = _number.matchAsPrefix(_data, _pos);
    if (m == null) throw FormatException('Expected a number', _data, _pos);
    _pos = m.end;
    return double.parse(m[0]!);
  }

  double readFlag() {
    _skip();
    if (_pos >= _data.length || (_data[_pos] != '0' && _data[_pos] != '1')) {
      throw FormatException('Arc flag must be 0 or 1', _data, _pos);
    }
    return _data[_pos++] == '1' ? 1 : 0;
  }
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
      throw FormatException(
        'Wrong number of arguments for $command',
        args.toString(),
      );
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
        _cubic(
          _point(a[0], a[1], rel),
          _point(a[2], a[3], rel),
          _point(a[4], a[5], rel),
        );
      case 'S':
        control = control == null ? _current : _current * 2 - control;
        _cubic(control, _point(a[0], a[1], rel), _point(a[2], a[3], rel));
      case 'A':
        final end = _point(a[5], a[6], rel);
        path.arcToPoint(
          end,
          radius: Radius.elliptical(a[0], a[1]),
          rotation: a[2],
          largeArc: a[3] != 0,
          clockwise: a[4] != 0,
        );
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
