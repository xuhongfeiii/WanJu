class Favorite {
  final String websiteId;
  final String groupName;
  final DateTime addedAt;

  Favorite({
    required this.websiteId,
    required this.groupName,
    required this.addedAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      websiteId: json['websiteId'],
      groupName: json['groupName'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteId': websiteId,
      'groupName': groupName,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}