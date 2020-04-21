import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';
import '../dbProvider.dart';
import 'library.dart';
import 'confirm.dart';

class Home extends StatefulWidget {
  final List<CameraDescription> initCameras;

  const Home({Key key, this.initCameras}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  List<CameraDescription> cameras;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  File _image;
  bool _cameraOn = true;

  double  _widthLib = 20;
  double _heightLib = 20;

  void _library() {
    setState(() {
      _heightLib +=20;
      _widthLib +=20;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _widthLib -= 20;
        _heightLib -= 20;
      });
    });
  }

  double  _widthGal = 20;
  double _heightGal = 20;

  void _gallery() {
    setState(() {
      _widthGal += 20;
      _heightGal += 20;
    });
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _widthGal -= 20;
        _heightGal -= 20;
      });
    });
  }

  void openGallery(BuildContext context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      if(_image != null) {
        // Open confirmation
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Confirm(image: _image),
          ),
        );
      }
    });
  }

  Future<void> takePicture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      setState(() { _cameraOn = true; });
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
      await _controller.takePicture(path);
      _image = File(path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Attempt to fix the issue of the camera breaking when opening the app from lock screen
    /*if(widget.initCameras == null) {
      availableCameras().then((value) {
        cameras = value;
        initialiseCamera();
      });
    } else {
      cameras = widget.initCameras;
      initialiseCamera();
    }*/

    initialiseCamera();
  }

  @override
  void deactivate() {
    super.deactivate();
    _cameraOn = false;
    //_controller.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraOn = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      print('Paused');
      _cameraOn = false;
    }
    if(state == AppLifecycleState.resumed)
    {
      print('Resumed');
      _cameraOn = true;
      _initializeControllerFuture;
    }
    super.didChangeAppLifecycleState(state);
  }

  void initialiseCamera()  {
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
        widget.initCameras.first, // change to cameras.first if using the attempted fix above
        // Define the resolution to use.
        ResolutionPreset.medium,
        enableAudio: false
    );
    _cameraOn = true;
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    _cameraOn = true;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.00,
        backgroundColor: Colors.grey[900],
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: FlatButton(
                        child: AnimatedContainer(
                            child: Image.asset('assets/library.png',),
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              width: _heightLib,
                              height: _widthLib,

                        ),
                        onPressed: (){
                          _library();
                          DbProvider().getAlbums().then((value){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Library(albums: value)
                                )
                            );
                          });
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
                        _gallery();
                        openGallery(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                      child: _cameraOn ? CameraPreview(_controller) : Container()
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
          takePicture().then((value) {
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