Process math expressions, convert them to machine-readable
form, and calculate them.

## Features

### Math Tree

The library provides a family of `MathNode` classes, most of
them have subnodes that are being calculated recursively.

There are such types of MathNode:

- `MathFunction` (and `MathFunctionWithTwoArguments` subclass)
- `MathValue`
- `MathOperator`

All the child classes names begin with the family they belong to.

### Evaluation

You can evaluate a MathNode and its subnodes recursively by calling
`MathNode.calc(num x)` and passing custom `x` variable value.

Example: Calculate `x + 3`, where `x = 5`.

```dart
MathOperatorAddition(
    MathFunctionX(),
    const MathValue(3),
).calc(5);
```

### Parsing String to MathNode

The library can parse general mathematical expressions strings
and return them as a machine-readable `MathNode` using
`MathNodeExpression.fromString` method.

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

## Numerical methods for Definite Integrals

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
