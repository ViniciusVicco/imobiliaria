class Enviroment {
  final bool debug;
  final String configName;
  final String apiBaseUrl;
  final String cdcUrl;
  final bool logEnabled;
  final int colorFromHex;
  final String firebaseEnv;
  final String geniaBaseUrl;

  Enviroment({
    this.debug = false,
    required this.configName,
    required this.apiBaseUrl,
    required this.cdcUrl,
    this.logEnabled = false,
    required this.colorFromHex,
    required this.firebaseEnv,
    required this.geniaBaseUrl,
  });

  String get firebaseNotificationSubscriptionName => "topic-$configName";

  factory Enviroment.fromJson(Map<String, dynamic> json) {
    return Enviroment(
        firebaseEnv: json['firebaseEnv'],
        colorFromHex: json['colorFromHex'],
        configName: json['configName'],
        debug: json['debug'],
        apiBaseUrl: json['apiBaseUrl'],
        cdcUrl: json['cdcUrl'],
        logEnabled: json['logEnabled'],
        geniaBaseUrl: json['geniaBaseUrl']);
  }

  Map<String, dynamic> toMap() => {
        "configName": configName,
        "debug": debug,
        "apiBaseUrl": apiBaseUrl,
        "cdcUrl": cdcUrl,
        "logEnabled": logEnabled,
        "colorFromHex": colorFromHex,
        "firebaseEnv": firebaseEnv,
        "geniaBaseUrl": geniaBaseUrl,
      };
}

