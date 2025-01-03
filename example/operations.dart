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
