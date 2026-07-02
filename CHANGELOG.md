## 1.0.1

- Add `ClosedFormMethod` solver for exact analytical real-root solving of polynomials with degree ≤ 4 (quadratic, cubic, and quartic formulas).
- Add `Polynomial.gcd` to compute the monic greatest common divisor of two polynomials via the Euclidean algorithm.
- Add `Polynomial.compose` to compute functional composition $p(q(t))$ (substituting one polynomial into another).
- Add `Polynomial.monic` to normalize a polynomial to its monic form (leading coefficient = 1).
- Add `Polynomial.isNearlyZero` to check if all coefficients are within a given tolerance of zero.

## 1.0.0

- Initial version.
