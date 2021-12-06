import 'package:math_parser/src/math_errors.dart';

/// Math Parse Exception
///
/// All sorts of errors related to parsing a string to [MathNode] used by
/// [MathNodeExpression]. All actual exceptions are being extended from this
/// class.
abstract class MathParseException extends MathException {
  /// Creates a new Math Parse Exception
  const MathParseException();
}

/// Missing Operator Operand Exception
///
/// Thrown when an operator lacks its left or right operand.
///
/// The operator which caused the problem is stored in [operator]
class MissingOperatorOperandException extends MathParseException {
  @override
  String toString() {
    return 'MissingOperatorOperandException: "$operator" has insufficient '
        'neighboring expressions';
  }

  /// The operator the error happened in
  final String operator;

  /// Creates a new Missing Operator Operand Exception
  const MissingOperatorOperandException(this.operator);
}

/// Missing Function Argument List Exception
///
/// Thrown when a function receives less arguments than it expects.
///
/// The function which caused the problem is stored in [func]
class MissingFunctionArgumentListException extends MathParseException {
  @override
  String toString() {
    return 'MissingFunctionArgumentListException: "$func" has insufficient '
        'arguments fed';
  }

  /// The function which caused the problem
  final String func;

  /// Creates a new Missing Function Argument List Exception
  const MissingFunctionArgumentListException(this.func);
}

/// Unknown Operation Exception
///
/// Thrown when the parser finds syntax it doesn't understand
///
/// The part which caused the problem is stored in [operation]
class UnknownOperationException extends MathParseException {
  @override
  String toString() {
    return 'UnknownOperationException: "$operation" is an unknown operation '
        'in given context';
  }

  /// The part which caused the problem
  final String operation;

  /// Creates a new Unknown Operation Exception
  const UnknownOperationException(this.operation);
}

/// Cant Process Expression Exception
///
/// Thrown when some parts of the expression were left unprocessed
///
/// The unprocessed parts are stored as a string in [parts]
class CantProcessExpressionException extends MathParseException {
  @override
  String toString() {
    return 'CantProcessExpressionException: '
        'Some parts of the expression were left unprocessed: '
        '${parts.map((p) => p.toString()).join(', ')}.'
        '\nThis often happens if you used an undefined variable in '
        'variableNames parameter of the parse function or you haven\'t '
        'specified the multiplication operator explicitly and don\'t have '
        'isImplicitMultiplication turned on';
  }

  /// The unprocessed parts
  final List<Object> parts;

  /// Creates a new Cant Process Expression Exception
  const CantProcessExpressionException(this.parts);
}

/// Parsing Failed Exception
///
/// Thrown when parsing fails for an unknown reason
///
/// The error is stored in [error]
class ParsingFailedException extends MathParseException {
  @override
  String toString() {
    return 'ParsingFailedException: $error';
  }

  /// The unprocessed parts
  final Object error;

  /// Creates a new Parsing Failed Exception
  const ParsingFailedException(this.error);
}

/// Unexpected Closing Bracket Exception
///
/// Thrown when an unexpected closing bracket is met by the parser
///
/// The type of bracket is stored in [type]
class UnexpectedClosingBracketException extends MathParseException {
  @override
  String toString() {
    return 'UnexpectedClosingBracketException: A bracket of type "$type" was '
        'found in unexpected context';
  }

  /// The type of bracket
  final String type;

  /// Creates a new Unexpected Closing Bracket Exception
  const UnexpectedClosingBracketException(this.type);
}

/// Brackets Not Closed Exception
///
/// Thrown when parser notices there are unclosed brackets, so it can't guarantee
/// correct parsing of the expression
///
/// The type of bracket is stored in [type]
class BracketsNotClosedException extends MathParseException {
  @override
  String toString() {
    return "BracketsNotClosedException: A bracket of type \"$type\" wasn't "
        "closed so correct expression parsing can't be guaranteed";
  }

  /// The type of bracket
  final String type;

  /// Creates a new Brackets Not Closed Exception
  const BracketsNotClosedException(this.type);
}

/// Invalid Variable Name Exception
///
/// Thrown when variable has incorrect name
///
/// The name which caused the error is stored in [name]
class InvalidVariableNameException extends MathParseException {
  @override
  String toString() {
    return "InvalidVariableNameException: A variable with name \"$name\" can't"
        ' be defined. First character must be a letter, others - letters, '
        'digits, or underscore. Letters may be latin or Greek, both lower or '
        'capital case. You can\'t use built-in function names like sin, cos, '
        'etc. Variable names are case-sensitive';
  }

  /// The missing variable
  final String name;

  /// Created a new Undefined Variable Exception
  const InvalidVariableNameException(this.name);
}
