import 'dart:ui';

import 'svg_path.dart';

/// Thin-outline icons (24×24 viewBox, stroke 1.8), copied from the approved
/// reference SVGs in `Code/`. Circles and ellipses are listed separately.
enum ErmiasIconData {
  database(
    ['M3 5v14a9 3 0 0 0 18 0V5', 'M3 12a9 3 0 0 0 18 0'],
    ovals: [Rect.fromLTRB(3, 2, 21, 8)],
  ),
  auditLog([
    'M8 6h13',
    'M8 12h13',
    'M8 18h13',
    'M3 6h.01',
    'M3 12h.01',
    'M3 18h.01',
  ]),
  taskChain([
    'm3 17 2 2 4-4',
    'm3 7 2 2 4-4',
    'M13 6h8',
    'M13 12h8',
    'M13 18h8',
  ]),
  projectGrade(
    ['M15.48 12.89 17 22l-5-3-5 3 1.52-9.11'],
    ovals: [Rect.fromLTRB(6, 2, 18, 14)],
  ),
  close(['M18 6 6 18', 'm6 6 12 12']),
  shieldCheck(['M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z', 'm9 12 2 2 4-4']),
  users(
    [
      'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2',
      'M22 21v-2a4 4 0 0 0-3-3.87',
      'M16 3.13a4 4 0 0 1 0 7.75',
    ],
    ovals: [Rect.fromLTRB(5, 3, 13, 11)],
  ),
  settings(
    [
      'M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z',
    ],
    ovals: [Rect.fromLTRB(9, 9, 15, 15)],
  ),
  chevronDown(['m6 9 6 6 6-6']),
  chevronLeft(['m15 18-6-6 6-6']),
  chevronUp(['m18 15-6-6-6 6']),
  minus(['M5 12h14']),
  plus(['M5 12h14', 'M12 5v14']);

  const ErmiasIconData(this.paths, {this.ovals = const []});

  final List<String> paths;
  final List<Rect> ovals;

  Path toPath() {
    final result = Path();
    for (final d in paths) {
      result.addPath(parseSvgPath(d), Offset.zero);
    }
    for (final oval in ovals) {
      result.addOval(oval);
    }
    return result;
  }
}
