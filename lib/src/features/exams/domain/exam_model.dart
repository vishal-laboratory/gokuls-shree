class Exam {
  final String id;
  final String title;
  final int durationMinutes;
  final int totalMarks;
  final int questionsCount;

  Exam({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalMarks,
    required this.questionsCount,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      durationMinutes: json['duration_minutes'],
      totalMarks: int.tryParse(json['total_marks'].toString()) ?? 0,
      questionsCount: json['questions_count'],
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correct_option_index'],
    );
  }
}
