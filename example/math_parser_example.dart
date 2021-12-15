import 'package:math_parser/math_parser.dart';
import 'package:math_parser/integrate.dart';

/// Example function to calculate an expression from string
void main() {
  // Parsing string to a MathNode
  final expression = MathNodeExpression.fromString(
    '([2x]^(e^3 + 4) + cos(3)x) / log[x_1*2 + 3^2e, 2 + (3y)^2]^5 * (2 + y)(x^2 + 3) + arcctg(Θ) + 2',
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
      '((2*x)^(e^3 + 4) + cos(3)*x) / log(x_1*2 + 3^2*e, 2 + (3*y)^2)^5 * (2 + y)*(x^2 + 3) + arcctg(Θ) + 2';

  // Remove built-in variables if you are going to ask a user to enter the
  // values
  final definable = MathNodeExpression.getPotentialDefinable(
    stringExpression,
    hideBuiltIns: true,
  );

  // Show all detected variables
  print(MathNodeExpression.getPotentialDefinable(
    stringExpression,
    hideBuiltIns: false,
  ));

  // Use the vars to parse the math expression
  // Variable detection works properly only with implicit multiplication
  print(MathNodeExpression.fromString(
    stringExpression,
    variableNames: definable.variables,
    isImplicitMultiplication: false,
  ));

  integrate();
  customFunctions();
}

/// Integrate library example
void integrate() {
  print(
    MathNodeExpression.fromString('cos(x)')
        .definiteIntegralBySimpson(10, 0, 3.14),
  );
}

/// Custom functions

/// Define custom functions
class MathFunctionT1 implements MathDefinitionFunctionFreeformImplemented {
  @override
  final name = 't1';
  @override
  final minArgumentsCount = 1;
  @override
  final maxArgumentsCount = 1;

  @override
  num calc(
    List<MathNode> args,
    MathVariableValues values, {
    required MathCustomFunctionsImplemented customFunctions,
  }) {
    return 2 * args[0].calc(values, customFunctions: customFunctions);
  }

  @override
  bool hasSameName(String other) {
    return other == name;
  }

  @override
  bool isCompatible(MathDefinitionFunctionFreeform other) {
    return hasSameName(other.name) &&
        minArgumentsCount == other.minArgumentsCount &&
        maxArgumentsCount == other.maxArgumentsCount;
  }

  const MathFunctionT1();
}

class MathFunctionT2 implements MathDefinitionFunctionFreeformImplemented {
  @override
  final name = 't2';
  @override
  final minArgumentsCount = 1;
  @override
  final maxArgumentsCount = 1;

  @override
  num calc(
    List<MathNode> args,
    MathVariableValues values, {
    required MathCustomFunctionsImplemented customFunctions,
  }) {
    return 0.5 * args[0].calc(values, customFunctions: customFunctions);
  }

  @override
  bool hasSameName(String other) {
    return other == name;
  }

  @override
  bool isCompatible(MathDefinitionFunctionFreeform other) {
    return hasSameName(other.name) &&
        minArgumentsCount == other.minArgumentsCount &&
        maxArgumentsCount == other.maxArgumentsCount;
  }

  const MathFunctionT2();
}

/// Redefines built-in function
class CustomCos implements MathDefinitionFunctionFreeformImplemented {
  @override
  final name = 'cos';
  @override
  final minArgumentsCount = 1;
  @override
  final maxArgumentsCount = 1;

  @override
  num calc(
    List<MathNode> args,
    MathVariableValues values, {
    required MathCustomFunctionsImplemented customFunctions,
  }) {
    return 2 *
        args[0].calc(
          values,
          customFunctions: customFunctions,
        );
  }

  @override
  bool hasSameName(String other) {
    return other == name;
  }

  @override
  bool isCompatible(MathDefinitionFunctionFreeform other) {
    return hasSameName(other.name) &&
        minArgumentsCount == other.minArgumentsCount &&
        maxArgumentsCount == other.maxArgumentsCount;
  }

  const CustomCos();
}

/// Define a function without implementing it
class WillImplementLater implements MathDefinitionFunctionFreeform {
  @override
  final name = 'time';
  @override
  final minArgumentsCount = 0;
  @override
  final maxArgumentsCount = 0;

  @override
  bool hasSameName(String other) {
    return other == name;
  }

  @override
  bool isCompatible(MathDefinitionFunctionFreeform other) {
    return hasSameName(other.name) &&
        minArgumentsCount == other.minArgumentsCount &&
        maxArgumentsCount == other.maxArgumentsCount;
  }

  const WillImplementLater();
}

/// Same function as [WillImplementLater] but with implementation
class PromisedImplementation
    implements MathDefinitionFunctionFreeformImplemented {
  @override
  final name = 'time';
  @override
  final minArgumentsCount = 0;
  @override
  final maxArgumentsCount = 0;

  @override
  bool hasSameName(String other) {
    return other == name;
  }

  @override
  bool isCompatible(MathDefinitionFunctionFreeform other) {
    return hasSameName(other.name) &&
        minArgumentsCount == other.minArgumentsCount &&
        maxArgumentsCount == other.maxArgumentsCount;
  }

  @override
  num calc(
    List<MathNode> args,
    MathVariableValues values, {
    required MathCustomFunctionsImplemented customFunctions,
  }) {
    return DateTime.now().millisecondsSinceEpoch;
  }

  const PromisedImplementation();
}

/// Use of custom functions in code
void customFunctions() {
  final expr = MathNodeExpression.fromStringExtended(
    '2x-x=t1(t2(x))=2',
    customFunctions: MathCustomFunctionsImplemented({
      const MathFunctionT1(),
      const MathFunctionT2(),
    }),
  );

  // Show used custom functions
  print(expr.getUsedFreeformFunctions());

// Calculate
  print(
    expr.calc(
      MathVariableValues.x(2),
      // You may omit defining functions in call method if you used
      // `MathDefinitionFunctionFreeformImplemented` during parsing
    ),
  );

  // Redefine built-ins
  print(
    MathNodeExpression.fromString('cos(x)',
        customFunctions: MathCustomFunctionsImplemented({
          const CustomCos(),
        })).calc(
      MathVariableValues.x(0.5),
    ),
  );

  // Define now - implement later
  final parsedExpr = MathNodeExpression.fromString(
    '1 + time()',
    customFunctions: MathCustomFunctions({
      const WillImplementLater(),
    }),
  );

  print(parsedExpr.calc(
    MathVariableValues.none,
    customFunctions: MathCustomFunctionsImplemented({
      const PromisedImplementation(),
    }),
  ));
}
