import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stevens_learn/utils/auth_helpers.dart';

class MyVideoPage extends StatefulWidget {
  const MyVideoPage({Key? key}) : super(key: key);

  @override
  State<MyVideoPage> createState() => _MyVideoPageState();
}

class _MyVideoPageState extends State<MyVideoPage> {
  bool _isLoaded = false;

  List _videos = [];

  final _firebaseFirestoreInstance = FirebaseFirestore.instance;

  void _fetchAllUserVideos() {
    String userId = getUserId();
    _firebaseFirestoreInstance
        .collection("users")
        .doc(userId)
        .collection("videos")
        .orderBy("timestamp")
        .limit(10)
        .get()
        .then((response) {
      for (var video in response.docs) {
        _videos.add(video.data());
      }
    });

    setState(() {
      _isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllUserVideos();
  }

  List<Widget> _buildVideoList() {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Videos"),
      ),
      body: SingleChildScrollView(
        child: _isLoaded
            ? Container()
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
