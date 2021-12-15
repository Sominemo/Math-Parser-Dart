import 'package:math_parser/src/math_errors.dart';

import 'math_node.dart';
import 'parse_errors.dart';

/// Math Expression Parser Extension
///
/// Adds [fromString] method that lets you convert String to MathNode
extension MathNodeExpression on MathExpression {
  /// Parse MathNode from String
  ///
  /// Returns a single [MathNode]. Throws [MathException] if parsing fails.
  /// - Set [isMinusNegativeFunction] to `true` to interpret minus operator as a
  /// sum of two values, right of which will be negative: X - Y turns to X + (-Y)
  /// - Set [isImplicitMultiplication] to `false` to disable implicit
  /// multiplication
  ///
  /// Define custom variables with [variableNames] parameter. Don't forget to
  /// define the variable value in [MathExpression.calc] when calling it.
  ///
  /// Define custom functions using [customFunctions] argument. You can use either
  /// [MathCustomFunctions] class, which plainly declares the functions, or
  /// [MathCustomFunctionsImplemented], which also requires to implement the
  /// function. When you use [MathCustomFunctionsImplemented] during parsing,
  /// you don't need to redeclare the function in [MathExpression.calc].
  ///
  /// Parse priority:
  /// 1. Parentheses () []
  /// 2. Variables: e, pi (π) and custom ones.
  ///    `x` is being interpreted as a var by default, but you can override
  ///    this behavior with the variableNames parameter. You can rewrite e and pi
  ///    by defining it in variableNames and mentioning it during the calc call.
  ///    First character must be a letter or _, others - letters, digits, period,'
  ///    or underscore. Last symbol can't be a period. Letters may be latin or
  ///    Greek, both lower or capital case.
  ///    You can't use built-in function names like sin, cos, etc. Variable names
  ///    are case-sensitive.  Custom functions have the same requirements, except
  ///    they can override built-in functions.
  /// 3. Functions (case-sensitive):
  ///    - Custom functions
  ///    - sin, cos, tan (tg), cot (ctg)
  ///    - sqrt (√) (interpreted as power of 1/2), complex numbers not supported
  ///    - ln (base=E), lg (base=2), log\[base\](x)
  ///    - asin (arcsin), acos (arccos), atan (arctg), acot (arcctg)
  /// 4. Unary minus (-) at the beginning of a block
  /// 5. Power (x^y)
  /// 6. Implicit multiplication (two MathNodes put near without operator between)
  /// 7. Division (/) & Multiplication (*)
  /// 8. Subtraction (-) & Addition (+)
  static MathNode fromString(
    /// The expression to convert
    String expression, {

    /// Converts all X - Y to X + (-Y)
    bool isMinusNegativeFunction = false,

    /// Allows skipping the multiplication (*) operator
    bool isImplicitMultiplication = true,

    /// Expressions which should be marked as variables
    Set<String> variableNames = const {'x'},

    /// Expressions which should be marked as functions
    MathCustomFunctions customFunctions = const MathCustomFunctions({}),
  }) {
    for (final e in variableNames) {
      _checkVariableName(e);
    }

    for (final e in customFunctions.definitions) {
      _checkVariableName(e.name, isFunction: true);

      if (e.minArgumentsCount < 0 ||
          e.maxArgumentsCount < e.minArgumentsCount) {
        throw InvalidFunctionArgumentsDeclaration(e.toString());
      }

      if (variableNames.contains(e.name)) {
        throw DuplicateDeclarationException(e.toString());
      }
    }

    final variableNamesList = [
      ...customFunctions.definitions.map<String>((e) => e.name),
      ..._variableBuiltIns,
      ..._bracketFuncs,
      ...variableNames,
    ];

    variableNamesList.sort((a, b) => b.length.compareTo(a.length));

    return _parseMathString(
      expression,
      isMinusNegativeFunction: isMinusNegativeFunction,
      isImplicitMultiplication: isImplicitMultiplication,
      variableNames: variableNames,
      customFunctions: customFunctions,
      regexp: RegExp(
        '(' +
            variableNamesList.map((e) => RegExp.escape(e)).join('|') +
            (variableNamesList.isNotEmpty ? '|' : '') +
            r'(\d+(\.\d+)?)|\+|-|\^|/|\*)',
      ),
    );
  }

  /// Create a new MathExpression from String
  ///
  /// Compared to [fromString], this method also supports creating
  /// [MathExpression] entities, like [MathComparisonEquation],
  /// [MathComparisonGreater], [MathComparisonLess]. This means, this method
  /// supports =, < and > operators.
  static MathExpression fromStringExtended(
    /// The expression to convert
    String expression, {

    /// Converts all X - Y to X + (-Y)
    bool isMinusNegativeFunction = false,

    /// Allows skipping the multiplication (*) operator
    bool isImplicitMultiplication = true,

    /// Expressions which should be marked as variables
    Set<String> variableNames = const {'x'},

    /// Expressions which should be marked as functions
    MathCustomFunctionsImplemented customFunctions =
        const MathCustomFunctionsImplemented({}),
  }) {
    final nodes = <_MathExpressionPart>[];

    int start = 0;
    for (final match in RegExp('[=<>]').allMatches(expression, 0)) {
      var r = expression.substring(start, match.start);
      if (r.isNotEmpty) nodes.add(_MathExpressionPartString(r));
      r = match[0]!;
      if (r.isNotEmpty) {
        nodes.add(_MathExpressionPartString(r));
      }
      start = match.end;
    }

    final r = expression.substring(start);
    if (r.isNotEmpty) nodes.add(_MathExpressionPartString(r));

    for (var i = 0; i < nodes.length; i++) {
      final token = nodes[i];
      if (token is! _MathExpressionPartString ||
          !RegExp(r'^[=<>]$').hasMatch(token.str)) continue;

      if (i == 0 || i == nodes.length - 1) {
        throw MissingOperatorOperandException(token.str);
      }

      final left = nodes[i - 1];
      late final _MathExpressionPartParsed leftParsed;

      if (left is _MathExpressionPartString) {
        leftParsed = _MathExpressionPartParsed(
          fromString(
            left.str,
            isMinusNegativeFunction: isImplicitMultiplication,
            isImplicitMultiplication: isImplicitMultiplication,
            customFunctions: customFunctions,
            variableNames: variableNames,
          ),
        );
      } else if (left is _MathExpressionPartParsed) {
        leftParsed = left;
      } else {
        throw CantProcessExpressionException([left]);
      }

      final right = nodes[i + 1];
      late final _MathExpressionPartParsed rightParsed;

      if (right is _MathExpressionPartString) {
        rightParsed = _MathExpressionPartParsed(
          fromString(
            right.str,
            isMinusNegativeFunction: isImplicitMultiplication,
            isImplicitMultiplication: isImplicitMultiplication,
            customFunctions: customFunctions,
            variableNames: variableNames,
          ),
        );
      } else if (right is _MathExpressionPartParsed) {
        rightParsed = right;
      } else {
        throw CantProcessExpressionException([right]);
      }

      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);

      late final MathExpression result;

      if (token.str == '=') {
        result = MathComparisonEquation(leftParsed.node, rightParsed.node);
      } else if (token.str == '>') {
        result = MathComparisonGreater(leftParsed.node, rightParsed.node);
      } else if (token.str == '<') {
        result = MathComparisonLess(leftParsed.node, rightParsed.node);
      } else {
        throw UnknownOperationException(token.str);
      }

      nodes.insert(i - 1, _MathExpressionPartParsed(result));
      i -= 2;
    }

    if (nodes.length == 1) {
      if (nodes[0] is _MathExpressionPartString) {
        return fromString(
          nodes[0].str!,
          isMinusNegativeFunction: isImplicitMultiplication,
          isImplicitMultiplication: isImplicitMultiplication,
          customFunctions: customFunctions,
          variableNames: variableNames,
        );
      } else if (nodes[0] is _MathExpressionPartParsed) {
        return nodes[0].node!;
      }
    }

    throw CantProcessExpressionException(nodes);
  }

  /// Detect potential variable and function names
  ///
  /// This method analyzes the given string and assumes if there are
  /// any variable  and function names. This method doesn't give you a 100%
  /// guarantee if you use implicit multiplication, since there's no way to be
  /// sure if an unprocessed substring is a whole name or multiple variables being
  /// multiplied, or if that's a function getting multiplied with parentheses. Because of that, this method assumes you don't use implicit
  /// multiplication.
  ///
  /// Returns a list of strings of potential undeclared variable names.
  ///
  /// Use `hideBuiltIns` if you want to remove built-in variables like `e` and
  /// `pi` from result. Can be useful if you are going to prompt user to enter the
  /// values.
  static _MathExpressionDefinable getPotentialDefinable(
    String expression, {
    bool hideBuiltIns = false,
  }) {
    final funcs = getPotentialFunctionNames(expression, hideBuiltIns: false);

    final vars = RegExp(_variableNameBaseRegExp)
        .allMatches(expression)
        .map((element) => element.group(0)!)
        .where((element) {
      return !(_bracketFuncs.contains(element)) &&
          !(hideBuiltIns && _variableBuiltIns.contains(element)) &&
          !funcs.contains(element);
    }).toSet();

    return _MathExpressionDefinable(vars, funcs);
  }

  /// Detect potential function names
  ///
  /// This method analyzes the given string and assumes if there are
  /// any function names. This method doesn't give you a 100% guarantee
  /// if you use implicit multiplication, since there's no way to be sure if an
  /// unprocessed substring is a function name or a variable being multiplied.
  /// Because of that, this method assumes you don't use implicit
  /// multiplication.
  ///
  /// Returns a list of strings of potential undeclared function names.
  ///
  /// Use `hideBuiltIns` if you want to remove built-in functions like `cos`,
  /// `sin` and other from result. Can be useful if you are going to prompt user
  /// to define the functions.
  static Set<String> getPotentialFunctionNames(
    String expression, {
    bool hideBuiltIns = false,
  }) {
    return RegExp('(' + _variableNameBaseRegExp + ')([(])')
        .allMatches(expression)
        .map((element) => element.group(1)!)
        .where((element) {
      return (!hideBuiltIns || !_bracketFuncs.contains(element));
    }).toSet();
  }

  /// Built-in variables
  ///
  /// Math parser has some basic variables predefined, like `e` and `pi`. This
  /// field lets you get a lit of these variables. This list is used to filter out
  /// variables in [getPotentialVariableNames].
  static Set<String> get builtInVariables => _variableBuiltIns;

  /// Validate variable name
  ///
  /// Returns `true` if parser can interpret given token as a variable during
  /// parsing.
  static bool isVariableNameValid(String name, {bool isFunction = false}) {
    return _validateVariableName(name, isFunction: isFunction);
  }
}

const _variableBuiltIns = {'e', 'pi', 'π'};

const _bracketFuncs = {
  'sin',
  'cos',
  'tan',
  'tg',
  'cot',
  'ctg',
  'sqrt',
  '√',
  'ln',
  'lg',
  'log',
  'asin',
  'acos',
  'atan',
  'acot',
  'arcsin',
  'arccos',
  'arctg',
  'arcctg'
};

final _variableNameBaseRegExp =
    '[a-zA-Zα-ωΑ-Ω_]([a-zA-Zα-ωΑ-Ω0-9_.]+(?<=[a-zA-Zα-ωΑ-Ω0-9_]))?';

bool _validateVariableName(String name, {bool isFunction = false}) {
  return (RegExp('^$_variableNameBaseRegExp\$').hasMatch(name)) &&
      (isFunction || !_bracketFuncs.contains(name));
}

void _checkVariableName(String name, {bool isFunction = false}) {
  if (!_validateVariableName(name, isFunction: isFunction)) {
    if (isFunction) {
      throw InvalidFunctionNameException(name);
    } else {
      throw InvalidVariableNameException(name);
    }
  }
}

const _priority1 = {'^'};
const _priority2 = {'/', '*'};
const _priority3 = {'-', '+'};

class _BracketType {
  final String start;
  final String end;

  @override
  bool operator ==(other) {
    if (other is! _BracketType) return false;
    return start == other.start && end == other.end;
  }

  @override
  int get hashCode => start.hashCode * 13 + end.hashCode * 14;

  const _BracketType(
    this.start,
    this.end,
  );
}

const _bracketTypes = <_BracketType>[
  _BracketType('(', ')'),
  _BracketType('[', ']'),
];

MathNode _parseMathString(
  String s, {
  required bool isMinusNegativeFunction,
  required bool isImplicitMultiplication,
  required Set<String> variableNames,
  required MathCustomFunctions customFunctions,
  required RegExp regexp,
}) {
  final List<_UnprocessedMathString> tempNodes = [];

  // Looking for brackets on top level
  int openedNodePosition = 0;
  final List<_BracketType> bracketList = [];

  character:
  for (int pos = 0; pos < s.length; pos++) {
    final String char = s[pos];

    for (final currentBracketType in _bracketTypes) {
      if (char == currentBracketType.start) {
        if (pos != 0 && bracketList.isEmpty) {
          tempNodes.add(_UnprocessedMathString(
            s.substring(
              openedNodePosition,
              pos,
            ),
          ));
        }

        bracketList.add(currentBracketType);

        if (bracketList.length > 1) {
          continue character;
        }

        openedNodePosition = pos + 1;
      } else if (char == currentBracketType.end) {
        if (bracketList.isEmpty || bracketList.last != currentBracketType) {
          throw UnexpectedClosingBracketException(currentBracketType.end, pos);
        }

        bracketList.removeLast();

        if (bracketList.isNotEmpty) {
          continue character;
        }

        tempNodes.add(
          _UnprocessedBrackets(s.substring(openedNodePosition, pos)),
        );
        openedNodePosition = pos + 1;
      }
    }
  }

  if (bracketList.isNotEmpty) {
    throw BracketsNotClosedException(
      bracketList.last.start,
      openedNodePosition,
      s.length,
    );
  }

  if (openedNodePosition != s.length) {
    tempNodes.add(_UnprocessedMathString(
      s.substring(
        openedNodePosition,
        s.length,
      ),
    ));
  }

  final nodes = <_MathNodePart>[];

  // Splitting string to tokens
  for (final item in tempNodes) {
    if (item is! _UnprocessedBrackets) {
      final str = item.contents.replaceAll(' ', '');

      int start = 0;
      for (final match in regexp.allMatches(str, 0)) {
        var r = str.substring(start, match.start);
        if (r.isNotEmpty) nodes.add(_MathNodePartString(r));
        r = match[0]!;
        if (r.isNotEmpty) {
          if (match[2] != null) {
            nodes.add(_MathNodePartParsed(MathValue(num.parse(r))));
          } else {
            nodes.add(_MathNodePartString(r));
          }
        }
        start = match.end;
      }

      final r = str.substring(start);
      if (r.isNotEmpty) nodes.add(_MathNodePartString(r));
    } else {
      if (item.contents == '') continue;

      final sp = item.contents.split(',');
      final List<MathNode> n = [];

      for (final r in sp) {
        if (r.trim().isEmpty) continue;

        n.add(_parseMathString(
          r,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }

      if (n.length == 1) {
        nodes.add(_MathNodePartParsed(n[0]));
      } else {
        nodes.add(_MathNodePartParsedList(n));
      }
    }
  }

  // Looking for variables
  for (int i = nodes.length - 1; i >= 0; i--) {
    final item = nodes[i];

    if (item is _MathNodePartString && variableNames.contains(item.str)) {
      nodes.removeAt(i);
      nodes.insert(i, _MathNodePartParsed(MathVariable(item.str)));
    } else if (item.str == 'e') {
      const el = MathFunctionE();

      nodes.removeAt(i);
      nodes.insert(i, _MathNodePartParsed(el));
    } else if (item.str == 'pi' || item.str == 'π') {
      const el = MathValuePi();

      nodes.removeAt(i);
      nodes.insert(i, _MathNodePartParsed(el));
    }
  }

  // Looking for functions
  for (int i = 0; i < nodes.length; i++) {
    final item = nodes[i];

    MathDefinitionFunctionFreeform? cf;
    final doesBuiltInContain = _bracketFuncs.contains(item.str);

    if (item is _MathNodePartString) {
      cf = customFunctions.byName(item.str);
    }

    _MathNodePartParsedList? op;

    if (i + 1 != nodes.length) {
      final te = nodes[i + 1];

      if (te is _MathNodePartParsed) {
        op = _MathNodePartParsedList([te.node]);
      } else if (te is _MathNodePartParsedList) {
        op = te;
      }
    }

    if (cf != null) {
      if ((op == null || op.nodeList.isEmpty) && cf.minArgumentsCount > 0 ||
          op != null &&
              (op.nodeList.length < cf.minArgumentsCount ||
                  op.nodeList.length > cf.maxArgumentsCount)) {
        throw OutOfRangeFunctionArgumentListException(cf.toString());
      }

      final el =
          _MathNodePartParsed(MathFunctionFreeform(cf, op?.nodeList ?? []));

      nodes.removeAt(i);
      if (op != null) nodes.removeAt(i);
      nodes.insert(i, el);
      continue;
    }

    if (doesBuiltInContain) {
      if (op == null || op is! _MathNodePartParsedList) {
        throw OutOfRangeFunctionArgumentListException(cf.toString());
      }

      MathNode? el;

      if (item.str == 'log') {
        if (op.nodeList.length == 2) {
          el = MathFunctionLog(op.nodeList[1], x2: op.nodeList[0]);
        } else if (op.nodeList.length == 1) {
          el = MathFunctionLog(op.nodeList[0], x2: const MathValue(10));
        } else {
          throw OutOfRangeFunctionArgumentListException(item.toString());
        }
      } else {
        if (op.nodeList.length != 1) {
          throw OutOfRangeFunctionArgumentListException(item.toString());
        }

        switch (item.str) {
          case 'sin':
            el = MathFunctionSin(op.nodeList[0]);
            break;
          case 'cos':
            el = MathFunctionCos(op.nodeList[0]);
            break;
          case 'tan':
          case 'tg':
            el = MathFunctionTan(op.nodeList[0]);
            break;
          case 'cot':
          case 'ctg':
            el = MathFunctionCot(op.nodeList[0]);
            break;
          case 'sqrt':
          case '√':
            el = MathOperatorPower(op.nodeList[0], const MathValue(1 / 2));
            break;
          case 'ln':
            el = MathFunctionLn(op.nodeList[0]);
            break;
          case 'lg':
            el = MathFunctionLog(op.nodeList[0], x2: const MathValue(2));
            break;
          case 'asin':
          case 'arcsin':
            el = MathFunctionAsin(op.nodeList[0]);
            break;
          case 'acos':
          case 'arccos':
            el = MathFunctionAcos(op.nodeList[0]);
            break;
          case 'atan':
          case 'arctg':
            el = MathFunctionAtan(op.nodeList[0]);
            break;
          case 'acot':
          case 'arcctg':
            el = MathFunctionAcot(op.nodeList[0]);
            break;
          default:
            throw UnknownOperationException(item.toString());
        }
      }

      nodes.removeAt(i);
      nodes.removeAt(i);
      nodes.insert(i, _MathNodePartParsed(el));
    }
  }

  // Looking for unary minus
  for (int i = 0; i < nodes.length; i++) {
    final item = nodes[i];
    if (item is _MathNodePartString &&
        item.str == '-' &&
        i != nodes.length - 1 &&
        (i == 0 || nodes[i - 1] is! _MathNodePartParsed)) {
      var right = nodes[i + 1];
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }

      if (right is! _MathNodePartParsed) {
        throw UnknownOperationException(right.toString());
      }

      final el = MathFunctionNegative(right.node);

      nodes.removeAt(i);
      nodes.removeAt(i);
      nodes.insert(i, _MathNodePartParsed(el));
    }
  }

  // Looking for power (^)
  for (int i = 0; i < nodes.length; i++) {
    final item = nodes[i];

    if (_priority1.contains(item.str)) {
      if (i + 1 == nodes.length || i == 0) {
        throw MissingOperatorOperandException(item.toString());
      }

      var left = nodes[i - 1];
      var right = nodes[i + 1];

      if (left is _MathNodePartString) {
        left = _MathNodePartParsed(_parseMathString(
          left.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }

      if (left is! _MathNodePartParsed) {
        throw UnknownOperationException(left.toString());
      }
      if (right is! _MathNodePartParsed) {
        throw UnknownOperationException(right.toString());
      }

      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      MathNode? el;

      switch (item.str) {
        case '^':
          el = (left.node is MathFunctionE
              ? MathFunctionE(x1: right.node)
              : MathOperatorPower(left.node, right.node));
          break;
        default:
          throw UnknownOperationException(item.toString());
      }

      nodes.insert(i - 1, _MathNodePartParsed(el));
      i--;
    }
  }

  // Looking for implicit multiplication
  if (isImplicitMultiplication) {
    for (int i = 0; i < nodes.length; i++) {
      final item = nodes[i];

      if (item is _MathNodePartParsed) {
        var el = item.node;
        bool removeBefore = false, removeAfter = false;

        if (i != 0) {
          final left = nodes[i - 1];
          if (left is _MathNodePartParsed) {
            el = MathOperatorMultiplication(left.node, el);
            removeBefore = true;
          }
        }

        if (i != nodes.length - 1) {
          final right = nodes[i + 1];
          if (right is _MathNodePartParsed) {
            el = MathOperatorMultiplication(el, right.node);
            removeAfter = true;
          }
        }

        nodes.removeAt(i);
        nodes.insert(i, _MathNodePartParsed(el));

        if (removeBefore) nodes.removeAt(i - 1);
        if (removeAfter) nodes.removeAt(i + 1);
      }
    }
  }

  // Looking for / and *
  for (int i = 0; i < nodes.length; i++) {
    final item = nodes[i];

    if (_priority2.contains(item.str)) {
      if (i + 1 == nodes.length || i == 0) {
        throw MissingOperatorOperandException(item.toString());
      }

      var left = nodes[i - 1];
      var right = nodes[i + 1];

      if (left is _MathNodePartString) {
        left = _MathNodePartParsed(_parseMathString(
          left.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }

      if (left is! _MathNodePartParsed) {
        throw UnknownOperationException(left.toString());
      }
      if (right is! _MathNodePartParsed) {
        throw UnknownOperationException(right.toString());
      }

      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      MathNode? el;

      switch (item.str) {
        case '/':
          el = MathOperatorDivision(left.node, right.node);
          break;
        case '*':
          el = MathOperatorMultiplication(left.node, right.node);
          break;
        default:
          throw UnknownOperationException(item.toString());
      }

      nodes.insert(i - 1, _MathNodePartParsed(el));
      i--;
    }
  }

  // Looking for plus and minus
  for (int i = 0; i < nodes.length; i++) {
    final item = nodes[i];

    if (_priority3.contains(item.str)) {
      if (i + 1 == nodes.length || i == 0) {
        throw MissingOperatorOperandException(item.toString());
      }

      var left = nodes[i - 1];
      var right = nodes[i + 1];

      if (left is _MathNodePartString) {
        left = _MathNodePartParsed(_parseMathString(
          left.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
          variableNames: variableNames,
          customFunctions: customFunctions,
          regexp: regexp,
        ));
      }

      if (left is! _MathNodePartParsed) {
        throw UnknownOperationException(left.toString());
      }
      if (right is! _MathNodePartParsed) {
        throw UnknownOperationException(right.toString());
      }

      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      nodes.removeAt(i - 1);
      MathNode? el;

      switch (item.str) {
        case '-':
          if (isMinusNegativeFunction) {
            el = MathOperatorAddition(
              left.node,
              MathFunctionNegative(right.node),
            );
          } else {
            el = MathOperatorSubtraction(left.node, right.node);
          }
          break;
        case '+':
          el = MathOperatorAddition(left.node, right.node);
          break;
        default:
          throw UnknownOperationException(item.toString());
      }

      nodes.insert(i - 1, _MathNodePartParsed(el));
      i--;
    }
  }

  // If some nodes were left unprocessed - error
  if (nodes.length != 1 || nodes[0] is! _MathNodePartParsed) {
    throw CantProcessExpressionException(nodes);
  }

  return (nodes[0] as _MathNodePartParsed).node;
}

class _UnprocessedMathString {
  final String contents;
  const _UnprocessedMathString(this.contents);

  @override
  String toString() {
    return 'MATH[$contents]';
  }
}

class _UnprocessedBrackets implements _UnprocessedMathString {
  @override
  final String contents;

  const _UnprocessedBrackets(this.contents);

  @override
  String toString() {
    return 'BRACKETS[$contents]';
  }
}

abstract class _MathNodePart {
  final String? str;
  final MathNode? node;
  final List<MathNode>? nodeList;

  _MathNodePart(this.str, this.node, this.nodeList);
}

class _MathNodePartString implements _MathNodePart {
  @override
  final String str;
  @override
  final MathNode? node = null;
  @override
  final List<MathNode>? nodeList = null;

  const _MathNodePartString(this.str);

  @override
  String toString() => str.toString();
}

class _MathNodePartParsed implements _MathNodePart {
  @override
  final String? str = null;
  @override
  final MathNode node;
  @override
  final List<MathNode>? nodeList = null;

  const _MathNodePartParsed(this.node);

  @override
  String toString() => node.toString();
}

class _MathNodePartParsedList implements _MathNodePart {
  @override
  final String? str = null;
  @override
  final MathNode? node = null;
  @override
  final List<MathNode> nodeList;

  const _MathNodePartParsedList(this.nodeList);

  @override
  String toString() => 'ARG_LIST[${nodeList.toString()}]';
}

abstract class _MathExpressionPart {
  final String? str;
  final MathExpression? node;

  _MathExpressionPart(this.str, this.node);
}

class _MathExpressionPartString implements _MathExpressionPart {
  @override
  final String str;
  @override
  final MathExpression? node = null;

  const _MathExpressionPartString(this.str);

  @override
  String toString() => str.toString();
}

class _MathExpressionPartParsed implements _MathExpressionPart {
  @override
  final String? str = null;
  @override
  final MathExpression node;

  const _MathExpressionPartParsed(this.node);

  @override
  String toString() => node.toString();
}

class _MathExpressionDefinable {
  final Set<String> variables;
  final Set<String> functions;

  const _MathExpressionDefinable(
    this.variables,
    this.functions,
  );

  @override
  String toString() {
    return 'DEFINABLE[vars: $variables; funcs: $functions]';
  }
}
