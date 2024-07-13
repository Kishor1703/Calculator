import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: CalculatorApp(),
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(

      home: Calculator(),
      debugShowCheckedModeBanner: false,

    );
  }
}

class Calculator extends StatelessWidget {
  final List<String> buttons = [
    'sin', 'cos', 'tan', 'sqrt', 'log',
    '7', '8', '9', '/', 'C',
    '4', '5', '6', '*', '(',
    '1', '2', '3', '-', ')',
    '0', '.', '+', '=', '<-', '^'
  ];


  void _onButtonPressed(BuildContext context, String buttonText) {
    final _calculatorProvider = Provider.of<CalculatorProvider>(context, listen: false);
    if (buttonText == '=') {
      _calculatorProvider.calculateResult();
    } else if (buttonText == 'C') {
      _calculatorProvider.clearInput();
    } else if (buttonText == '<-') {
      _calculatorProvider.removeLastCharacter();
    } else {
      _calculatorProvider.addToInput(buttonText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),

      body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<CalculatorProvider>(
              builder: (context, calculatorProvider, _) => Container(
                padding: EdgeInsets.all(20.0),
                alignment: Alignment.bottomRight,
                child: Text(
                  calculatorProvider.getInput(),
                  style: TextStyle(fontSize: 32.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<CalculatorProvider>(
              builder: (context, calculatorProvider, _) => Container(
                padding: EdgeInsets.all(20.0),
                alignment: Alignment.bottomRight,
                child: Text(
                  calculatorProvider.getOutput(),
                  style: TextStyle(fontSize: 32.0),
                ),
              ),
            ),
          ),
          Divider(height: 1.0),
          Expanded(
            flex: 2,
            child: Container(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  final buttonText = buttons[index];
                  return GestureDetector(
                    onTap: () => _onButtonPressed(context, buttonText),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorProvider with ChangeNotifier {
  String _input = '';
  String _output = '';


  void addToInput(String buttonText) {
    _input += buttonText;
    notifyListeners();
  }

  void removeLastCharacter() {
    if (_input.isNotEmpty) {
      _input = _input.substring(0, _input.length - 1);
      notifyListeners();
    }
  }

  void clearInput() {
    _input = '';
    _output = ''; // Clear the output result as well
    notifyListeners();
  }

  void calculateResult() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_input);
      ContextModel cm = ContextModel();
      String expressionString = exp.toString();
      String modifiedExpression = expressionString.replaceAll(RegExp(r'(\d+(\.\d+)?)\^(\d+(\.\d+)?)'), "calculatePow(1, 3)");
      Expression expWithPowerReplaced = p.parse(modifiedExpression);
      double result = expWithPowerReplaced.evaluate(EvaluationType.REAL, cm);
      _output = result.toString();
      notifyListeners();
    } catch (e) {
      _output = 'Error';
      notifyListeners();
    }
  }

  String getInput() => _input;
  String getOutput() => _output;


  num calculatePow(double base, double exponent) {
    return math.pow(base, exponent);
  }
}
