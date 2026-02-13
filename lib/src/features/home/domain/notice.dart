class Notice {
  final String id;
  final String title;
  final DateTime date;
  final String? link; // For tapping to open PDF/Page

  const Notice({
    required this.id,
    required this.title,
    required this.date,
    this.link,
  });
}
