import 'dart:math';
import 'dart:typed_data';

import 'package:polynomial/polynomial.dart';

class Polynomial {
  final Float64List _coefficients;

  Polynomial(List<double> coefficients)
      : _coefficients = Float64List.fromList(cleanCoefficients(coefficients));

  Polynomial.fromRoot(double root)
      : _coefficients = Float64List.fromList([-root, 1]);

  factory Polynomial.fromRoots(List<double> roots) => Roots(roots).polynomial;

  int get degree => _coefficients.length - 1;

  double operator [](int index) {
    if (index < 0 || index >= _coefficients.length) {
      return 0;
    }
    return _coefficients[index];
  }

  double evaluate(double x) {
    double result = 0;
    double mul = 1;
    for (int i = 0; i < _coefficients.length; i++) {
      result += _coefficients[i] * mul;
      mul *= x;
    }
    return result;
  }

  double call(double x) => evaluate(x);

  Polynomial operator -() {
    final ret = <double>[];
    for (int i = 0; i < _coefficients.length; i++) {
      ret.add(-_coefficients[i]);
    }
    return Polynomial(ret);
  }

  Polynomial operator +(other) {
    if (other is Polynomial) {
      final maxCount = max(_coefficients.length, other._coefficients.length);
      final ret = <double>[];
      for (int i = 0; i < maxCount; i++) {
        double v = 0;
        if (i < _coefficients.length) {
          v += _coefficients[i];
        }
        if (i < other._coefficients.length) {
          v += other._coefficients[i];
        }
        ret.add(v);
      }
      return Polynomial(ret);
    } else if (other is num) {
      final ret = _coefficients.toList();
      ret[0] += other;
      return Polynomial(ret);
    }
    throw ArgumentError('Invalid type: ${other.runtimeType}');
  }

  Polynomial operator -(other) {
    if (other is Polynomial) {
      final maxCount = max(_coefficients.length, other._coefficients.length);
      final ret = <double>[];
      for (int i = 0; i < maxCount; i++) {
        double v = 0;
        if (i < _coefficients.length) {
          v += _coefficients[i];
        }
        if (i < other._coefficients.length) {
          v -= other._coefficients[i];
        }
        ret.add(v);
      }
      return Polynomial(ret);
    } else if (other is num) {
      final ret = _coefficients.toList();
      ret[0] -= other;
      return Polynomial(ret);
    }
    throw ArgumentError('Invalid type: ${other.runtimeType}');
  }

  Polynomial operator *(other) {
    if (other is Polynomial) {
      final resDegree = _coefficients.length + other._coefficients.length - 1;
      final ret = List<double>.filled(resDegree, 0);
      for (int i = 0; i < _coefficients.length; i++) {
        for (int j = 0; j < other._coefficients.length; j++) {
          ret[i + j] += _coefficients[i] * other._coefficients[j];
        }
      }
      return Polynomial(ret);
    } else if (other is num) {
      final ret = _coefficients.toList();
      for (int i = 0; i < ret.length; i++) {
        ret[i] *= other;
      }
      return Polynomial(ret);
    }
    throw ArgumentError('Invalid type: ${other.runtimeType}');
  }

  Polynomial operator /(divisor) {
    if (divisor is Polynomial) {
      final (q, _) = divide(divisor);
      return q;
    } else if (divisor is num) {
      final ret = _coefficients.toList();
      for (int i = 0; i < ret.length; i++) {
        ret[i] /= divisor;
      }
      return Polynomial(ret);
    }
    throw ArgumentError('Invalid type: ${divisor.runtimeType}');
  }

  (Polynomial q, Polynomial r) divide(Polynomial divisor) {
    if (divisor.degree > degree) {
      throw ArgumentError(
          'The divisor must have a degree less than or equal to the dividend.');
    } else if (divisor.isZero) {
      throw ArgumentError('The divisor must not be zero.');
    }
    final ret = <double>[];
    Polynomial remainder = this;
    for (int i = degree; i >= divisor.degree; i--) {
      final coefficient = remainder[i] / divisor[divisor.degree];
      ret.add(coefficient);
      remainder =
          remainder - (divisor * Polynomial([coefficient])).raiseToDegree(i);
    }
    return (Polynomial(ret.reversed.toList()), remainder);
  }

  Polynomial raiseToDegree(int degree) =>
      Polynomial(List.filled(degree - this.degree, 0.0) + _coefficients);

  Polynomial derivative() {
    final ret = <double>[];
    for (int i = 1; i < _coefficients.length; i++) {
      ret.add(_coefficients[i] * i);
    }
    return Polynomial(ret);
  }

  Polynomial integral() {
    final ret = <double>[0];
    for (int i = 0; i < _coefficients.length; i++) {
      ret.add(_coefficients[i] / (i + 1));
    }
    return Polynomial(ret);
  }

  double solveOne(
          {double tolerance = 1e-8,
          int trials = 10000,
          double? guess,
          PolynomialSolver solver = LaguerreMethod.instance}) =>
      solver.solveOne(this, tolerance: tolerance, trials: trials, guess: guess);

  Roots solveAll(
          {double tolerance = 1e-8,
          int trials = 10000,
          List<double?>? guess,
          PolynomialSolver solver = LaguerreMethod.instance}) =>
      solver.solveAll(this, tolerance: tolerance, trials: trials, guess: guess);

  bool get isZero => _coefficients.length == 1 && _coefficients.first == 0;

  @override
  String toString({String variable = 'x'}) {
    final sb = StringBuffer();
    bool first = true;
    for (int i = _coefficients.length - 1; i >= 0; i--) {
      double coefficient = _coefficients[i];
      if (coefficient.abs() < 1e-8) continue;
      if (!first) {
        sb.write(coefficient.isNegative ? ' - ' : ' + ');
      } else {
        if (coefficient.isNegative) {
          sb.write('-');
        }
        first = false;
      }
      coefficient = coefficient.abs();

      if (i > 0) {
        if ((coefficient - 1).abs() > 1e-6) {
          if ((coefficient - coefficient.round()).abs() > 1e-8) {
            sb.write(coefficient);
          } else {
            sb.write(coefficient.round());
          }
        }
        sb.write(variable);
        if (i > 1) {
          sb.write(_intToSuperscript(i));
        }
      } else {
        if ((coefficient - coefficient.round()).abs() > 1e-8) {
          sb.write(coefficient);
        } else {
          sb.write(coefficient.round());
        }
      }
    }
    return sb.toString();
  }

  static List<double> cleanCoefficients(List<double> coefficients) {
    final ret = <double>[];
    bool first = true;
    for (int i = coefficients.length - 1; i >= 0; i--) {
      double coefficient = coefficients[i];
      if (first) {
        if (coefficient.abs() < 1e-8) continue;
        first = false;
      }
      ret.add(coefficient);
    }
    if (ret.isEmpty) return [0];
    return ret.reversed.toList();
  }
}

const _superscript = {
  0: '⁰',
  1: '¹',
  2: '²',
  3: '³',
  4: '⁴',
  5: '⁵',
  6: '⁶',
  7: '⁷',
  8: '⁸',
  9: '⁹',
};

String _intToSuperscript(int i) {
  final sb = StringBuffer();
  while (i > 0) {
    sb.write(_superscript[i % 10]);
    i = i ~/ 10;
  }
  return sb.toString();
}
