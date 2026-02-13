import 'package:flutter/material.dart';

class StudentResultListScreen extends StatelessWidget {
  const StudentResultListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final results = [
      {
        'title': 'Mathematics Mid-Term',
        'score': 85,
        'total': 100,
        'date': '15 Dec 2024',
        'status': 'Pass',
      },
      {
        'title': 'Science Quiz',
        'score': 18,
        'total': 20,
        'date': '10 Dec 2024',
        'status': 'Pass',
      },
      {
        'title': 'English Grammar',
        'score': 42,
        'total': 50,
        'date': '05 Dec 2024',
        'status': 'Pass',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          final percentage =
              ((result['score'] as int) / (result['total'] as int)) * 100;
          Color gradeColor = Colors.green;
          if (percentage < 35) {
            gradeColor = Colors.red;
          } else if (percentage < 60) {
            gradeColor = Colors.orange;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircularProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(gradeColor),
              ),
              title: Text(
                result['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Date: ${result['date']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result['score']}/${result['total']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: gradeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
