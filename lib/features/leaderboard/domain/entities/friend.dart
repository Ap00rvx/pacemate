class Friend {
  final String id;
  final String name;
  final String avatarUrl; // can be empty for placeholder

  const Friend({required this.id, required this.name, this.avatarUrl = ''});
}
