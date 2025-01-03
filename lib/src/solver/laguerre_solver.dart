import 'dart:math';

import 'package:polynomial/polynomial.dart';

class LaguerreMethod extends PolynomialSolver {
  const LaguerreMethod();

  @override
  double solveOne(Polynomial p,
      {double tolerance = 1e-8, int trials = 10000, double? guess}) {
    double root = guess ?? 0;
    double err = double.infinity;
    int deg = p.degree;
    Polynomial d = p.derivative();
    Polynomial dd = d.derivative();
    for (int trial = 0; trial < trials; trial++) {
      err = p(root).abs();
      if (err < tolerance) break;

      double g = d(root) / p(root);
      double h = g * g - (dd(root) / p(root));
      double den1 = g + sqrt((deg - 1) * (deg * h - g * g));
      double den2 = g - sqrt((deg - 1) * (deg * h - g * g));
      double den = den2;
      if (den1.abs() > den2.abs()) {
        den = den1;
      }
      double a = deg / den;
      root -= a;
    }
    if (err > tolerance) {
      throw RootNotFound(1);
    }
    return root;
  }

  @override
  Roots solveAll(Polynomial polynomial,
      {double tolerance = 1e-8, int trials = 10000, List<double?>? guess}) {
    final roots = <double>[];
    Polynomial p = polynomial;
    while (p.degree > 0) {
      try {
        final root = solveOne(p,
            tolerance: tolerance, trials: trials, guess: guess?[p.degree - 1]);
        roots.add(root);
        p /= Polynomial.fromRoot(root);
      } on RootNotFound catch (_) {
        throw RootNotFound(roots.length + 1);
      }
    }
    return Roots(roots);
  }

  static const instance = LaguerreMethod();
}
