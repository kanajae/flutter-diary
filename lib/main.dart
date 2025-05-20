import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:heungdiary/screens/post_form_page.dart';
import 'package:heungdiary/screens/post_list_page.dart';
import 'package:heungdiary/screens/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(HeungDiaryApp());
}

class HeungDiaryApp extends StatelessWidget {
  const HeungDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '日記アプリ',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: AuthGate(), // ログイン状態で切り替える
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ログイン状態の監視
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        } else if (snapshot.hasData) {
          return const HomePage(); // ログイン済みならメイン画面へ
        } else {
          return const LoginPage(); // 未ログインならログイン画面へ
        }
      },
    )
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pages = [
    PostListPage(), // 投稿一覧
    PostFormPage(), // 投稿フォーム
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '投稿一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '投稿新規',
          ),
        ],
      ),
    );
  }
}
