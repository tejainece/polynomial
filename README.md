# Polynomial

A robust, lightweight Dart package to perform polynomial operations including algebraic arithmetic, root finding (numerical and closed-form/analytic), polynomial division, calculus (derivatives and integrals), and advanced operations like greatest common divisor (GCD) and functional composition.

## Features

- **Algebraic Expressions**: Construct polynomials naturally using standard math operators and the symbol `x`.
- **Basic Arithmetic**: Addition, subtraction, multiplication, and division of polynomials or scalar numbers.
- **Polynomial Division**: Perform division to get both quotient and remainder.
- **Calculus**: Compute exact derivatives and integrals.
- **Root Solvers**:
  - **Laguerre's Method**: Rapid numerical solver for finding all real/complex roots (default).
  - **Newton-Raphson Method**: Iterative root-finding using derivatives.
  - **Closed-Form Analytic Solver**: Exact algebraic solutions for degrees $\le 4$ using quadratic, cubic (Cardano's), and quartic (Ferrari's) formulas.
- **Advanced Operations**:
  - **Monic Normalization**: Scale the polynomial so the leading coefficient is `1.0`.
  - **Functional Composition**: Evaluate $p(q(t))$ (substituting one polynomial into another).
  - **Greatest Common Divisor (GCD)**: Find the monic GCD of two polynomials using the Euclidean algorithm.

---

## Usage

### Construction

You can define a polynomial in three ways:

#### 1. Coefficients Array (ascending power order)
Pass a list of coefficients where index `i` corresponds to the coefficient of the $x^i$ term.

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  // Represents 3x² + 2x + 1
  var poly = Polynomial([1, 2, 3]);
  print(poly); // => 3x² + 2x + 1
}
```

#### 2. From Roots
Construct a polynomial that has specific roots:

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  // Construct (x - 2)
  var single = Polynomial.fromRoot(2.0); 
  print(single); // => x - 2

  // Construct (x - 1) * (x - 2) * (x - 3)
  var poly = Polynomial.fromRoots([1.0, 2.0, 3.0]);
  print(poly); // => x³ - 6x² + 11x - 6
}
```

#### 3. Algebraic Expressions (using `x`)
Use the exported symbol `x` to construct polynomials using standard operators:

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  // Represents 4x³ + 2x² - 5
  var poly = x.pow(3) * 4 + x * x * 2 - 5;
  print(poly); // => 4x³ + 2x² - 5
}
```

---

### Evaluation

Polynomials can be evaluated at a specific point either by calling `evaluate()` or using the shorthand call operator:

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = Polynomial([1, 2, 3]); // 3x² + 2x + 1
  
  print(poly.evaluate(5)); // => 86.0
  print(poly(5));          // => 86.0 (shorthand call)
}
```

---

### Arithmetic Operations

Standard arithmetic operators `+`, `-`, `*`, and `/` are overloaded for both `Polynomial` and scalar `num` arguments.

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly1 = Polynomial([1, 4]); // 4x + 1
  var poly2 = Polynomial([3, 2]); // 2x + 3

  print(poly1 + poly2); // => 6x + 4
  print(poly1 - poly2); // => 2x - 2
  print(poly1 * poly2); // => 8x² + 14x + 3
  
  // Unary negation
  print(-poly1); // => -4x - 1
  
  // Scalar operations
  print(poly1 * 3); // => 12x + 3
}
```

#### Polynomial Division with Remainder

Using `/` performs division and returns only the quotient. To retrieve both the quotient and the remainder, use the `divide()` method:

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var dividend = Polynomial([-3, -2, 1]); // x² - 2x - 3
  var divisor = Polynomial([-3, 1]);     // x - 3

  var (q, r) = dividend.divide(divisor);
  print('Quotient: $q');   // => x + 1
  print('Remainder: $r');  // => 0
}
```

---

### Calculus

Compute exact derivatives and integrals:

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = Polynomial([1, 2, 3]); // 3x² + 2x + 1

  var d = poly.derivative();
  print(d); // => 6x + 2

  var i = d.integral();
  print(i); // => 3x² + 2x (constant term C is 0)
}
```

---

### Advanced Operations

#### Monic Normalization
Obtain the monic form (where the leading coefficient is `1.0`):

```dart
var poly = Polynomial([2, 4, 2]); // 2x² + 4x + 2
var monic = poly.monic();
print(monic); // => x² + 2x + 1
```

#### Functional Composition
Substitute a polynomial into another, computing $p(q(t))$:

```dart
var p = Polynomial([0, 0, 1]); // x²
var q = Polynomial([1, 2]);    // 2x + 1

var pq = p.compose(q);
print(pq); // => 4x² + 4x + 1  (i.e., (2x + 1)²)
```

#### Greatest Common Divisor (GCD)
Find the monic GCD of two polynomials:

```dart
var a = Polynomial([2, -3, 1]); // (x - 1)(x - 2)
var b = Polynomial([3, -4, 1]); // (x - 1)(x - 3)

var gcd = Polynomial.gcd(a, b);
print(gcd); // => x - 1
```

#### Near-Zero Check
Check if all coefficients are nearly zero within a given tolerance:

```dart
var tiny = Polynomial([1e-10, 1e-11]);
print(tiny.isNearlyZero(1e-9)); // => true
```

---

### Root Finding (Solving)

This package supports solving for the real roots of a polynomial.

```dart
import 'package:polynomial/polynomial.dart';

void main() {
  var poly = (x - 1) * (x - 2) * (x - 3); // x³ - 6x² + 11x - 6

  // Find all roots (default solver: Laguerre's Method)
  var roots = poly.solveAll();
  print(roots); // => (x - 1) * (x - 2) * (x - 3)
  
  // Find a single root
  var root = poly.solveOne();
  print(root); // => 1.0 (or another root, depending on solver/guess)
}
```

#### Solvers

You can customize root-finding by choosing a specific solver:

1. **`LaguerreMethod` (Default)**: A reliable iterative solver for general polynomials.
2. **`NewtonMethod`**: Standard Newton-Raphson iterative solver.
3. **`ClosedFormMethod`**: Uses exact algebraic equations for degree $\le 4$ (quadratic, cubic, quartic). Discards complex roots via the discriminant and refines results with a few Newton steps.

```dart
// Using ClosedFormMethod for exact analytic solutions (degree <= 4)
var roots = poly.solveAll(solver: ClosedFormMethod.instance);

// Specifying an initial guess for Newton's method
var singleRoot = poly.solveOne(
  solver: NewtonMethod.instance,
  guess: 2.5,
);
```