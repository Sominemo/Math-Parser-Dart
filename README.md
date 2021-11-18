# Math Parser for Dart

Process math expressions, convert them to machine-readable
form, and calculate them.

## Math Tree

The library provides a family of `MathNode` classes, most of
them have subnodes that are being calculated recursively.

There are such types of MathNode:

- `MathFunction` (and `MathFunctionWithTwoArguments` subclass)
- `MathValue`
- `MathOperator`

All the child classes names begin with the family they belong to.

## Evaluation

You can evaluate a MathNode and its subnodes recursively by calling
`MathNode.calc(num x)` and passing custom `x` variable value.

Example: Calculate `x + 3`, where `x = 5`.

```dart
MathOperatorAddition(
    MathFunctionX(),
    const MathValue(3),
).calc(5);
```

## Parsing String to MathNode

The library can parse general mathematical expressions strings
and return them as a machine-readable `MathNode` using
`MathNodeExpression.fromString` method.

- Set [isMinusNegativeFunction] to `true` to interpret minus operator as a
  sum of two values, right of which will be negative: X - Y turns to X + (-Y)
- Set [isImplicitMultiplication] to `false` to disable implicit multiplication

### Parse priority:

1. Parentheses () []
2. Variables: x, e, pi (π)
3. Functions:
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
  });
```

Example for parsing a string and evaluating it with `x = 20`:

```dart
final expression = MathNodeExpression.fromString(
    '((2x)^(e^3 + 4)',
);
print(expression.calc(20));

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
