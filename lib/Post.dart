import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String imageUrl;
  final bool isPublic;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.isPublic,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json, String id) {
    return Post(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isPublic: json['isPublic'] ?? false,
      createdAt: (json['createAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'createdAt': createdAt,
    };
  }
}
