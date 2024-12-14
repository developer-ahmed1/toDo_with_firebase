class Task {
  String id;
  String title;
  bool isCompleted;

  Task({required this.id, required this.title, this.isCompleted = false});

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
