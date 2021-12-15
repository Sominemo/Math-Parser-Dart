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

/// Out Of Range Function Argument List Exception
///
/// Thrown when a function receives less or more arguments than it expects.
///
/// The function which caused the problem is stored in [func]
class OutOfRangeFunctionArgumentListException extends MathParseException {
  @override
  String toString() {
    return 'OutOfRangeFunctionArgumentListException: "$func" has insufficient '
        'arguments fed or has too much of them';
  }

  /// The function which caused the problem
  final String func;

  /// Creates a new Out Of Range Function Argument List Exception
  const OutOfRangeFunctionArgumentListException(this.func);
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
        '\nThis often happens if you used an undefined variable or function in '
        'variableNames and customFunctions parameters of the parse function or '
        'you haven\'t specified the multiplication operator explicitly and '
        'don\'t have isImplicitMultiplication turned on';
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
        'found in unexpected context at position $position';
  }

  /// The type of bracket
  final String type;

  /// Error position
  final int position;

  /// Creates a new Unexpected Closing Bracket Exception
  const UnexpectedClosingBracketException(this.type, this.position);
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
    return 'BracketsNotClosedException: A bracket of type "$type" was opened '
        "at position $startPosition but wasn't closed before position "
        "$position so correct expression parsing can't be guaranteed.";
  }

  /// The type of bracket
  final String type;

  /// Start position
  final int startPosition;

  /// Error position
  final int position;

  /// Creates a new Brackets Not Closed Exception
  const BracketsNotClosedException(
    this.type,
    this.startPosition,
    this.position,
  );
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
        'digits, period, or underscore.  Last symbol can\'t be a period. '
        'Letters may be latin or Greek, both lower or capital case. You can\'t'
        ' use built-in function names like sin, cos, etc. Variable names are '
        'case-sensitive. You can check name validity in '
        'MathNodeExpression.isVariableNameValid()';
  }

  /// The incorrect variable
  final String name;

  /// Created a new Undefined Variable Exception
  const InvalidVariableNameException(this.name);
}

/// Invalid Function Name Exception
///
/// Thrown when function has incorrect name
///
/// The definition which caused the error is stored in [name]
class InvalidFunctionNameException extends MathParseException {
  @override
  String toString() {
    return "InvalidFunctionNameException: A function with name \"$name\" can't"
        ' be defined. First character must be a letter or _, others - letters, '
        'digits, period, or underscore. Last symbol can\'t be a period. '
        'Letters may be latin or Greek, both lower or capital case. Function '
        'names are case-sensitive. You can check name validity in '
        'MathNodeExpression.isVariableNameValid()';
  }

  /// The incorrect function definition
  final String name;

  /// Created a new Undefined Function Exception
  const InvalidFunctionNameException(this.name);
}

/// Duplicate Declaration Exception
///
/// Thrown when there's a function with the same name as a defined variable
class DuplicateDeclarationException extends MathParseException {
  @override
  String toString() {
    return 'DuplicateDeclarationException: Function "$name" was already '
        'defined as a variable.';
  }

  /// The problematic function
  final String name;

  /// Created a new Duplicate Declaration Exception
  const DuplicateDeclarationException(this.name);
}

/// Invalid Function Arguments Declaration
///
/// Thrown when function has invalid function arguments range
class InvalidFunctionArgumentsDeclaration extends MathParseException {
  @override
  String toString() {
    return 'InvalidFunctionArgumentsDeclaration: Function "$name" has '
        'incorrect accepting arguments range.';
  }

  /// The problematic function
  final String name;

  /// Created a new Invalid Function Arguments Declaration
  const InvalidFunctionArgumentsDeclaration(this.name);
}
