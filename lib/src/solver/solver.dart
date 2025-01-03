import 'dart:typed_data';

import 'package:polynomial/polynomial.dart';

export 'laguerre_solver.dart';
export 'newton_solver.dart';

abstract class PolynomialSolver {
  const PolynomialSolver();

  factory PolynomialSolver.newton() => NewtonMethod.instance;

  double solveOne(Polynomial polynomial,
      {double tolerance = 1e-8, int trials, double? guess});

  Roots solveAll(Polynomial polynomial,
      {double tolerance = 1e-8, int trials, List<double?>? guess});
}

class Roots {
  final Float64List _roots;

  Roots(List<double> roots) : _roots = Float64List.fromList(roots) {
    assert(_roots.isNotEmpty);
  }

  List<double> get roots => _roots.toList();

  List<Polynomial> get polynomials =>
      _roots.map((e) => Polynomial.fromRoot(e)).toList();

  Polynomial get polynomial {
    Polynomial ret = Polynomial.fromRoot(_roots.first);
    for (final root in _roots.skip(1)) {
      ret = ret * Polynomial.fromRoot(root);
    }
    return ret;
  }

  @override
  String toString({String variable = 'x'}) {
    final parts = <String>[];
    for (final root in _roots) {
      double v = root.abs();
      parts.add(
          '($variable ${root.isNegative ? '+' : '-'} ${(v - v.round()).abs() > 1e-8 ? v : v.round()})');
    }
    return parts.join(' * ');
  }
}

class RootNotFound {
  final int nth;

  RootNotFound(this.nth);

  @override
  String toString() =>
      '$nth${nth == 1 ? 'st' : nth == 2 ? 'nd' : 'th'} root not found';
}
