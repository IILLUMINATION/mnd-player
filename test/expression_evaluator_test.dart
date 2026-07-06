import 'package:flutter_test/flutter_test.dart';
import 'package:mnd_player/services/expression_evaluator.dart';

void main() {
  late ExpressionEvaluatorService evaluator;

  setUp(() {
    evaluator = ExpressionEvaluatorService();
  });

  group('ExpressionEvaluatorService — basic arithmetic', () {
    test('evaluates simple addition', () {
      expect(evaluator.evaluate('2 + 2', {}), 4);
    });

    test('evaluates multiplication', () {
      expect(evaluator.evaluate('3 * 3', {}), 9);
    });

    test('evaluates division', () {
      expect(evaluator.evaluate('10 / 2', {}), 5);
    });

    test('evaluates subtraction with negative result', () {
      expect(evaluator.evaluate('3 - 7', {}), -4);
    });

    test('evaluates parentheses expression', () {
      expect(evaluator.evaluate('(2 + 3) * 4', {}), 20);
    });

    test('handles non-string input (passes through)', () {
      expect(evaluator.evaluate(42, {}), 42);
    });

    test('handles double input', () {
      expect(evaluator.evaluate(3.14, {}), 3.14);
    });
  });

  group('ExpressionEvaluatorService — variables', () {
    test('resolves simple variable', () {
      final vars = {'hp': 100};
      expect(evaluator.evaluate('hp', vars), 100);
    });

    test('resolves variable in braces', () {
      final vars = {'hp': 100};
      expect(evaluator.evaluate('{hp}', vars), 100);
    });

    test('resolves variable in math expression', () {
      final vars = {'hp': 100, 'damage': 25};
      expect(evaluator.evaluate('{hp} - {damage}', vars), 75);
    });

    test('resolves russian variable name', () {
      final vars = {'здоровье': 50};
      expect(evaluator.evaluate('здоровье', vars), 50);
    });

    test('returns null for undefined variable', () {
      expect(evaluator.evaluate('undefinedVar', {}), null);
    });

    test('resolves boolean variable', () {
      final vars = {'completed': true};
      expect(evaluator.evaluate('completed', vars), true);
    });

    test('resolves string variable in braces (quoted)', () {
      final vars = {'name': 'Hero'};
      expect(evaluator.evaluate("{'Result: '} + {name}", vars), null);
    });
  });

  group('ExpressionEvaluatorService — built-in functions', () {
    test('abs() — absolute value', () {
      expect(evaluator.evaluate('abs(-5)', {}), 5);
      expect(evaluator.evaluate('abs(5)', {}), 5);
    });

    test('round() — rounding', () {
      expect(evaluator.evaluate('round(3.7)', {}), 4);
      expect(evaluator.evaluate('round(3.2)', {}), 3);
    });

    test('round() with digits', () {
      expect(evaluator.evaluate('round(3.14159, 2)', {}), 3.14);
    });

    test('ceil() and floor()', () {
      expect(evaluator.evaluate('ceil(3.1)', {}), 4);
      expect(evaluator.evaluate('floor(3.9)', {}), 3);
    });

    test('sqrt() — square root', () {
      expect(evaluator.evaluate('sqrt(16)', {}), 4);
      expect(evaluator.evaluate('sqrt(9)', {}), 3);
    });

    test('pow() — power', () {
      expect(evaluator.evaluate('pow(2, 3)', {}), 8);
      expect(evaluator.evaluate('pow(5, 2)', {}), 25);
    });

    test('sin(), cos(), tan()', () {
      expect(evaluator.evaluate('sin(0)', {}), 0);
      expect(evaluator.evaluate('cos(0)', {}), 1);
      expect(evaluator.evaluate('tan(0)', {}), 0);
    });

    test('min() and max()', () {
      expect(evaluator.evaluate('min(3, 5)', {}), 3);
      expect(evaluator.evaluate('max(3, 5)', {}), 5);
    });

    test('random() — returns value in range', () {
      for (var i = 0; i < 20; i++) {
        final result = evaluator.evaluate('random(1, 6)', {});
        expect(result, greaterThanOrEqualTo(1));
        expect(result, lessThanOrEqualTo(6));
      }
    });

    test('random() with int args returns int', () {
      for (var i = 0; i < 10; i++) {
        final result = evaluator.evaluate('random(1, 10)', {});
        expect(result, isA<int>());
      }
    });

    test('contains() and length()', () {
      expect(evaluator.evaluate("contains('hello', 'll')", {}), true);
      expect(evaluator.evaluate("contains('hello', 'xx')", {}), false);
      expect(evaluator.evaluate("length('abc')", {}), 3);
    });
  });

  group('ExpressionEvaluatorService — literals', () {
    test('null literal', () {
      expect(evaluator.evaluate('null', {}), null);
    });

    test('true/false literals', () {
      expect(evaluator.evaluate('true', {}), true);
      expect(evaluator.evaluate('false', {}), false);
    });

    test('empty string returns null', () {
      expect(evaluator.evaluate('', {}), null);
    });

    test('whitespace string returns null', () {
      expect(evaluator.evaluate('   ', {}), null);
    });

    test('numeric literal', () {
      expect(evaluator.evaluate('42', {}), 42);
    });
  });

  group('ExpressionEvaluatorService — edge cases', () {
    test('string with quotes', () {
      expect(evaluator.evaluate("'hello'", {}), 'hello');
    });

    test('string with double quotes', () {
      expect(evaluator.evaluate('"world"', {}), 'world');
    });

    test('unknown text returns null', () {
      expect(evaluator.evaluate('someRandomText', {}), null);
    });

    test('cleans floating point artifacts', () {
      final vars = {'a': 0.3, 'b': 0.2};
      final result = evaluator.evaluate('{a} - {b}', vars);
      expect(result, 0.1);
    });

    test('integer result is returned as int', () {
      expect(evaluator.evaluate('10 / 2', {}), isA<int>());
      expect(evaluator.evaluate('10 / 2', {}), 5);
    });

    test('non-integer result is returned as double', () {
      expect(evaluator.evaluate('10 / 3', {}), isA<double>());
    });
  });
}
