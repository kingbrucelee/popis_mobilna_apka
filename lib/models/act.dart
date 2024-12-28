class Act {
  final String title;
  final String type;

  Act({required this.title, required this.type});

  factory Act.fromJson(Map<String, dynamic> json) {
    return Act(
      title: json['title'] ?? 'Brak tytułu',
      type: json['type'] ?? 'Nieznany',
    );
  }
}
