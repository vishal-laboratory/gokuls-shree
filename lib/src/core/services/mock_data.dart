class MockData {
  static const Map<String, dynamic> studentProfile = {
    "status": "success",
    "data": {
      "id": "1",
      "name": "Rohan Kumar",
      "father_name": "Suresh Kumar",
      "gender": "Male",
      "course_id": "ADCA",
      "photo_url": "https://via.placeholder.com/150",
    },
  };

  static const Map<String, dynamic> studentResults = {
    "status": "success",
    "data": [
      {
        "subject": "Computer Fundamentals",
        "marks_obtained": "85",
        "max_marks": "100",
      },
      {"subject": "MS Office", "marks_obtained": "92", "max_marks": "100"},
    ],
  };

  static const Map<String, dynamic> pingSuccess = {
    "status": "success",
    "message": "Pong! Server is up (Mock).",
  };

  static const Map<String, dynamic> authLoginSuccess = {
    "user": {
      "id": "1",
      "registrationNumber": "GO123456",
      "name": "Rohan Kumar",
      "role": "student",
    },
    "token": "mock_token_12345",
  };

  static const Map<String, dynamic> authRegisterSuccess = {
    "status": "success",
    "message": "Registration successful",
  };

  static const Map<String, dynamic> authAdminLoginSuccess = {
    "user": {
      "id": "ADMIN001",
      "registrationNumber": null,
      "name": "System Administrator",
      "role": "admin",
    },
    "token": "mock_admin_token_999",
  };

  static const Map<String, dynamic> examList = {
    "status": "success",
    "data": [
      {
        "id": "EX001",
        "title": "Computer Fundamentals",
        "duration_minutes": 30,
        "total_marks": 50,
        "questions_count": 5,
      },
      {
        "id": "EX002",
        "title": "MS Office Specialist",
        "duration_minutes": 45,
        "total_marks": 50,
        "questions_count": 10,
      },
    ],
  };

  static const Map<String, dynamic> examQuestions = {
    "status": "success",
    "data": [
      {
        "id": "Q1",
        "text": "Who is known as the father of the computer?",
        "options": [
          "Alan Turing",
          "Charles Babbage",
          "Bill Gates",
          "Steve Jobs",
        ],
        "correct_option_index": 1,
      },
      {
        "id": "Q2",
        "text": "What does CPU stand for?",
        "options": [
          "Central Process Unit",
          "Central Processing Unit",
          "Computer Personal Unit",
          "Central Processor Unit",
        ],
        "correct_option_index": 1,
      },
      {
        "id": "Q3",
        "text": "Which of these is NOT an input device?",
        "options": ["Mouse", "Keyboard", "Monitor", "Scanner"],
        "correct_option_index": 2,
      },
      {
        "id": "Q4",
        "text": "1 Kilobyte (KB) is equal to:",
        "options": ["1000 Bytes", "1024 Bytes", "1024 Bits", "1000 Bits"],
        "correct_option_index": 1,
      },
      {
        "id": "Q5",
        "text": "Which key is used to refresh the active window?",
        "options": ["F2", "F5", "F10", "F12"],
        "correct_option_index": 1,
      },
    ],
  };
}
