/// Parse and evaluate mathematical expressions
///
/// A simple library done for tasks like function evaluation
///
/// Example for parsing a string and calculating it with x = 20.
/// Look at [MathNodeExpression]'s `fromString` method for more info about
/// how parsing works.
///
/// ```dart
/// import 'package:math_parser/math_parser.dart';
///
/// void main() {
///   final expression = MathNodeExpression.fromString(
///     '(2x)^(e^3 + 4)',
///   );
///   print(expression.calc(20));
/// }
/// ```
library math_parser;

export 'src/math_node.dart';
export 'src/parse.dart';
export 'src/math_errors.dart';
export 'src/parse_errors.dart';
