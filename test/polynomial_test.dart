import 'package:polynomial/polynomial.dart';
import 'package:test/test.dart';

void main() {
  group('Polynomial.compose', () {
    test('compose with identity (t) returns same polynomial', () {
      final p = Polynomial([1, 2, 3]); // 1 + 2t + 3t²
      final id = Polynomial([0, 1]); // t
      final result = p.compose(id);
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        expect(result(t), closeTo(p(t), 1e-9));
      }
    });

    test('compose constant polynomial returns that constant', () {
      final p = Polynomial([5]); // 5
      final inner = Polynomial([1, 2, 3]); // 1 + 2t + 3t²
      final result = p.compose(inner);
      for (final t in [0.0, 0.5, 1.0, -1.0]) {
        expect(result(t), closeTo(5.0, 1e-9));
      }
    });

    test('compose with constant polynomial evaluates at that constant', () {
      final p = Polynomial([1, 2, 3]); // 1 + 2t + 3t²
      final c = Polynomial([0.5]); // constant 0.5
      final result = p.compose(c);
      // p(0.5) = 1 + 2·0.5 + 3·0.25 = 1 + 1 + 0.75 = 2.75
      expect(result(0.0), closeTo(2.75, 1e-9));
    });

    test('compose linear into quadratic yields correct quadratic', () {
      // p(t) = t², inner(t) = 2t + 1 → p(inner(t)) = (2t+1)² = 4t² + 4t + 1
      final p = Polynomial([0, 0, 1]); // t²
      final inner = Polynomial([1, 2]); // 1 + 2t
      final result = p.compose(inner);
      final expected = Polynomial([1, 4, 4]); // 1 + 4t + 4t²
      for (final t in [0.0, 0.5, 1.0, -0.5]) {
        expect(result(t), closeTo(expected(t), 1e-9));
      }
    });

    test('compose verifies Bézier reparameterization', () {
      // A quadratic Bézier on [0,1] restricted to [0.25, 0.75] should equal
      // the sub-curve parameterized by t ∈ [0,1] via L(t) = 0.25 + 0.5t.
      // p(t) = t², sub-range [0.25, 0.75] → L(t) = 0.25 + 0.5t
      final p = Polynomial([0, 0, 1]); // t²
      final sub = Polynomial([0.25, 0.5]); // 0.25 + 0.5t
      final composed = p.compose(sub);
      for (final t in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        expect(composed(t), closeTo(p(0.25 + 0.5 * t), 1e-9));
      }
    });

    test('compose of zero polynomial returns zero', () {
      final zero = Polynomial([0]);
      final inner = Polynomial([1, 2, 3]);
      expect(zero.compose(inner).isZero, isTrue);
    });
  });

  group('Polynomial.gcd', () {
    test('gcd of polynomial with itself is monic self', () {
      final p = Polynomial([2, 4, 2]); // 2 + 4t + 2t² = 2(1 + t)²
      final g = Polynomial.gcd(p, p);
      // GCD should be monic (1 + t)²
      final expected = Polynomial([1, 2, 1]);
      for (final t in [0.0, 0.5, 1.0, -0.5]) {
        expect(g(t), closeTo(expected(t), 1e-7));
      }
    });

    test('gcd of coprime polynomials is 1', () {
      // (t - 2) and (t - 3) share no roots
      final a = Polynomial([-2, 1]); // t - 2
      final b = Polynomial([-3, 1]); // t - 3
      final g = Polynomial.gcd(a, b);
      expect(g.degree, equals(0));
      expect(g(0.0), closeTo(1.0, 1e-9)); // monic constant = 1
    });

    test('gcd of polynomials with common linear factor', () {
      // (t - 1)(t - 2) and (t - 1)(t - 3) → gcd = (t - 1)
      final a = Polynomial([2, -3, 1]); // (t-1)(t-2) = 2 - 3t + t²
      final b = Polynomial([3, -4, 1]); // (t-1)(t-3) = 3 - 4t + t²
      final g = Polynomial.gcd(a, b);
      expect(g.degree, equals(1));
      // monic: (t - 1) → evaluates to 0 at t=1
      expect(g(1.0).abs(), lessThan(1e-6));
      expect(g(0.0), closeTo(-1.0, 1e-6)); // -1 + t evaluated at 0
    });

    test('gcd with zero polynomial returns monic other', () {
      final p = Polynomial([2, 2]); // 2 + 2t
      final zero = Polynomial([0]);
      final g = Polynomial.gcd(p, zero);
      expect(g.degree, equals(1));
      expect(g(1.0), closeTo(2.0, 1e-9)); // monic 1+t at t=1 = 2
    });

    test('gcd of both zero is zero', () {
      final g = Polynomial.gcd(Polynomial([0]), Polynomial([0]));
      expect(g.isZero, isTrue);
    });

    test('gcd symmetric: gcd(a,b) == gcd(b,a)', () {
      final a = Polynomial([2, -3, 1]);
      final b = Polynomial([3, -4, 1]);
      final g1 = Polynomial.gcd(a, b);
      final g2 = Polynomial.gcd(b, a);
      for (final t in [0.0, 0.5, 1.0]) {
        expect(g1(t), closeTo(g2(t), 1e-9));
      }
    });
  });

  group('Polynomial.monic', () {
    test('monic of 2t² + 4t + 2 is t² + 2t + 1', () {
      final p = Polynomial([2.0, 4.0, 2.0]);
      final m = p.monic();
      expect(m[0], closeTo(1.0, 1e-9));
      expect(m[1], closeTo(2.0, 1e-9));
      expect(m[2], closeTo(1.0, 1e-9));
    });

    test('monic of already-monic polynomial is itself', () {
      final p = Polynomial([1.0, 2.0, 1.0]);
      final m = p.monic();
      for (final t in [0.0, 0.5, 1.0]) {
        expect(m(t), closeTo(p(t), 1e-9));
      }
    });
  });

  group('Polynomial.isNearlyZero', () {
    test('zero polynomial is nearly zero', () {
      expect(Polynomial([0]).isNearlyZero(), isTrue);
    });

    test('polynomial with tiny coefficients is nearly zero', () {
      expect(Polynomial([1e-10, 1e-10]).isNearlyZero(), isTrue);
    });

    test('polynomial with non-negligible coefficients is not nearly zero', () {
      expect(Polynomial([0.01, 0]).isNearlyZero(), isFalse);
    });
  });
}
