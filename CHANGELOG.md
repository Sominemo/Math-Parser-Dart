# 1.5.1

-   Increased upper SDK constraint to declare support for Dart 3
-   Documentation fixes

# 1.5.0

## Breaking changes

-   Now the `'` symbol is allowed for variable and function names so you can have variables like `y'`.

## Equations

-   Implemented `>=` and `<=`.

# 1.4.0

## Custom Functions

-   Define custom functions and redefine built-in functions when parsing
    an expression. See docs and example.
-   Use `MathNodeExpression.getPotentialFunctionNames()` to detect potentially
    used functions in a string.
-   Use period in the middle of custom variable and function names.
-   Under-hood, functions now support multiple comma separated arguments, so
    you can supply multiple arguments to your custom function.
-   Detect custom functions im math tree using
    `MathExpression.getUsedFreeformFunctions()`.

## Breaking Changes

-   `MissingFunctionArgumentListException` renamed to
    `OutOfRangeFunctionArgumentListException`
-   `MathNodeExpression.fromString()` may throw other errors besides
    `MathException`
-   `MathNodeExpression.getPotentialVariableNames()` is replaced by
    `MathNodeExpression.getPotentialDefinable()`
-   Instead of `log[base](arg)`, you should pass `log(base, arg)` syntax now
-   Period is an allowed character in the middle of a variable name now

## Misc.

-   `UnexpectedClosingBracketException` and `BracketsNotClosedException` can
    now tell where the problem probably happened.
-   New MathParseException's `InvalidFunctionNameException`,
    `DuplicateDeclarationException`, `InvalidFunctionArgumentsDeclaration`.

# 1.3.1

-   Variable validation fix

# 1.3.0

## Math Tree

-   Important change: `MathNode` is now a class of `MathExpression` interface.
    Compared to MathNode, MathExpression may return null in `calc()` method.
-   New: `getUsedVariables()` method for `MathExpression` and `MathNode`.
    This method goes down the math tree to find any uses of `MathVariable`
    and returns names of all variables.
-   New: `MathExpression` object family - `MathComparison`:
    -   `MathComparisonEquation` (=)
    -   `MathComparisonGreater` (>)
    -   `MathComparisonLess` (<)

## Parsing

-   New: `MathNodeExpression.fromStringExtended()` method allows you to
    interpret equations and comparisons. Compared to `fromString`,
    it returns `MathExpression` instead of `MathNode`, since comparisons
    can't guarantee result.
-   New: `MathNodeExpression.getPotentialVariableNames()` analyzes given
    math expression string for possible use of variables. Refer to
    documentation for rough edges before using it.
-   New: `MathNodeExpression.builtInVariables` gives a list of built-in
    predefined variable names.
-   New: `MathNodeExpression.isVariableNameValid()` lets you check if
    the parser can work with a given name.

## Misc.

-   Changed input parameters type for `CantProcessExpressionException`.
-   Small documentation fixes.

# 1.2.0

-   Fix README.
-   Moved integrating features to a separate package library
    `math_parser_integrate`.

# 1.1.0

-   Custom variables support.
-   `MathFunctionX`deprecated.
-   `MathVariable` introduced.
-   You need to pass an instance of `MathVariableValues` instead of a num
    to the `calc()` function now.

# 1.0.0

-   Initial version.
