import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'question_generator.dart';

void main() {
  runApp(const MathGameApp());
}

class MathGameApp extends StatelessWidget {
  const MathGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Game',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color.fromARGB(255, 185, 186, 232),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/math.jpg',
            fit: BoxFit.cover,
          ),
          // Foreground UI
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D Bubble Font Title
              const Text(
                'Math Game',
                style: TextStyle(
                  fontFamily: 'BubbleFont', // Add your custom font in pubspec.yaml
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(4.0, 4.0),
                      blurRadius: 10.0,
                      color: Colors.blueAccent,
                    ),
                    Shadow(
                      offset: Offset(-4.0, -4.0),
                      blurRadius: 10.0,
                      color: Colors.purpleAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              _build3DElevatedButton(
                text: 'Start Game',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _build3DElevatedButton(
                text: 'Exit',
                onPressed: () {
                  SystemNavigator.pop(); // Exit the app
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DElevatedButton({required String text, required VoidCallback onPressed}) {
    return Transform(
      transform: Matrix4.rotationX(0.1),
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 24),
        ),
        child: Text(text),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Question _currentQuestion;
  int _score = 0;
  int _lives = 3;
  String _difficulty = 'easy';
  final String _operation = 'addition';
  int _highScore = 0;
  int _timeRemaining = 8;

  @override
  void initState() {
    super.initState();
    _currentQuestion = generateQuestion(difficulty: _difficulty, operation: _operation);
    _startTimer();
  }

  void _startTimer() {
    _timeRemaining = 8;
  }

  void _checkAnswer(int selected) {
    bool isCorrect = selected == _currentQuestion.correctAnswer;

    if (isCorrect) {
      setState(() {
        _score++;
        _adjustDifficulty();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Correct!'), duration: Duration(milliseconds: 800)),
      );
    } else {
      setState(() {
        _lives--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Wrong!'), duration: Duration(milliseconds: 800)),
      );
    }

    if (_lives == 0) {
      _showGameOverDialog();
    } else {
      setState(() {
        _currentQuestion = generateQuestion(difficulty: _difficulty, operation: _operation);
        _startTimer();
      });
    }
  }

  void _adjustDifficulty() {
    if (_score >= 35) {
      _difficulty = 'master';
    } else if (_score >= 25) {
      _difficulty = 'difficult';
    } else if (_score >= 20) {
      _difficulty = 'hard';
    } else {
      _difficulty = 'easy';
    }
  }

  void _showGameOverDialog() {
    if (_score > _highScore) {
      _highScore = _score;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Better luck next time!\nYour final score: $_score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Math Game'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 237, 113, 206),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_highScore > 0)
              Text("🔥 High Score: $_highScore", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Time Remaining: $_timeRemaining seconds", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _currentQuestion.questionText,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ..._currentQuestion.options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          onPressed: () => _checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                            backgroundColor: const Color.fromARGB(255, 141, 196, 223),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                          child: Text(option.toString()),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("Score: $_score", style: const TextStyle(fontSize: 20)),
                Row(
                  children: List.generate(3, (index) {
                    return Icon(
                      index < _lives ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
