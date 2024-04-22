import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:uuid/uuid.dart';

class CallHistoryModel {
  String? id;
  int? createdAt;
  final List<User> callerUserData;
  final List<User> receiverUserData;
  final List<String> membersId;
  final bool isGroup;
  String? roomId;
  String? roomTag;
  String? roomName;
  String? roomImage;

  CallHistoryModel({
    this.id,
    this.createdAt,
    this.roomId,
    this.roomTag,
    this.roomName,
    this.roomImage,
    required this.callerUserData,
    required this.receiverUserData,
    required this.membersId,
    required this.isGroup,
  });

  // Serialization
  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': DateTime.timestamp().millisecondsSinceEpoch,
      'callerUserData': callerUserData.map((user) => user.toJson()).toList(),
      'receiverUserData': receiverUserData.map((user) => user.toJson()).toList(),
      'membersId': membersId,
      'isGroup': isGroup,
      'roomId': roomId,
      'roomName': roomName,
      'roomImage': roomImage,
      'roomTag': roomTag,
    };
  }


  // Deserialization
  factory CallHistoryModel.fromJson(Map<String, dynamic> jsonMap) {
    List<User> callerUserData = [];
    List<User> receiverUserData = [];

    var callerData = jsonMap['callerUserData'];
    if (callerData is List) {
      callerUserData = List<User>.from(callerData.map((userData) => User.fromJson(userData)));
    }

    var receiverData = jsonMap['receiverUserData'];
    if (receiverData is List) {
      receiverUserData = List<User>.from(receiverData.map((userData) => User.fromJson(userData)));
    }

    return CallHistoryModel(
      id: jsonMap['id'],
      createdAt: jsonMap['createdAt'],
      roomId: jsonMap['roomId'],
      roomName: jsonMap['roomName'],
      roomImage: jsonMap['roomImage'],
      roomTag: jsonMap['roomTag'],
      callerUserData: callerUserData,
      receiverUserData: receiverUserData,
      membersId: List<String>.from(jsonMap['membersId'] ?? []),
      isGroup: jsonMap['isGroup'] ?? false,
    );
  }
}
