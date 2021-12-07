# 1.3.1
- Variable validation fix

# 1.3.0

## Math Tree
- Important change: `MathNode` is now a class of `MathExpression` interface. 
  Compared to MathNode, MathExpression may return null in `calc()` method.
- New: `getUsedVariables()` method for `MathExpression` and `MathNode`.
  This method goes down the math tree to find any uses of `MathVariable`
  and returns names of all variables.
- New: `MathExpression` object family - `MathComparison`:
    - `MathComparisonEquation` (=)
    - `MathComparisonGreater` (>)
    - `MathComparisonLess` (<)

## Parsing
- New: `MathNodeExpression.fromStringExtended()` method allows you to 
  interpret equations and comparisons. Compared to `fromString`, 
  it returns `MathExpression` instead of `MathNode`, since comparisons
  can't guarantee result.
- New: `MathNodeExpression.getPotentialVariableNames()` analyzes given
  math expression string for possible use of variables. Refer to 
  documentation for rough edges before using it.
- New: `MathNodeExpression.builtInVariables` gives a list of built-in
  predefined variable names.
- New: `MathNodeExpression.isVariableNameValid()` lets you check if 
  the parser can work with a given name.

## Misc.
- Changed input parameters type for `CantProcessExpressionException`.
- Small documentation fixes.

# 1.2.0

- Fix README.
- Moved integrating features to a separate package library 
  `math_parser_integrate`.


# 1.1.0

- Custom variables support.
- `MathFunctionX`deprecated.
- `MathVariable` introduced.
- You need to pass an instance of `MathVariableValues` instead of a num 
  to the `calc()` function now.


# 1.0.0

- Initial version.
