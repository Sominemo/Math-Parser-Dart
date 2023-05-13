# Math Parser for Dart

Process math expressions, convert them to machine-readable
form, and calculate them.

This package is aimed to help you to work with formulas,
parts of equations and other forms of simple math
expressions in your projects. This package supports custom
variables too.

## TL;DR How to parse and calculate an expression

### Predefined list of variables

```dart
import 'package:math_parser/math_parser.dart';

void main() {
  final expression = MathNodeExpression.fromString(
  '(2x)^(e^3 + 4) + y',
  variableNames: {'x', 'y'},
  ).calc(
    MathVariableValues({'x': 20, 'y': 10}),
  );
}
```

### Autodetect variables

Implicit multiplication (writing `2x` instead of `2*x`) is not supported for auto-detecting variables.
Trying to use auto-detection on expressions with implicit multiplication may cause a `CantProcessExpressionException` during parsing or unexpected parsing results.

```dart
import 'dart:io';
import 'package:math_parser/math_parser.dart';

void main() {
  final stringExpression = '(2*x)^(e^3 + 4) + y';
  print('Expression: $stringExpression');

  final definable = MathNodeExpression.getPotentialDefinable(
    stringExpression,
    hideBuiltIns: true,
  );

  final expression = MathNodeExpression.fromString(
    stringExpression,
    variableNames: definable.variables,
    isImplicitMultiplication: false,
  );

  // Ask user to define variables
  final variableValues = <String, double>{};
  for (final variable in definable.variables) {
    print('Enter value for $variable:');
    final double value = double.parse(
      stdin.readLineSync() as String,
    );
    variableValues[variable] = value;
  }

  final result = expression.calc(
    MathVariableValues(variableValues),
  );

  print('Result: $result');
}
```

## Features: In Short

For more details about these features, refer to documentation,
this readme or example file. All public API elements are
documented.

-   Parse mathematical expressions using
    `MathNodeExpression.fromString` or equations using
    `MathNodeExpression.fromStringExtended`.
-   Define custom variables and functions by passing
    `variableNames` and `customFunctions` parameters. To define
    a custom function, you'll have to implement the
    `MathDefinitionFunctionFreeformImplemented` interface for
    each such function.
-   Automatically detect possible variable and function names used in
    an expression, but this works reliably only with implicit
    multiplication off.

## Advanced use: Math Tree

The library provides a family of `MathExpression` and
`MathNode` classes, most of them have subnodes that are being
calculated recursively.

There are such types of MathNode:

-   `MathFunction` (and `MathFunctionWithTwoArguments` subclass)
-   `MathValue`
-   `MathOperator`

Types of `MathExpression`:

-   `MathComparison`

All the child classes names begin with the family they belong to.

## Evaluation

You can evaluate a MathNode and its subnodes recursively by calling
`MathNode.calc(MathVariableValues values)` and passing custom
variable values.

Example: Calculate `x + 3`, where `x = 5`.

```dart
MathOperatorAddition(
    MathVariable('x'),
    const MathValue(3),
).calc(MathVariableValues.x(5));
```

You can also evaluate `MathExpression.calc`, but this method
doesn't guarantee numeric result, so it may return null.

## Parsing String to MathNode

The library can parse general mathematical expressions strings
and return them as a machine-readable `MathNode` using
`MathNodeExpression.fromString` method.

Define custom variables with `variableNames` parameter. Don't forget to
define the variable value in `MathExpression.calc` when calling it.

Define custom functions using `customFunctions` argument. You can use either
`MathCustomFunctions` class, which plainly declares the functions, or
`MathCustomFunctionsImplemented`, which also requires to implement the
function. When you use `MathCustomFunctionsImplemented` during parsing,
you don't need to redeclare the function in `MathExpression.calc`.

### Parse priority:

1. Parentheses () []
2. Variables: e, pi (π) and custom ones. `x` is being interpreted as a var
   by default, but you can override this behavior with the variableNames
   parameter. You can rewrite e and pi by defining it in variableNames and
   mentioning it during the calc call.
   First character must be a letter or \_, others - letters, digits, period,
   or underscore. Last symbol can't be a period. Letters may be latin or
   Greek, both lower or capital case. You can't use built-in function
   names like sin, cos, etc. Variable names are case-sensitive. Custom
   functions have the same requirements, except they can override built-in
   functions.
3. Functions (case-sensitive):
    - Custom functions
    - sin, cos, tan (tg), cot (ctg)
    - sqrt (√) (interpreted as power of 1/2), complex numbers not supported
    - ln (base=E), lg (base=2), log\[base\]\(x\)
    - asin (arcsin), acos (arccos), atan (arctg), acot (arcctg)
4. Unary minus (-) at the beginning of a block
5. Power (x^y)
6. Implicit multiplication (two MathNodes put near without operator between)
7. Division (/) & Multiplication (\*)
8. Subtraction (-) & Addition (+)

```dart
MathNode fromString(
    /// The expression to convert
    String expression, {

    /// Converts all X - Y to X + (-Y)
    bool isMinusNegativeFunction = false,

    /// Allows skipping the multiplication (*) operator
    bool isImplicitMultiplication = true,

    /// Expressions which should be marked as variables
    Set<String> variableNames = const {'x'},

    /// Expressions which should be marked as functions
    MathCustomFunctions customFunctions = const MathCustomFunctions({}),
  });
```

Example for parsing a string and evaluating it with `x = 20`:

```dart
final expression = MathNodeExpression.fromString(
  '(2x)^(e^3 + 4) + x',
).calc(
  MathVariableValues({'x': 20}),
);
```

More complicated work with variables and functions is shown off in
example.

You can also parse equations with `MathNodeExpression.fromStringExtended`,
refer to example for this.

### Detect used variable names

You can detect possible variable names used in a string math expression
using `MathNodeExpression.getPotentialDefinable`.

Detecting variable names works properly only when implicit multiplication
is disabled.

```dart
final expr = '2*a+b';

final definable = MathNodeExpression.getPotentialDefinable(
  expr,
  hideBuiltIns: true,
);

MathNodeExpression.fromString(
  expr,
  variableNames: definable.variables,
  isImplicitMultiplication: false,
);
```

## Other Features

### Numerical methods for Definite Integrals

You can calculate a given node as a definite integral using
the `MathNodeDefiniteIntegral` extension. All methods have
the same interface:

```dart
num definiteIntegralByLeftRectangles(
    /// Precision
    int n,
    num lowerLimit,
    num upperLimit,
);

```
