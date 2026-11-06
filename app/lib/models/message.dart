class Message {
  final String id;
  final String caseId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.caseId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });
}
