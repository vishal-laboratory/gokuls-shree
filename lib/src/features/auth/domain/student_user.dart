class StudentUser {
  final String id;
  final String registrationNumber;
  final String name;
  final String? email;
  final String? phone;
  final String? courseName;
  final String? sessionYear;
  final String? photoUrl;

  const StudentUser({
    required this.id,
    required this.registrationNumber,
    required this.name,
    this.email,
    this.phone,
    this.courseName,
    this.sessionYear,
    this.photoUrl,
  });

  factory StudentUser.fromJson(Map<String, dynamic> json) {
    return StudentUser(
      id: json['id'] as String,
      registrationNumber: json['registration_number'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      courseName: json['course_name'] as String?,
      sessionYear: json['session_year'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}
