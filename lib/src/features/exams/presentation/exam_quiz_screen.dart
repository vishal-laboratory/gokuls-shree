import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';
import '../data/exam_repository.dart';
import '../domain/exam_model.dart';

final examQuestionsProvider = FutureProvider.family<List<Question>, String>((
  ref,
  id,
) async {
  return ref.read(examRepositoryProvider).getQuestions(id);
});

class ExamQuizScreen extends ConsumerStatefulWidget {
  final String examId;
  final Exam? examMetadata; // Passed via extra

  const ExamQuizScreen({super.key, required this.examId, this.examMetadata});

  @override
  ConsumerState<ExamQuizScreen> createState() => _ExamQuizScreenState();
}

class _ExamQuizScreenState extends ConsumerState<ExamQuizScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {}; // Map<QuestionIndex, OptionIndex>
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitted = false;
  int _switchCounts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Start listening to lifecycle
    if (widget.examMetadata != null) {
      _remainingSeconds = widget.examMetadata!.durationMinutes * 60;
      _startTimer();
    }
  }

  // ANTI-CHEAT: Detect Tab Switching
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // User left the app (or notification shade pulled down)
      if (!_isSubmitted) {
        _handleAppSwitch();
      }
    }
  }

  void _handleAppSwitch() {
    _switchCounts++;
    debugPrint("⚠️ App Switch Detected! Count: $_switchCounts");

    // Warn user immediately (when they come back, or if logic runs in background)
    // Since UI can't update easily in background, we set state and show dialog on resume usually.
    // However, showing a dialog now might work if still active context.

    if (_switchCounts >= 3) {
      _submitExam(); // Auto submit after 3 warnings
    } else {
      // Show warning snackbar or dialog
      // Note: Calling showDialog from background might fail or not show until resume.
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Stop listening
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _submitExam([List<Question>? questions]) {
    if (_isSubmitted) return;
    _isSubmitted = true;
    _timer?.cancel();

    int score = 0;
    int total = questions?.length ?? 0;

    if (questions != null) {
      for (int i = 0; i < total; i++) {
        if (_selectedAnswers[i] == questions[i].correctOptionIndex) {
          score++;
        }
      }
    }

    // Navigate to Result Screen
    context.pushReplacement(
      '/exams/result',
      extra: {
        'score': score,
        'total': total,
        'title': widget.examMetadata?.title ?? 'Exam',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(examQuestionsProvider(widget.examId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examMetadata?.title ?? 'Exam'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60 ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(child: Text("No questions found."));
              }
              // Start timer if not started (e.g., if metadata was null)
              if (_timer == null && !_isSubmitted) {
                _remainingSeconds = 30 * 60; // Default 30 mins
                _startTimer();
              }

              return Column(
                children: [
                  // Progress Bar
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Question Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentQuestionIndex + 1}/${questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Question Page View
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable swipe
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                question.text,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ...List.generate(question.options.length, (
                                optIndex,
                              ) {
                                final isSelected =
                                    _selectedAnswers[index] == optIndex;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedAnswers[index] = optIndex;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: isSelected
                                            ? AppTheme.primaryColor.withOpacity(
                                                0.05,
                                              )
                                            : Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppTheme.primaryColor
                                                    : Colors.grey,
                                              ),
                                              color: isSelected
                                                  ? AppTheme.primaryColor
                                                  : null,
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 16,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              question.options[optIndex],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Navigation Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                setState(() => _currentQuestionIndex--);
                              },
                              child: const Text('Previous'),
                            ),
                          ),
                        if (_currentQuestionIndex > 0)
                          const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              if (_currentQuestionIndex <
                                  questions.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                setState(() => _currentQuestionIndex++);
                              } else {
                                // Submit
                                _submitExam(questions);
                              }
                            },
                            child: Text(
                              _currentQuestionIndex < questions.length - 1
                                  ? 'Next'
                                  : 'Submit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          if (_switchCounts > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Warning: App switch detected! ($_switchCounts/3)",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
