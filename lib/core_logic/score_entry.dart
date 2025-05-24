import 'package:flutter/foundation.dart';

@immutable
class ScoreEntry {
  final String username;
  final int score;
  final DateTime timestamp;

  const ScoreEntry({
    required this.username,
    required this.score,
    required this.timestamp,
  });

  // Factory constructor for deserialization
  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      username: json['username'] as String,
      score: json['score'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Method for serialization
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          score == other.score &&
          timestamp == other.timestamp;

  @override
  int get hashCode => username.hashCode ^ score.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'ScoreEntry{username: $username, score: $score, timestamp: $timestamp}';
  }
}