import 'package:polynomial/polynomial.dart';

void main() {
  var poly = x.pow(3) * 4 + x * x * 2 - 5;
  print(poly.evaluate(5)); // => 545
}
