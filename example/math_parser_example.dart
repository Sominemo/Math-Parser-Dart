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

  // List all used variables
  print(expression.getUsedVariables());

  // Evaluate the expression with `x = 20`, `y = 2`, `theta = 1/2`, 'x_1 = 3'
  // and display result
  print(
    expression.calc(
      MathVariableValues({'x': 20, 'y': 2, 'Θ': 0.5, 'x_1': 3}),
    ),
  );

  // Compare expressions
  print(
    MathNodeExpression.fromStringExtended('2x-x=8x/2x-x=2').calc(
      MathVariableValues.x(2),
    ),
  );

  // Detect possible variable names
  final stringExpression =
      '((2*x)^(e^3 + 4) + cos(3)*x) / log[x_1*2 + 3^2*e](2 + (3*y)^2)^5 * (2 + y)*(x^2 + 3) + arcctg(Θ)';

  // Remove built-in variables if you are going to ask a user to enter the
  // values
  final vars = MathNodeExpression.getPotentialVariableNames(
    stringExpression,
    hideBuiltIns: true,
  );

// Show detected variables
  print(vars);

  // Use the vars to parse the math expression
  // Variable detection works properly only with implicit multiplication
  print(MathNodeExpression.fromString(
    stringExpression,
    variableNames: vars,
    isImplicitMultiplication: false,
  ));
}

/// Integrate library example
void integrate() {
  print(
    MathNodeExpression.fromString('cos(x)')
        .definiteIntegralBySimpson(10, 0, 3.14),
  );
}
