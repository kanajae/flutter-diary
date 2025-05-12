import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostListPage extends StatelessWidget {
  const PostListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
        appBar: AppBar(
          title: Text('投稿一覧'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('エラーが発生しました'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final docs = snapshot.data!.docs;

            // 表示用にフィルター（公開 or 自分の投稿）
            final filteredDocs = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isPublic = data['isPublic'] ?? false;
              final userId = data['userId'] ?? '';
              return isPublic || userId == currentUser?.uid;
            }).toList();

            if (filteredDocs.isEmpty) {
              return Center(
                child: Text('投稿がありません'),
              );
            }

            return ListView.builder(
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final data =
                      filteredDocs[index].data() as Map<String, dynamic>;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (data['imageUrl'] != null &&
                              data['imageUrl'] != '')
                            Image.network(data['imageUrl']),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            data['title'] ?? 'タイトルなし',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            (data['content'] ?? '').toString().length > 100
                                ? data['content'].substring(0, 100) + '...'
                                : data['content'],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            (data['createdAt'] as Timestamp)
                                .toDate()
                                .toLocal()
                                .toString()
                                .split('.')[0], // yyyy-mm-dd hh:mm:ss
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
        ));
  }
}
