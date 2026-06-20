import 'dart:math';

import 'package:polynomial/polynomial.dart';

/// Analytic (closed-form) real-root solver for polynomials of degree ≤ 4.
///
/// Uses the quadratic formula, Cardano's method (cubic) and Ferrari's method
/// (quartic). Unlike [LaguerreMethod] / [NewtonMethod] it is not iterative and
/// does not need a guess: it returns **exactly the real roots** (any count,
/// including none), cleanly discarding complex roots via the discriminant.
///
/// Degree ≥ 5 has no general radical solution (Abel–Ruffini); [realRoots]
/// throws an [ArgumentError] for higher degrees — use a numerical solver there.
class ClosedFormMethod extends PolynomialSolver {
  const ClosedFormMethod();

  static const ClosedFormMethod instance = ClosedFormMethod();

  /// All real roots of [p] (degree ≤ 4), refined with a few Newton steps.
  ///
  /// May return an empty list (no real roots) and may contain near-duplicate
  /// entries for repeated roots.
  List<double> realRoots(Polynomial p) {
    final n = p.degree;
    final List<double> raw;
    if (n <= 0) {
      return const [];
    } else if (n == 1) {
      raw = [-p[0] / p[1]];
    } else if (n == 2) {
      raw = quadraticRealRoots(p[2], p[1], p[0]);
    } else if (n == 3) {
      raw = cubicRealRoots(p[3], p[2], p[1], p[0]);
    } else if (n == 4) {
      raw = quarticRealRoots(p[4], p[3], p[2], p[1], p[0]);
    } else {
      throw ArgumentError(
          'ClosedFormMethod supports degree ≤ 4 (Abel–Ruffini), got degree $n');
    }
    final d = p.derivative();
    return [for (final r in raw) _polish(p, d, r)];
  }

  /// Refines a root with up to a few Newton iterations against [p].
  static double _polish(Polynomial p, Polynomial d, double t) {
    for (int i = 0; i < 8; i++) {
      final f = p(t);
      final fp = d(t);
      if (fp.abs() < 1e-14) break;
      final next = t - f / fp;
      if ((next - t).abs() < 1e-14) {
        t = next;
        break;
      }
      t = next;
    }
    return t;
  }

  @override
  double solveOne(Polynomial polynomial,
      {double tolerance = 1e-8, int trials = 0, double? guess}) {
    final roots = realRoots(polynomial);
    if (roots.isEmpty) throw RootNotFound(1);
    if (guess == null) return roots.first;
    return roots.reduce(
        (a, b) => (a - guess).abs() <= (b - guess).abs() ? a : b);
  }

  @override
  Roots solveAll(Polynomial polynomial,
      {double tolerance = 1e-8, int trials = 0, List<double?>? guess}) {
    final roots = realRoots(polynomial);
    if (roots.isEmpty) throw RootNotFound(1);
    return Roots(roots);
  }
}

const double _eps = 1e-12;

double _cbrt(double x) =>
    x < 0 ? -pow(-x, 1.0 / 3.0).toDouble() : pow(x, 1.0 / 3.0).toDouble();

/// Real roots of `a·x² + b·x + c = 0`.
List<double> quadraticRealRoots(double a, double b, double c) {
  if (a.abs() < _eps) {
    if (b.abs() < _eps) return const [];
    return [-c / b];
  }
  var disc = b * b - 4 * a * c;
  if (disc < 0) {
    // Absorb roundoff near a double root, otherwise the roots are complex.
    if (disc > -_eps * (1 + (b * b).abs())) {
      disc = 0;
    } else {
      return const [];
    }
  }
  if (disc == 0) return [-b / (2 * a)];
  final s = sqrt(disc);
  return [(-b - s) / (2 * a), (-b + s) / (2 * a)];
}

/// Real roots of `a·x³ + b·x² + c·x + d = 0` (Cardano / trigonometric form).
List<double> cubicRealRoots(double a, double b, double c, double d) {
  if (a.abs() < _eps) return quadraticRealRoots(b, c, d);
  // Normalise to monic x³ + b·x² + c·x + d.
  b /= a;
  c /= a;
  d /= a;
  // Depress: x = t - b/3  →  t³ + p·t + q.
  final p = c - b * b / 3;
  final q = 2 * b * b * b / 27 - b * c / 3 + d;
  final shift = -b / 3;
  final disc = q * q / 4 + p * p * p / 27;
  if (disc > _eps) {
    // One real root.
    final sq = sqrt(disc);
    return [_cbrt(-q / 2 + sq) + _cbrt(-q / 2 - sq) + shift];
  } else if (disc < -_eps) {
    // Three distinct real roots (p < 0 here).
    final r = sqrt(-p * p * p / 27);
    final phi = acos((-q / 2 / r).clamp(-1.0, 1.0)) / 3;
    final m = 2 * sqrt(-p / 3);
    return [
      m * cos(phi) + shift,
      m * cos(phi - 2 * pi / 3) + shift,
      m * cos(phi - 4 * pi / 3) + shift,
    ];
  } else {
    // disc ≈ 0: repeated roots.
    if (q.abs() < _eps) return [shift];
    final u = _cbrt(-q / 2);
    return [2 * u + shift, -u + shift];
  }
}

/// Real roots of `a·x⁴ + b·x³ + c·x² + d·x + e = 0`.
///
/// Ferrari's method via a resolvent cubic, after Schwarze's Graphics Gems
/// `SolveQuartic`. The resolvent root is chosen to keep the two derived
/// quadratics real wherever possible.
List<double> quarticRealRoots(
    double a, double b, double c, double d, double e) {
  if (a.abs() < _eps) return cubicRealRoots(b, c, d, e);
  // Monic x⁴ + b·x³ + c·x² + d·x + e.
  b /= a;
  c /= a;
  d /= a;
  e /= a;
  // Depress: x = y - b/4  →  y⁴ + p·y² + q·y + r.
  final b2 = b * b;
  final p = c - 3 * b2 / 8;
  final q = b * b2 / 8 - b * c / 2 + d;
  final r = -3 * b2 * b2 / 256 + b2 * c / 16 - b * d / 4 + e;
  final shift = -b / 4;
  final roots = <double>[];
  if (q.abs() < _eps) {
    // Biquadratic: y⁴ + p·y² + r = 0.
    for (final y2 in quadraticRealRoots(1, p, r)) {
      if (y2 < 0) {
        if (y2 > -_eps) roots.add(0);
        continue;
      }
      final y = sqrt(y2);
      roots..add(y)..add(-y);
    }
  } else if (r.abs() < _eps) {
    // y·(y³ + p·y + q) = 0.
    roots.add(0);
    roots.addAll(cubicRealRoots(1, 0, p, q));
  } else {
    // Resolvent cubic: z³ - (p/2)·z² - r·z + (p·r/2 - q²/8) = 0.
    final cubicRoots = cubicRealRoots(1, -p / 2, -r, p * r / 2 - q * q / 8);
    var z = cubicRoots.first;
    for (final cand in cubicRoots) {
      if (2 * cand - p >= -_eps && cand * cand - r >= -_eps) {
        z = cand;
        break;
      }
      if (cand > z) z = cand;
    }
    var u = z * z - r;
    var v = 2 * z - p;
    u = u <= 0 ? 0 : sqrt(u);
    v = v <= 0 ? 0 : sqrt(v);
    roots.addAll(quadraticRealRoots(1, q < 0 ? -v : v, z - u));
    roots.addAll(quadraticRealRoots(1, q < 0 ? v : -v, z + u));
  }
  return [for (final y in roots) y + shift];
}
