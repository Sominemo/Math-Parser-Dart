import '../math_node.dart';

/// Integrate Extension
///
/// Numerical methods to calculate integral of given expression
extension MathNodeDefiniteIntegral on MathNode {
  /// Definite Integral By Left Rectangles
  ///
  /// [n] - precision
  num definiteIntegralByLeftRectangles(int n, num lowerLimit, num upperLimit) {
    final values = List<num>.unmodifiable(
      _calculateMathNodeAtPoints(
        this,
        _stepsWithFirst(n, lowerLimit, upperLimit),
      ),
    );
    final sum = values.reduce((value, element) => value + element);

    return ((upperLimit - lowerLimit) / n) * sum;
  }

  /// Definite Integral By Right Rectangles
  ///
  /// [n] - precision
  num definiteIntegralByRightRectangles(int n, num lowerLimit, num upperLimit) {
    final values = List<num>.unmodifiable(
      _calculateMathNodeAtPoints(
        this,
        _stepsWithLast(n, lowerLimit, upperLimit),
      ),
    );

    final sum = values.reduce((value, element) => value + element);

    return ((upperLimit - lowerLimit) / n) * sum;
  }

  /// Definite Integral By Middle Rectangles
  ///
  /// [n] - precision
  num definiteIntegralByMiddleRectangles(
      int n, num lowerLimit, num upperLimit) {
    final values = List<num>.unmodifiable(
      _calculateMathNodeAtPoints(
        this,
        _stepsAtMiddle(n, lowerLimit, upperLimit),
      ),
    );

    final sum = values.reduce((value, element) => value + element);

    return ((upperLimit - lowerLimit) / n) * sum;
  }

  /// Definite Integral By Simpson
  ///
  /// [n] - precision
  num definiteIntegralBySimpson(int n, num lowerLimit, num upperLimit) {
    final values = List<num>.unmodifiable(
      _calculateMathNodeAtPoints(
        this,
        _stepsAll(n, lowerLimit, upperLimit),
      ),
    );

    num res = values.first + values.last;
    for (int i = 1; i < n; i++) {
      res += (i.isOdd ? 4 : 2) * values[i];
    }

    return res * (upperLimit - lowerLimit) / n / 3;
  }

  /// Definite Integral By Trapezoids
  ///
  /// [n] - precision
  num definiteIntegralByTrapezoids(int n, num lowerLimit, num upperLimit) {
    final values = List<num>.unmodifiable(
      _calculateMathNodeAtPoints(
        this,
        _stepsAll(n, lowerLimit, upperLimit),
      ),
    );

    num res = (values.first + values.last) / 2;
    for (int i = 1; i < n; i++) {
      res += values[i];
    }

    return res * (upperLimit - lowerLimit) / n;
  }
}

Iterable<num> _stepsAll(int n, num lowerLimit, num upperLimit) sync* {
  final step = (upperLimit - lowerLimit) / n;
  for (num i = 0; i <= n; i++) {
    yield lowerLimit + step * i;
  }
}

Iterable<num> _stepsWithFirst(int n, num lowerLimit, num upperLimit) sync* {
  final step = (upperLimit - lowerLimit) / n;
  for (num i = 0; i < n; i++) {
    yield lowerLimit + step * i;
  }
}

Iterable<num> _stepsWithLast(int n, num lowerLimit, num upperLimit) sync* {
  final step = (upperLimit - lowerLimit) / n;
  for (num i = 1; i <= n; i++) {
    yield lowerLimit + step * i;
  }
}

Iterable<num> _stepsAtMiddle(int n, num lowerLimit, num upperLimit) sync* {
  final step = (upperLimit - lowerLimit) / n;
  for (num i = 0; i < n; i++) {
    yield lowerLimit + step / 2 + step * i;
  }
}

Iterable<num> _calculateMathNodeAtPoints(
    MathNode expression, Iterable<num> points) sync* {
  for (final point in points) {
    yield expression.calc(MathVariableValues.x(point));
  }
}
