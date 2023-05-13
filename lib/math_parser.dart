/// Parse and evaluate mathematical expressions
///
/// A simple library done for tasks like function evaluation
///
/// Look at [MathNodeExpression]'s `fromString` method for more info about
/// how parsing works.
///
///## Parsing TL;DR
///### Predefined list of variables
///
///```dart
///import 'package:math_parser/math_parser.dart';
///
///void main() {
///  final expression = MathNodeExpression.fromString(
///  '(2x)^(e^3 + 4) + y',
///  variableNames: {'x', 'y'},
///  ).calc(
///    MathVariableValues({'x': 20, 'y': 10}),
///  );
///}
///```
///
///### Autodetect variables
///
///Implicit multiplication (writing `2x` instead of `2*x`) is not supported for auto-detecting variables.
///Trying to use auto-detection on expressions with implicit multiplication may cause a `CantProcessExpressionException` during parsing or unexpected parsing results.
///
///```dart
///import 'dart:io';
///import 'package:math_parser/math_parser.dart';
///
///void main() {
///  final stringExpression = '(2*x)^(e^3 + 4) + y';
///  print('Expression: $stringExpression');
///
///  final definable = MathNodeExpression.getPotentialDefinable(
///    stringExpression,
///    hideBuiltIns: true,
///  );
///
///  final expression = MathNodeExpression.fromString(
///    stringExpression,
///    variableNames: definable.variables,
///    isImplicitMultiplication: false,
///  );
///
///  // Ask user to define variables
///  final variableValues = <String, double>{};
///  for (final variable in definable.variables) {
///    print('Enter value for $variable:');
///    final double value = double.parse(
///      stdin.readLineSync() as String,
///    );
///    variableValues[variable] = value;
///  }
///
///  final result = expression.calc(
///    MathVariableValues(variableValues),
///  );
///
///  print('Result: $result');
///}
///```
library math_parser;

export 'src/math_node.dart';
export 'src/parse.dart';
export 'src/math_errors.dart';
export 'src/parse_errors.dart';
