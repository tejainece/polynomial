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
