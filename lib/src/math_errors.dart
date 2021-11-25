/// Math parsing error
///
/// Errors must extends this class
abstract class MathException implements Exception {
  /// Creates a new Math Exception
  const MathException();
}

/// Undefined Variable Exception
///
/// Thrown when there's a variable referenced in calculations which wasn't passed
/// to the [MathNode.calc] function
class UndefinedVariableException extends MathException {
  @override
  String toString() {
    return 'UndefinedVariableException: Variable "$name" was not defined in '
        'the calc() function. Variable names are case-sensitive';
  }

  /// The missing variable
  final String name;

  /// Created a new Undefined Variable Exception
  const UndefinedVariableException(this.name);
}
