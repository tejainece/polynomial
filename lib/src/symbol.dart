import 'package:polynomial/polynomial.dart';

class Symbol {
  final String name;

  Symbol._(this.name);

  @override
  String toString() => name;

  Polynomial operator *(other) {
    if (other is Symbol) {
      return Polynomial([0, 0, 1]);
    } else if (other is num) {
      return Polynomial([0, other.toDouble()]);
    } else if (other is Polynomial) {
      return other.raiseToDegree(other.degree + 1);
    }
    throw ArgumentError('Invalid argument: $other');
  }

  Polynomial operator +(other) {
    if (other is Symbol) {
      return Polynomial([0, 2]);
    } else if (other is num) {
      return Polynomial([other.toDouble(), 1]);
    } else if (other is Polynomial) {
      return other + Polynomial([0, 1]);
    }
    throw ArgumentError('Invalid argument: $other');
  }

  Polynomial operator -(other) => this + (-other);

  Polynomial operator -() => Polynomial([0, -1]);

  Polynomial pow(int power) => Polynomial(List.filled(power, 0.0) + [1.0]);
}

final x = Symbol._('x');
