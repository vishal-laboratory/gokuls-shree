class Course {
  final String id;
  final String title;
  final String category; // Diploma, Vocational, University, Yoga
  final String duration;
  final String? eligibility; // e.g., "10th Pass"
  final String imagePath; // Asset or Network URL

  const Course({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    this.eligibility,
    required this.imagePath,
  });

  // Factory for potential JSON parsing later
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      duration: json['duration'] as String,
      eligibility: json['eligibility'] as String?,
      imagePath: json['imagePath'] as String,
    );
  }
}
