class AgentMessage {
  final String agent;
  final String text;
  final int timestamp;
  
  AgentMessage({
    required this.agent,
    required this.text,
    required this.timestamp,
  });

  factory AgentMessage.fromMap(Map<dynamic, dynamic> map) {
    return AgentMessage(
      agent: map['agent'] ?? 'Unknown',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
