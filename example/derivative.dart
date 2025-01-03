import 'package:polynomial/polynomial.dart';

void main() {
  var poly = Polynomial([1, 2, 3]);
  print(poly); // => 3x² + 2x + 1
  var d = poly.derivative();
  print(d); // => 6x + 2
  var i = d.integral();
  print(i); // => 3x² + 2x
}
