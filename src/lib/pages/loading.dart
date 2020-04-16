import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class Loading extends StatefulWidget {
  @override
  _loadingState createState() => _loadingState();
}

class _loadingState extends State<Loading> {

  double  _width = 200;
  double _height = 100;

  double _enlarge() {
    setState(() {
      _width = 230;
      _height = 130;
    });
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _width = 200;
        _height = 100;
      });
      Future.delayed(Duration(seconds: 2), () {
        _enlarge();
      });
    });
  }

  /*
  void getData() {
    //simulated, will just use delay, more of a pretty splash screen
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushNamed(context, '/home');
    });

  }*/

  @override
  void initState() {
    super.initState();
    //getData();
    _enlarge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.bounceOut,
                width: _width,
                height: _height,
                color: Colors.grey[900],
                child: Image.asset('assets/GLMPS.png'),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/home');
                },
                color: Colors.green[600],
                child: Text('Start Scanning',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.green[600]),
                ),
              ),
              FlatButton(
                child: Text('About',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline
                  ),),
                onPressed: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        )

    );
  }
}
