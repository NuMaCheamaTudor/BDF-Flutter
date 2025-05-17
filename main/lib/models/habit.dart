class Habit {
  final String id;
  final String title;
  final String description;
  bool isSelected;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    this.isSelected = false,
  });
}
