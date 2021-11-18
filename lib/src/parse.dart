import 'math_node.dart';
import 'parse_errors.dart';

/// Math Expression Parser Extension
///
/// Adds [fromString] method that lets you convert String to MathNode
extension MathNodeExpression on MathNode {
  /// Parse MathNode from String
  ///
  /// Returns a single [MathNode]. Throws [MathException] if parsing fails.
  /// - Set [isMinusNegativeFunction] to `true` to interpret minus operator as a
  /// sum of two values, right of which will be negative: X - Y turns to X + (-Y)
  /// - Set [isImplicitMultiplication] to `false` to disable implicit multiplication
  ///
  /// Parse priority:
  /// 1. Parentheses () []
  /// 2. Variables: x, e, pi (π)
  /// 3. Functions:
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
  }) {
    try {
      return _parseMathString(
        expression,
        isMinusNegativeFunction: isMinusNegativeFunction,
        isImplicitMultiplication: isImplicitMultiplication,
      );
    } on MathException {
      rethrow;
    } catch (e) {
      throw ParsingFailedException(e);
    }
  }
}

// Tokenizer regex
final _regex = RegExp(
  r'((\d+(\.\d+)?)|\+|-|\^|/|\*|x|e|asin|acos|atan|acot|'
  r'arcsin|arccos|arctg|arcctg|cos|tan|tg|cot|ctg|sqrt|√|ln|log|lg|pi|π)',
);

MathNode _parseMathString(
  String s, {
  required bool isMinusNegativeFunction,
  required bool isImplicitMultiplication,
}) {
  final List<_UnprocessedMathString> tempNodes = [];

  // Looking for brackets
  int expectedClosingBracketsNumber = 0, openedNodePosition = 0;
  bool squareBrackets = false;

  for (int pos = 0; pos < s.length; pos++) {
    final String char = s[pos];

    if (char == '(') {
      if (openedNodePosition != pos && expectedClosingBracketsNumber == 0) {
        tempNodes.add(_UnprocessedMathString(
          s.substring(openedNodePosition, pos),
        ));

        openedNodePosition = pos;
      }

      expectedClosingBracketsNumber++;
    } else if (char == ')' && !squareBrackets) {
      if (expectedClosingBracketsNumber > 1) {
        expectedClosingBracketsNumber--;
      } else if (expectedClosingBracketsNumber <= 0) {
        throw const UnexpectedClosingBracketException(')');
      } else {
        expectedClosingBracketsNumber--;
        tempNodes.add(_UnprocessedBrackets(
          s.substring(openedNodePosition + 1, pos),
        ));
        openedNodePosition = pos + 1;
      }
    } else if (char == '[') {
      if (openedNodePosition != pos && expectedClosingBracketsNumber == 0) {
        tempNodes.add(_UnprocessedMathString(
          s.substring(openedNodePosition, pos),
        ));

        openedNodePosition = pos;
        squareBrackets = true;
        expectedClosingBracketsNumber++;
      }
    } else if (char == ']' && squareBrackets) {
      if (expectedClosingBracketsNumber > 1) {
        expectedClosingBracketsNumber--;
      } else if (expectedClosingBracketsNumber <= 0) {
        throw const UnexpectedClosingBracketException(']');
      } else {
        expectedClosingBracketsNumber--;
        tempNodes.add(_UnprocessedSquareBrackets(
          s.substring(openedNodePosition + 1, pos),
        ));
        squareBrackets = false;
        openedNodePosition = pos + 1;
      }
    } else if (pos == s.length - 1) {
      if (expectedClosingBracketsNumber > 0) {
        if (squareBrackets) {
          throw const BracketsNotClosedException('[');
        } else {
          throw const BracketsNotClosedException('(');
        }
      } else {
        tempNodes.add(_UnprocessedMathString(
          s.substring(openedNodePosition, pos + 1),
        ));
      }
    }
  }

  final nodes = <_MathNodePart>[];

  // Splitting string to tokens
  for (final item in tempNodes) {
    if (item is! _UnprocessedBrackets) {
      final str = item.contents.replaceAll(' ', '').toLowerCase();

      int start = 0;
      for (final match in _regex.allMatches(str, 0)) {
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
      nodes.add(_MathNodePartParsed(_parseMathString(
        item.contents,
        isMinusNegativeFunction: isMinusNegativeFunction,
        isImplicitMultiplication: isImplicitMultiplication,
      )));
    }
  }

  const bracketFuncs = [
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
  ];

  const priority1 = ['^'];
  const priority2 = ['/', '*'];
  const priority3 = ['-', '+'];

  // Looking for variables
  for (int i = nodes.length - 1; i >= 0; i--) {
    final item = nodes[i];

    if (item.str == 'e') {
      const el = MathFunctionE();

      nodes.removeAt(i);
      nodes.insert(i, _MathNodePartParsed(el));
    } else if (item.str == 'x') {
      const el = MathFunctionX();

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

    if (bracketFuncs.contains(item.str)) {
      if (i + 1 == nodes.length) {
        throw MissingFunctionArgumentListException(item.toString());
      }
      _MathNodePartParsed op;
      final te = nodes[i + 1];
      if (te is _MathNodePartString) {
        op = _MathNodePartParsed(_parseMathString(
          te.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
        ));
      } else if (te is _MathNodePartParsed) {
        op = te;
      } else {
        throw UnknownOperationException(item.toString());
      }

      MathNode? el;

      switch (item.str) {
        case 'sin':
          el = MathFunctionSin(op.node);
          break;
        case 'cos':
          el = MathFunctionCos(op.node);
          break;
        case 'tan':
        case 'tg':
          el = MathFunctionTan(op.node);
          break;
        case 'cot':
        case 'ctg':
          el = MathFunctionCot(op.node);
          break;
        case 'sqrt':
        case '√':
          el = MathOperatorPower(op.node, const MathValue(1 / 2));
          break;
        case 'ln':
          el = MathFunctionLn(op.node);
          break;
        case 'lg':
          el = MathFunctionLog(op.node, x2: const MathValue(2));
          break;
        case 'log':
          final n = nodes[i + 2];
          if (n is! _MathNodePartParsed) {
            throw UnknownOperationException(n.toString());
          }
          el = MathFunctionLog(n.node, x2: op.node);
          nodes.removeAt(i);
          break;
        case 'asin':
        case 'arcsin':
          el = MathFunctionAsin(op.node);
          break;
        case 'acos':
        case 'arccos':
          el = MathFunctionAcos(op.node);
          break;
        case 'atan':
        case 'arctg':
          el = MathFunctionAtan(op.node);
          break;
        case 'acot':
        case 'arcctg':
          el = MathFunctionAcot(op.node);
          break;
        default:
          throw UnknownOperationException(item.toString());
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

    if (priority1.contains(item.str)) {
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
        ));
      }
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
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

    if (priority2.contains(item.str)) {
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
        ));
      }
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
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

    if (priority3.contains(item.str)) {
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
        ));
      }
      if (right is _MathNodePartString) {
        right = _MathNodePartParsed(_parseMathString(
          right.str,
          isMinusNegativeFunction: isMinusNegativeFunction,
          isImplicitMultiplication: isImplicitMultiplication,
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
    throw CantProcessExpressionException(nodes.join(', '));
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

class _UnprocessedSquareBrackets implements _UnprocessedBrackets {
  @override
  final String contents;

  const _UnprocessedSquareBrackets(this.contents);

  @override
  String toString() {
    return 'SQBRACKETS[$contents]';
  }
}

abstract class _MathNodePart {
  final String? str;
  final MathNode? node;

  _MathNodePart(this.str, this.node);
}

class _MathNodePartString implements _MathNodePart {
  @override
  final String str;
  @override
  final MathNode? node = null;

  const _MathNodePartString(this.str);

  @override
  String toString() => str.toString();
}

class _MathNodePartParsed implements _MathNodePart {
  @override
  final String? str = null;
  @override
  final MathNode node;

  const _MathNodePartParsed(this.node);

  @override
  String toString() => node.toString();
}
