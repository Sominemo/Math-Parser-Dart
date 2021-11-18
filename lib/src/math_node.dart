import 'dart:math' as math;

/// Basic math expression unit
///
/// Defines the [calc] method for every child to implement.
abstract class MathNode {
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
  num calc(
    num x,
  );

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
}

/// Constant value
///
/// The given value never changes, is guaranteed to be numerical and constant
class MathValue extends MathNode {
  /// The value
  final num value;

  @override
  num calc(num x) => value;

  /// Creates a new constant value
  const MathValue(this.value);

  @override
  String toString() => 'VALUE($value)';
}

/// Addition operator (+)
///
/// Both operands are addends. This expression evaluates to the sum of left and
/// right operands.
class MathOperatorAddition extends MathOperator {
  @override
  num calc(num x) => left.calc(x) + right.calc(x);

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
  num calc(num x) => left.calc(x) - right.calc(x);

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
  num calc(num x) => left.calc(x) * right.calc(x);

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
  num calc(num x) => left.calc(x) / right.calc(x);

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
  num calc(num x) => -x1.calc(x);

  /// Creates a negative value
  const MathFunctionNegative(MathNode x) : super(x);

  @override
  String toString() => '(-$x1)';
}

/// The X variable
///
/// This value is being passed from the [MathNode.calc] method to every subnode.
///
/// The function is being replaced by the passed value during calculation.
class MathFunctionX extends MathFunction {
  @override
  num calc(num x) => x;

  /// Creates the X value
  const MathFunctionX() : super(const MathValue(1));

  @override
  String toString() => '[x]';
}

/// The Exponent in power constant
///
/// Value that evaluates to the natural exponent in given number. The power
/// of 1 is the default value.
class MathFunctionE extends MathFunction {
  @override
  num calc(num x) => math.exp(x1.calc(x));

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
  num calc(num x) => math.pow(left.calc(x), right.calc(x));

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
  num calc(num x) => math.sin(x1.calc(x));

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
  num calc(num x) => math.cos(x1.calc(x));

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
  num calc(num x) => math.tan(x1.calc(x));

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
  num calc(num x) => 1 / math.tan(x1.calc(x));

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
  num calc(num x) => math.asin(x1.calc(x));

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
  num calc(num x) => math.acos(x1.calc(x));

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
  num calc(num x) => math.atan(x1.calc(x));

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
  num calc(num x) => math.atan(1 / x1.calc(x));

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
  num calc(num x) => math.log(x1.calc(x)) / math.log(x2.calc(x));

  /// Creates the log function
  const MathFunctionLog(MathNode x1, {MathNode x2 = const MathValue(10)})
      : super(x1, x2);

  @override
  String toString() => '[LOG($x1, $x2)]';
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
