import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'login.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'studentHeadPage.dart';
import 'alumniMain.dart';
import 'studentPage.dart';

Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);

Color c= Color(0x43cea2);

void main() =>
    runApp(new MaterialApp(

      home: LoginPage(),
      title: "Alumni Project",
      theme: ThemeData(
      fontFamily: 'Ubuntu',
    ),
      debugShowCheckedModeBanner: false,
    ));

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  int a;



  AnimationController controller;
  Animation<double> animation;


  int loginTokenCheck;

  Future<String> getTokenPath()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, "config.txt");
  }


  Future checkToken() async{
    final p= await getTokenPath();
    io.File file= new io.File(p);
    bool check= await file.exists();
    if(check) {
      setState(() {
        loginTokenCheck=0;
        print(file.readAsStringSync());
        Map tmp= jsonDecode(file.readAsStringSync());
        Navigator.push(context, new MaterialPageRoute(builder: (context)=>(tmp['type']=='alumni')?AlumniMainPage(tmp):(tmp['type']=='studenthead')?StudentHeadMainPage(tmp):StudentPage(tmp )));
      });
    }
    else{
      setState(() {
        loginTokenCheck=0;
      });
    }
  }



  initState() {
    super.initState();
    loginTokenCheck=1;
    checkToken();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  dispose(){
    super.dispose();
    controller.dispose();
  }





  @override
  Widget build(BuildContext context) {

    Widget Loader= Column(

      children: <Widget>[
    Center(
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SpinKitRipple(
          color: actualWhite,
          size: 90.0,
          duration: Duration(milliseconds: 1000),
        ),
        SpinKitChasingDots(
          color: actualWhite,
          size: 25.0,
          duration: Duration(milliseconds: 1000),
        ),
      ],
    ),
    ),
        Text("Checking Login Status",
          style: new TextStyle(
            color: actualWhite,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );


    Widget threeButtons= Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: animation,
          child: Center(
            child: Text("Select type of account ",
              style: new TextStyle(
                color: actualWhite,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),//Just a text that asks to select the type of account.
        FadeTransition(
          opacity: animation,
          child: FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: (){
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>EntryPage(0)));
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.white
              ),
              width: 200.0,
              height: 50.0,
              child: Center(
                child: Text(
                  "Alumni",
                  style: TextStyle(
                    color: myGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),// To Navigate to Alumni login


        FadeTransition(
          opacity: animation,
          child: FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: (){
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>EntryPage(1)));
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.white
              ),
              width: 200.0,
              height: 50.0,
              child: Center(
                child: Text(
                  "Student Head",
                  style: TextStyle(
                    color: myGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),//To Navigate to Student head Login


        FadeTransition(
          opacity: animation,
          child: FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: (){
              Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>EntryPage(2)));
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: Colors.white
              ),
              width: 200.0,
              height: 50.0,
              child: Center(
                child: Text(
                  "Student",
                  style: TextStyle(
                    color: myGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),// To Navigate to student login.
      ],
    );

    double ht= MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
      body: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [Color.fromRGBO(2,170,176,1.0), Color.fromRGBO(0,205,172,1.0)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0,1.0],
      tileMode: TileMode.mirror
      ),
      ),
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Divider(
            height: ht/8,
            color: Colors.transparent,
          ),
        Container(
          constraints: BoxConstraints(maxWidth: 250.0, maxHeight: 250.0),
        child: Hero(
            tag: "IconTag",
            child: Image.asset("assets/logo.png")),
        ),
          Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child:Visibility(
                  visible: (loginTokenCheck==0),
                    child: threeButtons,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child:Visibility(
                  visible: (loginTokenCheck==1),
                  child: Loader,
                ),
              ),
            ],
          ),


        ],

        ),
      ))),
    );
  }
}



/*
*

*
*
* */