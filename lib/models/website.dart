class Website {
  final String id;
  final String name;
  final String url;
  final String description;
  final String category;
  final String coverUrl;
  final int heatCount;

  Website({
    required this.id,
    required this.name,
    required this.url,
    required this.description,
    required this.category,
    required this.coverUrl,
    required this.heatCount,
  });

  factory Website.fromJson(Map<String, dynamic> json) {
    return Website(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      description: json['description'],
      category: json['category'],
      coverUrl: json['coverUrl'],
      heatCount: json['heatCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'description': description,
      'category': category,
      'coverUrl': coverUrl,
      'heatCount': heatCount,
    };
  }
}