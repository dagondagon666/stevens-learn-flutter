import 'package:flutter/material.dart';
import 'package:stevens_learn/pages/drills/drills.dart';
import 'package:stevens_learn/pages/home/home.dart';
import 'package:stevens_learn/pages/login/login.dart';
import 'package:stevens_learn/pages/social/social.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learn Snowboard at Stevens Pass!',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const BaseApp(),
      // initialRoute: '/login',
      // routes: {
      //   '/login': (context) => const LoginPage(),
      //   '/': (context) => const VideoUploadPage()
      // },
    );
  }
}

class BaseApp extends StatefulWidget {
  // int selectedIndex;

  const BaseApp({Key? key}) : super(key: key);
  // BaseApp({required this.selectedIndex});

  @override
  State<BaseApp> createState() => _BaseAppState();
}

class _BaseAppState extends State<BaseApp> {
  int _selectedIndex = 0;

  // _BaseAppState({required this.selectedIndex});

  final List<Widget> _children = [
    const HomePage(),
    const DrillsPage(),
    const SocialPage(),
    const LoginPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.snowboarding),
            label: "Drills",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.social_distance),
            label: "Friends",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
