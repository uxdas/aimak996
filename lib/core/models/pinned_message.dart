class PinnedMessage {
  final int id;
  final String text;
  final DateTime createdAt;

  PinnedMessage(
      {required this.id, required this.text, required this.createdAt});

  factory PinnedMessage.fromJson(Map<String, dynamic> json) {
    return PinnedMessage(
      id: json['id'] as int,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
