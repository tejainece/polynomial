import 'package:polynomial/polynomial.dart';

class NewtonMethod extends PolynomialSolver {
  const NewtonMethod();

  @override
  double solveOne(Polynomial p,
      {double tolerance = 1e-8, int trials = 10000, double? guess}) {
    Polynomial d = p.derivative();
    double root = guess ?? p[0];
    double error = 0;
    for (int trial = 0; trial < trials; trial++) {
      double v = p(root);
      double m = d(root);
      double c = v - m * root;
      root = -c / m;
      error = p.evaluate(root).abs();
      if (error < tolerance) break;
    }
    if (error > tolerance) {
      throw RootNotFound(1);
    }
    return root;
  }

  @override
  Roots solveAll(Polynomial polynomial,
      {double tolerance = 1e-8, int trials = 10000, List<double?>? guess}) {
    if (guess != null && guess.length != polynomial.degree) {
      throw ArgumentError(
          'The length of the initial guess must be equal to the degree of the polynomial.');
    }
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

  static const NewtonMethod instance = NewtonMethod();
}
