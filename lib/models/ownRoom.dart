import 'package:cloud_firestore/cloud_firestore.dart';

class OwnRoom {
  final DateTime createdAt;
  final String? imageUrl;
  final List<Map<String, dynamic>> lastMessages;
  final String? name;
  final String type;
  final DateTime updatedAt;
  final List<String> userIds;
  final Map<String, dynamic>? userRoles;
  final Map<String, dynamic>? metadata;

  OwnRoom({
    required this.createdAt,
    required this.imageUrl,
    required this.lastMessages,
    required this.name,
    required this.type,
    required this.updatedAt,
    required this.userIds,
    required this.userRoles,
    required this.metadata,
  });

  factory OwnRoom.fromJson(Map<String, dynamic> json) {
    return OwnRoom(
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
      lastMessages: List<Map<String, dynamic>>.from(json['lastMessages']),
      name: json['name'],
      type: json['type'],
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      userIds: List<String>.from(json['userIds']),
      userRoles: json['userRoles'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'imageUrl': imageUrl,
      'lastMessages': lastMessages,
      'name': name,
      'type': type,
      'updatedAt': updatedAt,
      'userIds': userIds,
      'userRoles': userRoles,
      'metadata': metadata,
    };
  }
}
