import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;

import 'package:path/path.dart';
import 'package:uipage/pages/library.dart';

import 'confirm.dart';

class Home extends StatefulWidget {
  final List<CameraDescription> cameras;

  const Home({
    Key key,
    @required this.cameras,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  File _image;

  double  _widthLib = 20;
  double _heightLib = 20;

  double _library() {
    setState(() {
      _heightLib +=20;
      _widthLib +=20;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _widthLib -= 20;
        _heightLib -= 20;
      });
    });
  }

  double  _widthGal = 20;
  double _heightGal = 20;

  double _gallery() {
    setState(() {
      _widthGal += 20;
      _heightGal += 20;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _widthGal -= 20;
        _heightGal -= 20;
      });
    });
  }

  void open_gallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      // Open confirmation
    });
  }

  Future<void> takePicture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join (
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      // Attempt to take a picture and log where it's been saved.
      print("Awating taking picture");
      await _controller.takePicture(path);
      print("Setting path: " + path);
      _image = File(path);
      print("Set: " + _image.path);


    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras.first,
      // Define the resolution to use.
      ResolutionPreset.medium,
      enableAudio: false
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.00,
        backgroundColor: Colors.grey[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: FlatButton(
                  child: AnimatedContainer(
                      child: Image.asset('assets/library.png',),
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                        width: _heightLib,
                        height: _heightLib,

                  ),
                  onPressed: (){
                    Navigator.pushNamed(context, '/library');
                    _library();
                  },
                ),
            ),
            Container(
              child: Image.asset('assets/GLMPS.png', width: 80, height: 80,),
            ),
            Container(
              child: FlatButton(
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    width: _widthGal,
                    height: _heightGal,

                    child: Image.asset('assets/gallery.png',)
                ),
                onPressed: (){
                  open_gallery();
                  _gallery();
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                Center(
                  child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller)
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      heightFactor: (MediaQuery.of(context).size.width / MediaQuery.of(context).size.height) * 0.9,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(50, 255, 255, 255),
                            width: 10
                        )
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.photo_camera),
        onPressed: () {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          takePicture().then((value) {
            //Navigator.pushNamed(context, '/confirm');
            print("Then: " + _image.path);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Confirm(image: _image),
              ),
            );
          });
        },
      ),
    );
  }
}