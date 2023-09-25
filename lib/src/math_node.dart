import 'dart:math' as math;

import 'math_errors.dart';

/// Variables dictionary
///
/// The class must be passed to the [MathNode.calc] function.
/// Map key value is the variable name, with a corresponding numeric value
class MathVariableValues {
  /// The map containing values
  final Map<String, num> _values;

  /// Get the variable value
  ///
  /// Throws UndefinedVariableException if variable is not set
  num operator [](String variableName) {
    final v = _values[variableName];
    if (v is num) {
      return v;
    } else {
      throw UndefinedVariableException(variableName);
    }
  }

  /// Creates new variables dictionary
  ///
  /// - Use [MathVariableValues.x] if you only need to set x
  /// - Use [MathVariableValues.none] if you are not using variables
  const MathVariableValues(this._values);

  /// Empty variables dictionary
  static const MathVariableValues none = MathVariableValues({});

  /// Creates a new x variable dictionary
  factory MathVariableValues.x(num x) => MathVariableValues({'x': x});
}

/// Any Math-related object
///
/// Main implementers are decedents of [MathNode] and [MathComparison] classes.
abstract class MathExpression {
  /// Math expression constructor
  const MathExpression();

  /// Generalized value for all sorts of math expressions, but result is not
  /// guaranteed.
  ///
  /// Tries to return the most appropriate result for given object type.
  /// For example, when working with [MathNode], it always returns its
  /// [MathNode.calc] result. For [MathComparisonEquation], a value of subnodes is
  /// being returned but only if they equal, else null will be returned.
  /// For [MathComparisonGreater] and [MathComparisonLess] returns a greater or a
  /// smaller value accordingly only if the expression is true.
  num? calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions,
  });

  /// Get mentioned variables that are required to evaluate the expression
  ///
  /// Searches the math tree for any [MathVariable] instances and returns a set
  /// of their names.
  Set<String> getUsedVariables();

  /// Get mentioned custom defined functions that are required to evaluate the expression
  ///
  /// Searches the math tree for any [MathFunctionFreeform] instances and returns a set
  /// of their definitions.
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions();
}

/// Basic math expression unit
///
/// Defines the [calc] method for every child to implement.
abstract class MathNode extends MathExpression {
  /// Evaluate the expression
  ///
  /// Will calculate the value of the given expression using the given [x] value
  /// The x variable
  ///
  /// When you mentioning an x in your expression, that part of the expression
  /// becomes inconstant and will change its result based on the given
  /// value.
  ///
  /// You can check an expression or its parts (subnodes) for being
  /// constant with the isConst() method of the ExtensionConstant* extension
  /// family.
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions,
  });

  /// Creates a new math expression node
  const MathNode();
}

/// Mathematical function
///
/// A basic function which accepts a single parameter
abstract class MathFunction implements MathNode {
  /// Function's parameter
  ///
  /// Can be any MathNode expression
  final MathNode x1;

  /// Creates a new mathematical function
  ///
  /// The first and only parameters is supposed to be function's argument
  const MathFunction(this.x1);

  @override
  Set<String> getUsedVariables() {
    return x1.getUsedVariables();
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return x1.getUsedFreeformFunctions();
  }
}

/// Mathematical function with two arguments
///
/// Practically the same as [MathFunction], but has support for a second [x2]
/// argument
abstract class MathFunctionWithTwoArguments implements MathFunction {
  /// Function's first parameter
  ///
  /// Can be any MathNode expression
  @override
  final MathNode x1;

  /// Function's second parameter
  ///
  /// Can be any MathNode expression
  final MathNode x2;

  /// Creates a new mathematical function with two arguments
  ///
  /// The parameters are supposed to be function's arguments
  const MathFunctionWithTwoArguments(this.x1, this.x2);

  @override
  Set<String> getUsedVariables() {
    return {...x1.getUsedVariables(), ...x2.getUsedVariables()};
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return {...x1.getUsedFreeformFunctions(), ...x2.getUsedFreeformFunctions()};
  }
}

/// Mathematical operator
///
/// Same as [MathFunctionWithTwoArguments], but has different semantics by using
/// [left] and [right] as arguments instead of numbered parameters
abstract class MathOperator implements MathNode {
  /// Operator's left operand
  final MathNode left;

  /// Operator's right operand
  final MathNode right;

  /// Creates a new mathematical operator
  const MathOperator(this.left, this.right);

  @override
  Set<String> getUsedVariables() {
    return {...left.getUsedVariables(), ...right.getUsedVariables()};
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return {
      ...left.getUsedFreeformFunctions(),
      ...right.getUsedFreeformFunctions()
    };
  }
}

/// Constant value
///
/// The given value never changes, is guaranteed to be numerical and constant
class MathValue extends MathNode {
  /// The value
  final num value;

  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      value;

  /// Creates a new constant value
  const MathValue(this.value);

  @override
  String toString() => 'VALUE($value)';

  @override
  Set<String> getUsedVariables() {
    return {};
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return {};
  }
}

/// A math variable
///
/// This value is being set from the [MathNode.calc] method and being passed to
/// every subnode.
///
/// The variable is being replaced by the passed value during calculation.
class MathVariable extends MathNode {
  /// Designed variable name
  final String variableName;

  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      values[variableName];

  /// Creates a new variable which will be replaced by a corresponding value
  const MathVariable(this.variableName);

  @override
  String toString() => 'VAR[$variableName]';

  @override
  Set<String> getUsedVariables() {
    return {variableName};
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return {};
  }
}

/// Freeform function
///
/// Allows to define a custom function
///
/// Despite being a function, does not extend [MathFunction]
class MathFunctionFreeform extends MathNode {
  /// Function definition
  final MathDefinitionFunctionFreeform definition;

  /// Arguments list
  final List<MathNode> arguments;

  /// Creates a new function definition
  const MathFunctionFreeform(this.definition, this.arguments);

  @override
  Set<String> getUsedVariables() {
    return {
      for (var l in arguments.map<Set<String>>((e) => e.getUsedVariables()))
        ...l
    };
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return {
      definition,
      for (var l in arguments.map<Set<MathDefinitionFunctionFreeform>>(
          (e) => e.getUsedFreeformFunctions()))
        ...l
    };
  }

  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) {
    final d = definition;

    if (d is MathDefinitionFunctionFreeformImplemented) {
      return d.calc(
        arguments,
        values,
        customFunctions: customFunctions,
      );
    }

    return customFunctions[d].calc(
      arguments,
      values,
      customFunctions: customFunctions,
    );
  }

  @override
  String toString() =>
      'FUNC:${definition.name}(${definition.minArgumentsCount}:${definition.maxArgumentsCount})[${arguments.join(', ')}]';
}

/// Addition operator (+)
///
/// Both operands are addends. This expression evaluates to the sum of left and
/// right operands.
class MathOperatorAddition extends MathOperator {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      left.calc(
        values,
        customFunctions: customFunctions,
      ) +
      right.calc(
        values,
        customFunctions: customFunctions,
      );

  /// Creates a new addition operation
  const MathOperatorAddition(
    /// A left addend
    MathNode left,

    /// A right addend
    MathNode right,
  ) : super(left, right);

  @override
  String toString() => '[$left + $right]';
}

/// Subtraction operator (-)
///
/// [left] operand is minuend, [right] is subtrahend. This expression evaluates to
/// the difference `left - right`
class MathOperatorSubtraction extends MathOperator {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      left.calc(
        values,
        customFunctions: customFunctions,
      ) -
      right.calc(
        values,
        customFunctions: customFunctions,
      );

  /// Creates a new subtraction operation
  const MathOperatorSubtraction(
    /// Minuend
    MathNode left,

    /// Subtrahend
    MathNode right,
  ) : super(left, right);

  @override
  String toString() => '[$left - $right]';
}

/// Multiplication operator (*)
///
/// Both operands are both factors. This expression evaluates to the product
class MathOperatorMultiplication extends MathOperator {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      left.calc(
        values,
        customFunctions: customFunctions,
      ) *
      right.calc(
        values,
        customFunctions: customFunctions,
      );

  /// Creates multiplication operator
  const MathOperatorMultiplication(MathNode left, MathNode right)
      : super(left, right);

  /// Multiplication with simplification of unary operations
  ///
  /// Returns value of either operand if the other operands equals the value of 1
  static MathNode withSimplifying(MathNode left, MathNode right) {
    if (left == const MathValue(1)) return right;
    if (right == const MathValue(1)) return left;

    return MathOperatorMultiplication(left, right);
  }

  @override
  String toString() => '[$left * $right]';
}

/// Division operator (/)
///
/// Left operand is dividend, right is divider. This expression evaluates to the
/// the quotient of these two.
class MathOperatorDivision extends MathOperator {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      left.calc(
        values,
        customFunctions: customFunctions,
      ) /
      right.calc(
        values,
        customFunctions: customFunctions,
      );

  /// Creates division operator
  const MathOperatorDivision(MathNode left, MathNode right)
      : super(left, right);

  @override
  String toString() => '[$left / $right]';

  /// Division with simplification of unary operations
  ///
  /// Returns left operand if right operand equals 1
  static MathNode withSimplifying(MathNode left, MathNode right) {
    if (right == const MathValue(1)) return left;

    return MathOperatorDivision(left, right);
  }
}

/// Negative value
///
/// Returns the opposite value for the underlying node
class MathFunctionNegative extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      -x1.calc(
        values,
        customFunctions: customFunctions,
      );

  /// Creates a negative value
  const MathFunctionNegative(MathNode x) : super(x);

  @override
  String toString() => '(-$x1)';
}

/// The Exponent in power constant
///
/// Value that evaluates to the natural exponent in given number. The power
/// of 1 is the default value.
class MathFunctionE extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.exp(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates an exponent value
  const MathFunctionE({MathNode x1 = const MathValue(1)}) : super(x1);

  @override
  String toString() => '[e ^ $x1]';
}

/// The Pi constant
///
/// Evaluates to Dart's [math.pi]
class MathValuePi extends MathValue {
  /// Creates Pi constant
  const MathValuePi() : super(math.pi);

  @override
  String toString() => 'PI';
}

/// The power operation
///
/// Evaluates to [left] in the power of [right].
class MathOperatorPower extends MathOperator {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.pow(
          left.calc(
            values,
            customFunctions: customFunctions,
          ),
          right.calc(
            values,
            customFunctions: customFunctions,
          ));

  /// Creates the power operation
  const MathOperatorPower(MathNode base, MathNode exponent)
      : super(base, exponent);

  @override
  String toString() => '[$left ^ $right]';
}

/// The sin Function
///
/// Evaluates to the value of sin at the point of [x1]
class MathFunctionSin extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.sin(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the sin function
  const MathFunctionSin(MathNode x1) : super(x1);

  @override
  String toString() => '[SIN($x1)]';
}

/// The cos Function
///
/// Evaluates to the value of cos at the point of [x1]
class MathFunctionCos extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.cos(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the cos function
  const MathFunctionCos(MathNode x1) : super(x1);

  @override
  String toString() => '[COS($x1)]';
}

/// The tan Function
///
/// Evaluates to the value of tan at the point of [x1]
class MathFunctionTan extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.tan(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the tan function
  const MathFunctionTan(MathNode x1) : super(x1);

  @override
  String toString() => '[TAN($x1)]';
}

/// The cot Function
///
/// Evaluates to the value of cot at the point of [x1]
class MathFunctionCot extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      1 /
      math.tan(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the cot function
  const MathFunctionCot(MathNode x1) : super(x1);

  @override
  String toString() => '[COT($x1)]';
}

/// The asin Function
///
/// Evaluates to the value of asin at the point of [x1]
class MathFunctionAsin extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.asin(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the asin function
  const MathFunctionAsin(MathNode x1) : super(x1);

  @override
  String toString() => '[ASIN($x1)]';
}

/// The acos Function
///
/// Evaluates to the value of acos at the point of [x1]
class MathFunctionAcos extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.acos(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the acos function
  const MathFunctionAcos(MathNode x1) : super(x1);

  @override
  String toString() => '[ACOS($x1)]';
}

/// The atan Function
///
/// Evaluates to the value of atan at the point of [x1]
class MathFunctionAtan extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.atan(x1.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the atan function
  const MathFunctionAtan(MathNode x1) : super(x1);

  @override
  String toString() => '[ATAN($x1)]';
}

/// The acot Function
///
/// Evaluates to the value of acot at the point of [x1]
class MathFunctionAcot extends MathFunction {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.atan(1 /
          x1.calc(
            values,
            customFunctions: customFunctions,
          ));

  /// Creates the acot function
  const MathFunctionAcot(MathNode x1) : super(x1);

  @override
  String toString() => '[ACOT($x1)]';
}

/// The log Function
///
/// Evaluates to the value of log at the point of [x1] by base of [x2]
///
/// By default it's natural logarithm (base equals 10)
class MathFunctionLog extends MathFunctionWithTwoArguments {
  @override
  num calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) =>
      math.log(x1.calc(
        values,
        customFunctions: customFunctions,
      )) /
      math.log(x2.calc(
        values,
        customFunctions: customFunctions,
      ));

  /// Creates the log function
  const MathFunctionLog(MathNode x1, {MathNode x2 = const MathValue(10)})
      : super(x1, x2);

  @override
  String toString() => '[LOG($x2, $x1)]';
}

/// The ln Function
///
/// Evaluates to the value of log at the point of [x1] by base of [MathFunctionE]
class MathFunctionLn extends MathFunctionLog {
  /// Creates the ln function
  const MathFunctionLn(MathNode number)
      : super(number, x2: const MathFunctionE());

  @override
  String toString() => '[LOG($x1, E]';
}

/// A parent class for comparisons
abstract class MathComparison extends MathExpression {
  /// Left comparable
  final MathExpression left;

  /// Right comparable
  final MathExpression right;

  /// Creates a new comparable
  const MathComparison(this.left, this.right);

  @override
  Set<String> getUsedVariables() {
    return {...left.getUsedVariables(), ...right.getUsedVariables()};
  }

  @override
  Set<MathDefinitionFunctionFreeform> getUsedFreeformFunctions() {
    return {
      ...left.getUsedFreeformFunctions(),
      ...right.getUsedFreeformFunctions()
    };
  }

  /// Evaluates the comparison and returns 1 if it is true
  /// and 0 otherwise
  num? evaluate(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      });
}

/// Equation
///
/// The equation class which can contain multiple MathExpressions to be compared
class MathComparisonEquation extends MathComparison {
  @override
  num? calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );

    if (leftResult == rightResult) return leftResult;

    return null;
  }

  @override
  num? evaluate(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );

    if (leftResult == rightResult) return 1;

    return 0;
  }


  @override
  String toString() {
    return '[$left = $right]';
  }

  /// Creates an equation
  const MathComparisonEquation(MathExpression left, MathExpression right)
      : super(left, right);
}

/// If Greater Comparison
///
/// Looks for a bigger MathExpression
class MathComparisonGreater extends MathComparison {
  @override
  num? calc(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult > rightResult) return leftResult;
    return rightResult;
  }

  @override
  num? evaluate(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult > rightResult) return 1;
    return 0;
  }

  @override
  String toString() {
    return '[$left > $right]';
  }

  /// Creates a greater comparison
  const MathComparisonGreater(MathExpression left, MathExpression right)
      : super(left, right);
}

/// If Greater or Equals Comparison
///
/// Looks for a bigger MathExpression
class MathComparisonGreaterOrEquals extends MathComparison {
  @override
  num? calc(
    MathVariableValues values, {
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult >= rightResult) return leftResult;
    return rightResult;
  }

  @override
  num? evaluate(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult >= rightResult) return 1;
    return 0;
  }

  @override
  String toString() {
    return '[$left >= $right]';
  }

  /// Creates a greater or equals comparison
  const MathComparisonGreaterOrEquals(MathExpression left, MathExpression right)
      : super(left, right);
}

/// If Less Comparison
///
/// Looks for a bigger MathExpression
class MathComparisonLess extends MathComparison {
  @override
  num? calc(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult < rightResult) return leftResult;
    return rightResult;
  }

  @override
  num? evaluate(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult < rightResult) return 1;
    return 0;
  }

  @override
  String toString() {
    return '[$left < $right]';
  }

  /// Creates a less comparison
  const MathComparisonLess(MathExpression left, MathExpression right)
      : super(left, right);
}

/// If Less or Equals Comparison
///
/// Looks for a bigger MathExpression
class MathComparisonLessOrEquals extends MathComparison {
  @override
  num? calc(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult <= rightResult) return leftResult;
    return rightResult;
  }

  @override
  num? evaluate(
      MathVariableValues values, {
        MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
      }) {
    final leftResult = left.calc(
      values,
      customFunctions: customFunctions,
    );
    if (leftResult == null) return null;

    final rightResult = right.calc(
      values,
      customFunctions: customFunctions,
    );
    if (rightResult == null) return null;

    if (leftResult <= rightResult) return 1;
    return 0;
  }

  @override
  String toString() {
    return '[$left <= $right]';
  }

  /// Creates a less comparison
  const MathComparisonLessOrEquals(MathExpression left, MathExpression right)
      : super(left, right);
}

/// Create a new freeform function
///
/// This class is intended to be extended when developer needs to
/// define a custom function to [MathNodeExpression.toString]
abstract class MathDefinitionFunctionFreeform {
  /// Function name used by parser
  ///
  /// Case sensitive
  String get name;

  /// Minimum arguments count
  int get minArgumentsCount;

  /// Maximum arguments count
  int get maxArgumentsCount;

  /// Checks function compatibility
  ///
  /// Must return true when a given function definition satisfies this custom
  /// function (in most cases, this means equal name and arguments number range)
  bool isCompatible(MathDefinitionFunctionFreeform other);

  /// Checks if the function has the name name
  ///
  /// Must return true when functions have the same name
  bool hasSameName(String other);

  @override
  String toString() {
    return 'FUNC_DEF:$name($minArgumentsCount:$maxArgumentsCount)';
  }
}

/// Create a new freeform function with implementation
///
/// This class in intended to be extended when developer declares
/// a usable custom function in [MathNodeExpression.toString] or
/// [MathExpression.calc] methods
abstract class MathDefinitionFunctionFreeformImplemented
    extends MathDefinitionFunctionFreeform {
  /// Defined implementation
  num calc(
    List<MathNode> args,
    MathVariableValues values, {
    required MathCustomFunctionsImplemented customFunctions,
  });
}

/// Set of custom functions
///
/// To declare a custom function, implement [MathDefinitionFunctionFreeform] or
/// [MathDefinitionFunctionFreeformImplemented] interface and pass it as a member
/// of the set when constructing this class.
///
/// When using [MathNodeExpression.fromString], you can omit implementing the
/// functions, but [MathExpression.calc] will require you to pass a
/// [MathCustomFunctionsImplemented] instance instead, which requires
/// the functions to have the calc method. If you pass
/// [MathDefinitionFunctionFreeformImplemented] in `fromString`, you won't need
/// to declare the implementation when parsing.
class MathCustomFunctions {
  /// Function definitions
  final Set<MathDefinitionFunctionFreeform> definitions;

  /// Creates a set of custom functions
  ///
  /// See class documentation for examples
  const MathCustomFunctions(this.definitions);

  /// Get a declaration by its descriptor
  MathDefinitionFunctionFreeform operator [](
      MathDefinitionFunctionFreeform key) {
    return definitions.firstWhere(
      (element) => element.isCompatible(key),
      orElse: () => throw UndefinedFunctionException(key.toString()),
    );
  }

  /// Get a declaration by its name
  MathDefinitionFunctionFreeform? byName(String name) {
    try {
      return definitions.firstWhere(
        (element) => element.hasSameName(name),
      );
    } on StateError {
      return null;
    } catch (e) {
      rethrow;
    }
  }
}

/// Set of custom implemented functions
///
/// To declare a custom function, implement [MathDefinitionFunctionFreeform] or
/// [MathDefinitionFunctionFreeformImplemented] interface and pass it as a member
/// of the set when constructing this class.
///
/// When using [MathNodeExpression.fromString], you can omit implementing the
/// functions, but [MathExpression.calc] will require you to pass a
/// [MathCustomFunctionsImplemented] instance instead, which requires
/// the functions to have the calc method. If you pass
/// [MathDefinitionFunctionFreeformImplemented] in `fromString`, you won't need
/// to declare the implementation when parsing.
class MathCustomFunctionsImplemented implements MathCustomFunctions {
  /// Expected function definitions
  @override
  final Set<MathDefinitionFunctionFreeformImplemented> definitions;

  /// Creates a set of custom defined functions
  ///
  /// See class documentation for examples
  const MathCustomFunctionsImplemented(this.definitions);

  /// Get a declaration by its descriptor
  @override
  MathDefinitionFunctionFreeformImplemented operator [](
      MathDefinitionFunctionFreeform key) {
    return definitions.firstWhere(
      (element) => element.isCompatible(key),
      orElse: () => throw UndefinedFunctionException(key.toString()),
    );
  }

  @override
  MathDefinitionFunctionFreeform? byName(String name) {
    try {
      return definitions.firstWhere(
        (element) => element.name == name,
      );
    } on StateError {
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
