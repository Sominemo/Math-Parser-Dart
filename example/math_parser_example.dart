import 'package:math_parser/math_parser.dart';
import 'package:math_parser/integrate.dart';

/// Example function to calculate an expression from string
void main() {
  // Parsing string to a MathNode
  final expression = MathNodeExpression.fromString(
    '((2x)^(e^3 + 4) + cos(3)x) / log[x_1*2 + 3^2e](2 + (3y)^2)^5 * (2 + y)(x^2 + 3) + arcctg(Θ)',
    variableNames: {'x', 'y', 'Θ', 'x_1'},
  );
  // Display the parsed expression in human-readable form
  print(expression);

  // Evaluate the expression with `x = 20`, `y = 2`, `theta = 1/2`
  // and display result
  print(expression.calc(
    MathVariableValues({'x': 20, 'y': 2, 'Θ': 0.5, 'x_1': 3}),
  ));
}

/// Integrate library example
void integrate() {
  print(
    MathNodeExpression.fromString('cos(x)')
        .definiteIntegralBySimpson(10, 0, 3.14),
  );
}
