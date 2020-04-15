import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

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

  File _image;

  void open_camera()
  async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  void open_gallery()
  async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
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
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              Divider(
                height: 0,
                color: Colors.grey[800],
              ),
              Expanded(child: Container(child: _image == null ? Text("image holder") : Image.file(_image),)),
              
              FlatButton(
                child:
                CircleAvatar(
                  backgroundImage: AssetImage('assets/camerabutton.png'),
                ),

                onPressed: (){
                  open_camera();
                },
              ),
            ],
          ),
        ),
      ),

    );
  }
}