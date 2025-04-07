import 'package:flutter/material.dart';
import 'dart:math' as math;

class IeltsCoachingPage extends StatefulWidget {
  const IeltsCoachingPage({super.key});

  @override
  State<IeltsCoachingPage> createState() => _IeltsCoachingPageState();
}

class _IeltsCoachingPageState extends State<IeltsCoachingPage> with SingleTickerProviderStateMixin {
  final Map<String, String> _readingPassages = {
    'Section 1': '''
Bakelite
In 1907, Leo Hendrick Baekeland, a Belgian scientist working in New York, discovered and patented a revolutionary new synthetic material. His invention, which he named 'Bakelite', was of enormous technological importance, and effectively launched the modern plastics industry. The term 'plastic' comes from the Greek plassein, meaning 'to mould'. Some plastics are 'thermoplastic', which means that, like candlewax, they melt when heated and can be reshaped. Others are 'thermosetting': like eggs, they cannot revert to their original viscous state, and their shape is thus fixed forever. Bakelite had the distinction of being the first totally synthetic thermosetting plastic.
    ''',
    'Section 2': '''
What's so funny?
The joke comes over the headphones: 'Which side of a dog has the most hair? The outside.' Hah! The punchline is silly yet fitting, tempting a smile, even a laugh. Laughter has always struck people as deeply mysterious, perhaps pointless. The writer Arthur Koestler dubbed it the luxury reflex: 'unique in that it serves no apparent biological purpose'. Theories about humour have an ancient pedigree. Plato expressed the idea that humour is simply a delighted feeling of superiority over others.
    ''',
    'Section 3': '''
The Birth of Scientific English
World science is dominated today by a small number of languages, but it is English which is probably the most popular global language of science. This is not just because of the importance of English-speaking countries such as the USA in scientific research; the scientists of many non-English-speaking countries find that they need to write their research papers in English to reach a wide international audience. Given the prominence of scientific English today, it may seem surprising that no one really knew how to write science in English before the 17th century. Before that, Latin was regarded as the lingua franca for European intellectuals.
    ''',
  };

  final List<Map<String, dynamic>> _questions = [
    // Easy Questions
    {
      'section': 'Section 1',
      'difficulty': 'Easy',
      'question': 'Who discovered Bakelite?',
      'options': ['Thomas Edison', 'Leo Baekeland', 'Albert Einstein', 'Nikola Tesla'],
      'answer': 'Leo Baekeland',
      'category': 'Comprehension',
    },
    {
      'section': 'Section 1',
      'difficulty': 'Easy',
      'question': 'In which year was Bakelite patented?',
      'options': ['1905', '1907', '1910', '1899'],
      'answer': '1907',
      'category': 'Comprehension',
    },
    {
      'section': 'Section 2',
      'difficulty': 'Easy',
      'question': 'What is the punchline of the joke mentioned?',
      'options': ['The left', 'The outside', 'The inside', 'The right'],
      'answer': 'The outside',
      'category': 'Comprehension',
    },
    {
      'section': 'Section 3',
      'difficulty': 'Easy',
      'question': 'Which language is the most popular for science today?',
      'options': ['French', 'German', 'English', 'Japanese'],
      'answer': 'English',
      'category': 'Comprehension',
    },

    // Medium Questions
    {
      'section': 'Section 1',
      'difficulty': 'Medium',
      'question': 'Bakelite was the first totally ___ thermosetting plastic.',
      'options': ['Natural', 'Synthetic', 'Semi-synthetic', 'Organic'],
      'answer': 'Synthetic',
      'category': 'Vocabulary',
    },
    {
      'section': 'Section 1',
      'difficulty': 'Medium',
      'question': 'What does "thermoplastic" mean?',
      'options': [
        'Cannot be reshaped',
        'Melts when heated',
        'Fixed forever',
        'Breaks under pressure'
      ],
      'answer': 'Melts when heated',
      'category': 'Vocabulary',
    },
    {
      'section': 'Section 2',
      'difficulty': 'Medium',
      'question': 'According to Koestler, laughter serves ___ biological purpose.',
      'options': ['A vital', 'No apparent', 'A significant', 'An essential'],
      'answer': 'No apparent',
      'category': 'Comprehension',
    },
    {
      'section': 'Section 3',
      'difficulty': 'Medium',
      'question': 'Before the 17th century, which language was the lingua franca for intellectuals?',
      'options': ['English', 'Latin', 'French', 'German'],
      'answer': 'Latin',
      'category': 'Comprehension',
    },

    // Hard Questions
    {
      'section': 'Section 1',
      'difficulty': 'Hard',
      'question': 'Which TWO factors influenced the design of Bakelite objects? (Select two)',
      'options': [
        'Ease of filling the mould',
        'Function of the object',
        'Removal from the mould',
        'Material limitations',
        'Fashionable styles'
      ],
      'answer': ['Ease of filling the mould', 'Removal from the mould'],
      'category': 'Attention to Detail',
      'multiSelect': true,
    },
    {
      'section': 'Section 2',
      'difficulty': 'Hard',
      'question': 'Plato believed humour is a feeling of ___ over others.',
      'options': ['Superiority', 'Inferiority', 'Equality', 'Sympathy'],
      'answer': 'Superiority',
      'category': 'Comprehension',
    },
    {
      'section': 'Section 3',
      'difficulty': 'Hard',
      'question': 'Why was Latin preferred for original science in the 17th century? (Select two)',
      'options': [
        'Wider audience',
        'Secrecy concerns',
        'Lack of English vocabulary',
        'International scholars'
      ],
      'answer': ['Secrecy concerns', 'International scholars'],
      'category': 'Attention to Detail',
      'multiSelect': true,
    },
  ];

  String _selectedDifficulty = 'Easy';
  int _currentIndex = 0;
  List<String>? _selectedOptions; // For multi-select questions
  String? _selectedOption; // For single-select questions
  bool _answered = false;
  int _score = 0;
  Map<String, int> _categoryMistakes = {};
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  // Animated values
  double _questionOpacity = 0.0;
  final List<double> _optionOpacities = [];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize option opacities
    _initializeAnimations();
    
    // Start animations
    _startEntranceAnimations();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _optionOpacities.clear();
    for (int i = 0; i < _filteredQuestions[_currentIndex]['options'].length; i++) {
      _optionOpacities.add(0.0);
    }
  }
  
  void _startEntranceAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _questionOpacity = 1.0;
      });
      
      // Animate options one by one
      for (int i = 0; i < _optionOpacities.length; i++) {
        Future.delayed(Duration(milliseconds: 200 + (i * 100)), () {
          setState(() {
            _optionOpacities[i] = 1.0;
          });
        });
      }
    });
  }

  List<Map<String, dynamic>> get _filteredQuestions =>
      _questions.where((q) => q['difficulty'] == _selectedDifficulty).toList();

  void _nextQuestion() {
    setState(() {
      if (_answered) {
        final currentQuestion = _filteredQuestions[_currentIndex];
        final correctAnswer = currentQuestion['answer'];
        final category = currentQuestion['category'];
        bool isCorrect;

        if (currentQuestion['multiSelect'] == true) {
          isCorrect = _selectedOptions != null &&
              _selectedOptions!.length == (correctAnswer as List).length &&
              _selectedOptions!.every((option) => (correctAnswer as List).contains(option));
        } else {
          isCorrect = _selectedOption == correctAnswer;
        }

        if (isCorrect) {
          _score++;
        } else {
          _categoryMistakes[category] = (_categoryMistakes[category] ?? 0) + 1;
        }

        if (_currentIndex < _filteredQuestions.length - 1) {
          // Animate exit
          _questionOpacity = 0.0;
          for (int i = 0; i < _optionOpacities.length; i++) {
            _optionOpacities[i] = 0.0;
          }
          
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _currentIndex++;
              _selectedOption = null;
              _selectedOptions = null;
              _answered = false;
              
              // Reset animations for new question
              _initializeAnimations();
              _startEntranceAnimations();
            });
          });
        } else {
          _showResultDialog();
        }
      }
    });
  }

  void _showResultDialog() {
    final total = _filteredQuestions.length;
    String suggestion = '';
    IconData resultIcon;
    Color resultColor;
    
    // Start progress animation
    _animationController.reset();
    _animationController.forward();

    if (_score == total) {
      suggestion = 'Perfect Score! You nailed it!';
      resultIcon = Icons.star;
      resultColor = Colors.yellow;
    } else if (_score >= total * 0.7) {
      suggestion = 'Great job! You\'re on the right track.';
      resultIcon = Icons.thumb_up;
      resultColor = Colors.green;
    } else {
      suggestion = 'Keep practicing! Focus on:\n';
      _categoryMistakes.forEach((key, value) {
        suggestion += '• $key (missed $value)\n';
      });
      resultIcon = Icons.lightbulb_outline;
      resultColor = Colors.orange;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(resultIcon, color: resultColor, size: 40),
            ),
            SizedBox(width: 10),
            Text('Quiz Results', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Text(
                'You scored $_score out of $total!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: resultColor),
              ),
            ),
            SizedBox(height: 16),
            Text(
              suggestion,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value * (_score / total),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _categoryMistakes.clear();
                _selectedOption = null;
                _selectedOptions = null;
                _answered = false;
                // Reset and start animations
                _initializeAnimations();
                _startEntranceAnimations();
              });
            },
            child: Text('Try Again', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to home
            },
            child: Text('Back to Home', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _filteredQuestions[_currentIndex];
    final passage = _readingPassages[currentQuestion['section']];

    return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
              Color(0xFF1E88E5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Difficulty Selector with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedDifficulty,
                      items: ['Easy', 'Medium', 'Hard']
                          .map((difficulty) => DropdownMenuItem(
                                value: difficulty,
                                child: Text(difficulty),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                          _currentIndex = 0;
                          _selectedOption = null;
                          _selectedOptions = null;
                          _answered = false;
                          _score = 0;
                          _categoryMistakes.clear();
                          // Reset and start animations
                          _initializeAnimations();
                          _startEntranceAnimations();
                        });
                      },
                      dropdownColor: Color(0xFF3949AB),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      underline: Container(height: 0),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Progress indicator
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_filteredQuestions.length, (index) {
                      return Container(
                        width: index == _currentIndex ? 30 : 10,
                        height: 10,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 16),

                // Reading Passage with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentQuestion['section'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(color: Colors.white30),
                        Text(
                          passage!,
                          style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Question with animation
                AnimatedOpacity(
                  opacity: _questionOpacity,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${_currentIndex + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                currentQuestion['question'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        if (currentQuestion['multiSelect'] == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '(Select two answers)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Options
                ...List.generate(currentQuestion['options'].length, (index) {
                  final option = currentQuestion['options'][index];
                  bool isCorrect = currentQuestion['multiSelect'] == true
                      ? (currentQuestion['answer'] as List).contains(option)
                      : option == currentQuestion['answer'];
                  bool isSelected = currentQuestion['multiSelect'] == true
                      ? _selectedOptions?.contains(option) ?? false
                      : option == _selectedOption;
                  Color tileColor = Colors.white.withOpacity(0.1);

                  if (_answered) {
                    if (isSelected && isCorrect) {
                      tileColor = Colors.green.withOpacity(0.4);
                    } else if (isSelected && !isCorrect) {
                      tileColor = Colors.red.withOpacity(0.4);
                    } else if (isCorrect) {
                      tileColor = Colors.green.withOpacity(0.2);
                    }
                  }

                  return AnimatedOpacity(
                    opacity: index < _optionOpacities.length ? _optionOpacities[index] : 0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      transform: Matrix4.identity()
                        ..translate(
                          0.0,
                          isSelected ? -5.0 : 0.0,
                        ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: GestureDetector(
                        onTap: !_answered
                            ? () {
                                setState(() {
                                  if (currentQuestion['multiSelect'] == true) {
                                    _selectedOptions ??= [];
                                    if (_selectedOptions!.contains(option)) {
                                      _selectedOptions!.remove(option);
                                    } else if (_selectedOptions!.length < 2) {
                                      _selectedOptions!.add(option);
                                    }
                                    _answered = _selectedOptions!.isNotEmpty;
                                  } else {
                                    _selectedOption = option;
                                    _answered = true;
                                  }
                                });
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  isSelected ? Icons.check : null,
                                  color: Colors.blue[900],
                                  size: 16,
                                ),
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: 24),

                // Next Button with animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _answered ? 1.0 : 0.6,
                    child: ElevatedButton(
                      onPressed: _answered ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[900],
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: _answered ? 8 : 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentIndex < _filteredQuestions.length - 1 ? 'Next' : 'Finish',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            _currentIndex < _filteredQuestions.length - 1
                                ? Icons.arrow_forward
                                : Icons.check_circle,
                            size: 20,
                          ),
                          if (_answered)
                            AnimatedBuilder(
                              animation: _animationController..repeat(reverse: true),
                              builder: (_, child) {
                                return Transform.translate(
                                  offset: Offset(_animationController.value * 4, 0),
                                  child: child,
                                );
                              },
                              child: Icon(
                                _currentIndex < _filteredQuestions.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.check_circle,
                                size: 0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      useMaterial3: true,
    ),
    home: IeltsCoachingPage(),
  ));
}