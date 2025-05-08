import 'dart:math';

class Question {
  final String questionText;
  final int correctAnswer;
  final List<int> options;

  Question(this.questionText, this.correctAnswer, this.options);
}

Question generateQuestion({String difficulty = 'easy', required String operation}) {
  final random = Random();
  int a = 0, b = 0;

  // Set number range based on difficulty
  switch (difficulty) {
    case 'easy':
      a = random.nextInt(10); // 0–9
      b = random.nextInt(10);
      break;
    case 'hard':
      a = random.nextInt(50) + 10; // 10–59
      b = random.nextInt(50) + 10;
      break;
    case 'difficult':
      a = random.nextInt(900) + 100; // 100–999
      b = random.nextInt(900) + 100;
      break;
  }

  // Randomly pick an operation
  final operations = ['+', '-', '×', '÷'];
  final operation = operations[random.nextInt(operations.length)];

  int correct = 0;
  String question = '';

  switch (operation) {
    case '+':
      correct = a + b;
      question = "$a + $b = ?";
      break;
    case '-':
      if (b > a) {
        final temp = a;
        a = b;
        b = temp;
      }
      correct = a - b;
      question = "$a - $b = ?";
      break;
    case '×':
      correct = a * b;
      question = "$a × $b = ?";
      break;
    case '÷':
      b = (b == 0) ? 1 : b;
      correct = a ~/ b;
      a = correct * b; // Ensure clean division
      question = "$a ÷ $b = ?";
      break;
  }

  Set<int> options = {correct};
  while (options.length < 4) {
    int wrong = correct + random.nextInt(10) - 5;
    if (wrong != correct && wrong >= 0) options.add(wrong);
  }

  return Question(question, correct, options.toList()..shuffle());
}
