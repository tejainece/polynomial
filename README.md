# Polynomial

Simple API to perform polynomial operations like finding roots, addition, subtraction, multiplication, 
division, etc.

# Usage

## Constructor

```dart
import 'package:polynomial/polynomial.dart';

void main() {
    var poly = Polynomial([1, 2, 3]);
    print(poly.evaluate(5)); // => 86
    print(poly(5)); // => 86
}
```

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = x.pow(3) * 4 + x * x * 2 - 5;
  print(poly.evaluate(5)); // => 545
}
```

## Operations

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = Polynomial([1, 4]);
  print(poly); // => 4x + 1
  poly = poly * Polynomial([3, 2]);
  print(poly); // => 8x² + 14x + 3
  poly = poly / Polynomial([1, 4]);
  print(poly); // => 2x + 3
  poly = poly - Polynomial([1, 1]);
  print(poly); // => x + 2
}
```

## Derivative and Integral

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = Polynomial([1, 2, 3]);
  print(poly); // => 3x² + 2x + 1
  var d = poly.derivative();
  print(d); // => 6x + 2
  var i = d.integral();
  print(i); // => 3x² + 2x
}
```

## Solve/Roots

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = (x - 1) * (x - 2);
  print(poly); // => x² - 3x + 2
  var roots = poly.solveAll();
  print(roots); // => (x - 1) * (x - 2)
  poly = poly * Polynomial([-3, 1]);
  print(poly); // => x³ - 6x² + 11x - 6
  roots = poly.solveAll();
  print(roots); // => (x - 1) * (x - 2) * (x - 3)
}
```

# TODO

+ Discriminant