import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PostFormPage extends StatefulWidget {
  const PostFormPage({super.key});

  @override
  State<PostFormPage> createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  String imageUrl = '';
  File? _image;
  bool isPublic = true;

  // 画像を選択するメソッド
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Firebase Storageに画像をアップロードするメソッド
  Future<String> _uploadImage(File image) async {
    try {
      // Firebase Storageの参照を作成
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('posts/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // 画像をアップロード
      await storageRef.putFile(image);
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print("画像のアップロードに失敗しました: $e");
      return '';
    }
  }

  // 投稿するメソッド
  Future<void> _postDiary() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('ログインしていません');
      return;
    }

    if (_image != null) {
      // 画像をFirebase Storageにアップロード
      imageUrl = await _uploadImage(_image!);
      print("アップロードした画像のURL: $imageUrl");
    }

    final post = {
      'title': title,
      'content': content,
      'userId': user.uid,
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('posts').add(post);
      print("投稿成功！");
      Navigator.pop(context); // 投稿後に前の画面に戻るなど
    } catch (e) {
      print("Firestore保存エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("日記投稿"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "タイトル"),
                onChanged: (value) => title = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "内容"),
                maxLines: 5,
                onChanged: (value) => content = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '内容を入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              // 画像選択ボタン
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("画像を選択"),
              ),
              // 画像が選択されている場合、そのプレビューを表示
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.file(_image!),
                ),
              // 公開・非公開の切り替え
              SwitchListTile(
                title: Text('公開'),
                value: isPublic,
                onChanged: (value) {
                  setState(() {
                    isPublic = value;
                  });
                },
              ),
              // 投稿ボタン
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _postDiary();
                  }
                },
                child: Text("投稿"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
