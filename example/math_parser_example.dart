import 'package:math_parser/math_parser.dart';

void main() {
  // Parsing string to a MathNode
  final expression = MathNodeExpression.fromString(
    '((2x)^(e^3 + 4) + cos(3)x) / log[x + 3^2e](2 + (3x)^2)^5 * (2 + x)(x^2 + 3) + arcctg(x)',
  );
  // Display the parsed expression in human-readable form
  print(expression);

  // Evaluate the expression with `x = 20` and display result
  print(expression.calc(20));
}
