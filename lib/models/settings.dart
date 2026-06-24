class Settings {
  bool adBlockEnabled;
  String userAgent;
  bool darkTheme;
  String updateUrl;
  String privacyPassword;

  Settings({
    this.adBlockEnabled = true,
    this.userAgent = 'mobile',
    this.darkTheme = false,
    this.updateUrl = '',
    this.privacyPassword = '135235',
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      adBlockEnabled: json['adBlockEnabled'] ?? true,
      userAgent: json['userAgent'] ?? 'mobile',
      darkTheme: json['darkTheme'] ?? false,
      updateUrl: json['updateUrl'] ?? '',
      privacyPassword: json['privacyPassword'] ?? '135235',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adBlockEnabled': adBlockEnabled,
      'userAgent': userAgent,
      'darkTheme': darkTheme,
      'updateUrl': updateUrl,
      'privacyPassword': privacyPassword,
    };
  }
}