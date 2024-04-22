import 'package:cloud_firestore/cloud_firestore.dart';

enum StoryMediaType {
  image,
  video,
}

class StoryModel {
  final String userId;
  final String userImage;
  final String userName;
  final StoryItem story;
  final int? createdAt; // Change type to int

  StoryModel({
    required this.userId,
    required this.userImage,
    required this.userName,
    required this.story,
    this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      userId: json['userId'],
      userImage: json['userImage'],
      userName: json['userName'],
      story: StoryItem.fromJson(json['story']),
      createdAt: json['createdAt'], // No need for conversion
    );
  }

  factory StoryModel.create({
    required String userId,
    required String userImage,
    required String userName,
    required StoryItem story,
  }) {
    return StoryModel(
      userId: userId,
      userImage: userImage,
      userName: userName,
      story: story,
      createdAt: DateTime.now().millisecondsSinceEpoch, // Convert DateTime to int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userImage': userImage,
      'userName': userName,
      'story': story.toJson(),
      'createdAt': createdAt, // No need for conversion
    };
  }
}

class StoryItem {
  final String? storyUrl; // Changed to nullable as URL might not be present for text stories
  final StoryMediaType media;
  final Duration? duration; // Changed to nullable to support text stories
  final String? videoThumbnail;

  StoryItem({
    this.storyUrl,
    required this.media,
    this.duration,
    this.videoThumbnail,
  });

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    StoryMediaType mediaType;
    if (json['mediaType'] == 'image') {
      mediaType = StoryMediaType.image;
    } else if (json['mediaType'] == 'video') {
      mediaType = StoryMediaType.video;
    } else {
      mediaType = StoryMediaType.image; // Default to text if mediaType is not specified
    }

    return StoryItem(
      storyUrl: json['storyUrl'],
      media: mediaType,
      videoThumbnail: json['videoThumbnail'],
      duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storyUrl': storyUrl,
      'mediaType': media.toString().split('.').last, // Store media type as string
      'duration': duration?.inMilliseconds,
      'videoThumbnail': videoThumbnail,
    };
  }
}
