import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/aspect_ratio_video.dart';

class VideoUploadPage extends StatefulWidget {
  const VideoUploadPage({Key? key}) : super(key: key);

  @override
  State<VideoUploadPage> createState() => _VideoUploadPageState();
}

class _VideoUploadPageState extends State<VideoUploadPage> {
  void _setImageFileListFromFile(XFile? value) {}

  bool isVideo = false;
  XFile? file;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _descriptionController = TextEditingController();

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  final firebaseStorageInstance = FirebaseStorage.instance;
  final firebaseFirestoreInstance = FirebaseFirestore.instance;
  final firebaseAuthInstance = FirebaseAuth.instance;

  Future<void> _uploadMetadata(
      String videoCloudLocation, int videoTimestamp, String userId) async {
    final metadata = <String, dynamic>{
      "video_location": videoCloudLocation,
      "description": _descriptionController.text,
      // "location": "TBA"
      "timestamp": videoTimestamp
    };

    firebaseFirestoreInstance
        .collection("users")
        .doc(userId)
        .collection("videos")
        .doc("$videoTimestamp")
        .set(metadata, SetOptions(merge: true))
        .onError((error, stackTrace) => print(error));
  }

  Future<void> _uploadFile() async {
    final file = this.file;
    if (file != null) {
      final storageRef = firebaseStorageInstance.ref();
      String filePath = file.path;
      // String fileName = file.name;
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      String? userId = "anonymous";
      if (firebaseAuthInstance.currentUser != null) {
        userId = firebaseAuthInstance.currentUser?.uid;
      }

      File videoFile = File(filePath);
      String videoCloudLocation = "$userId/videos/$currentTimestamp";
      final videoRef = storageRef.child(videoCloudLocation);

      try {
        await videoRef.putFile(videoFile);
      } on FirebaseException catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }

      await _uploadMetadata(videoCloudLocation, currentTimestamp, userId!);
    }
  }

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      const double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    final XFile? pickedFile = await _picker.pickVideo(
        source: source, maxDuration: const Duration(seconds: 10));
    setState(() {
      file = pickedFile;
    });
    await _playVideo(file);
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file);
          } else {}
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  List<Widget> description() {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 22, right: 22, top: 6),
        child: TextField(
          focusNode: _focusNode,
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: "Tell us what is on your mind...",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            fillColor: Colors.white,
            filled: true,
          ),
          maxLines: 10,
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
          },
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Video"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Center(
                child:
                    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                        ? FutureBuilder<void>(
                            future: retrieveLostData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<void> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const Text(
                                    'You have not yet picked an image.',
                                    textAlign: TextAlign.center,
                                  );
                                case ConnectionState.done:
                                  return _previewVideo();
                                default:
                                  if (snapshot.hasError) {
                                    return Text(
                                      'Pick image/video error: ${snapshot.error}}',
                                      textAlign: TextAlign.center,
                                    );
                                  } else {
                                    return const Text(
                                      'You have not yet picked an image.',
                                      textAlign: TextAlign.center,
                                    );
                                  }
                              }
                            },
                          )
                        : _previewVideo(),
              ),
            ),
            Form(
                child: Column(
              children: description(),
            ))
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              heroTag: 'video0',
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
              heroTag: 'video1',
              tooltip: 'Take a Video',
              child: const Icon(Icons.videocam),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                if (kDebugMode) {
                  print("Upload!");
                }
                _uploadFile();
              },
              heroTag: 'uploadVideo',
              tooltip: 'Upload the Video',
              child: const Icon(Icons.upload),
            ),
          )
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
