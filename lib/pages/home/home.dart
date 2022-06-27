import 'package:flutter/material.dart';
import 'package:stevens_learn/pages/video_upload.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _buildHomeCards() {
    return [
      Card(
        color: Colors.lightBlue,
        child: InkWell(
          splashColor: Colors.blueGrey,
          child: const Center(child: Text("Upload Video")),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
              return const VideoUploadPage();
            })));
          },
        ),
      ),
      Card(
        color: Colors.lightGreen,
        child: InkWell(
          splashColor: Colors.green,
          child: const Center(child: Text("My Videos")),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
              return const VideoUploadPage();
            })));
          },
        ),
      ),
      Card(
        color: Colors.red,
        child: InkWell(
          splashColor: Colors.redAccent,
          child: const Center(child: Text("My Drills")),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
              return const VideoUploadPage();
            })));
          },
        ),
      ),
      Card(
        color: Colors.yellow,
        child: InkWell(
          splashColor: Colors.yellowAccent,
          child: const Center(child: Text("Community Videos")),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
              return const VideoUploadPage();
            })));
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1,
      children: _buildHomeCards(),
    );
  }
}
