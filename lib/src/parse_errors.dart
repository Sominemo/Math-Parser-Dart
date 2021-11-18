/// Math parsing error
///
/// Errors must extends this class
abstract class MathException implements Exception {
  const MathException();
}

/// Missing Operator Operand Exception
///
/// Thrown when an operator lacks its left or right operand.
///
/// The operator which caused the problem is stored in [operator]
class MissingOperatorOperandException extends MathException {
  @override
  String toString() {
    return 'MissingOperatorOperandException: "$operator" has insufficient neighboring expressions';
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
class MissingFunctionArgumentListException extends MathException {
  @override
  String toString() {
    return 'MissingFunctionArgumentListException: "$func" has insufficient arguments fed';
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
class UnknownOperationException extends MathException {
  @override
  String toString() {
    return 'UnknownOperationException: "$operation" is an unknown operation in given context';
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
class CantProcessExpressionException extends MathException {
  @override
  String toString() {
    return 'CantProcessExpressionException: '
        'Some parts of the expression were left unprocessed: $parts.'
        '\nThis often happens if you haven\'t specified the multiplication '
        'operator explicitly and don\'t have isImplicitMultiplication turned on';
  }

  /// The unprocessed parts
  final String parts;

  /// Creates a new Cant Process Expression Exception
  const CantProcessExpressionException(this.parts);
}

/// Parsing Failed Exception
///
/// Thrown when parsing fails for an unknown reason
///
/// The error is stored in [error]
class ParsingFailedException extends MathException {
  @override
  String toString() {
    return 'ParsingFailedException: $error';
  }

  /// The unprocessed parts
  final Object error;

  /// Creates a new  Parsing Failed Exception
  const ParsingFailedException(this.error);
}

/// Unexpected Closing Bracket Exception
///
/// Thrown when an unexpected closing bracket is met by the parser
///
/// The type of bracket is stored in [type]
class UnexpectedClosingBracketException extends MathException {
  @override
  String toString() {
    return 'UnexpectedClosingBracketException: A bracket of type "$type" was found in unexpected context';
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
class BracketsNotClosedException extends MathException {
  @override
  String toString() {
    return "BracketsNotClosedException: A bracket of type \"$type\" wasn't closed so correct expression parsing can't be guaranteed";
  }

  /// The type of bracket
  final String type;

  /// Creates a new Brackets Not Closed Exception
  const BracketsNotClosedException(this.type);
}
