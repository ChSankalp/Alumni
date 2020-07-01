import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'logincreds.dart';
import 'studentHeadPage.dart';
import 'studentPage.dart';
import 'alumniMain.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart' as toast;
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'initiatetalks.dart';
import 'package:image_picker/image_picker.dart' as imgPicker;

Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);


class EntryPage extends StatefulWidget {
  EntryPage(this.type);
  int type;

  @override
  _EntryPageState createState() => _EntryPageState(type);
}

class _EntryPageState extends State<EntryPage> with SingleTickerProviderStateMixin {
  _EntryPageState(this.type);
  int type;

  Talk talk;

  Map data = {
    'username':'',
    'email':'',
    'type':'',
    'password':'',
    'fullname':'',
    'passedoutyear':'',
    'designation':'',
  };

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  Future<String> getTokenPath()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, "config.txt");
  }


  io.File image;

  Future getImage() async {
    await imgPicker.ImagePicker.pickImage(source: imgPicker.ImageSource.gallery).then((io.File file){
      setState(() {
        image = file;
      });
    });
  }

  List<String> preferences = <String> ["a","b","c"];
  List<bool> isPrefSet = <bool> [true, false,true];

bool jj=false;


  void checkData() async {
    if(data['fullname']=='' || data['passedoutyear']=='' || data['designation']=='' || data['preferences']=='') {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: actualWhite,
              contentPadding: EdgeInsets.all(20.0),
              title: Text("Fill your details", textAlign: TextAlign.center,),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.grey[200],
                  ),
                  width: 250.0,
                  child: TextField(
                    controller: fullName,
                    style: TextStyle(
                      color: myGreen,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Full Name",
                    ),
                    cursorRadius: Radius.circular(10.0),
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.grey[200],
                  ),
                  width: 250.0,
                  child: TextField(
                    controller: passedOutYear,
                    keyboardType: TextInputType.numberWithOptions(),
                    style: TextStyle(
                      color: myGreen,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Passed Out Year",
                    ),
                    cursorRadius: Radius.circular(10.0),
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.grey[200],
                  ),
                  width: 250.0,
                  child: TextField(
                    controller: presentDesignation,
                    style: TextStyle(
                      color: myGreen,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Present Designation",
                    ),
                    cursorRadius: Radius.circular(10.0),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    color: myGreen,
                    onPressed: () {
                      data['fullname'] = fullName.text;
                      data['passedoutyear'] = passedOutYear.text;
                      data['designation'] = presentDesignation.text;
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Text("Done",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: actualWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              ],
            );
          }
      );
    }
    else{

      if(signUpUsername.text.contains(' ') || signUpSetPassword.text.contains(' ')){
        toast.Toast.show("Username or Password should contain only Alphabets or Numbers.", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
      }
      else if (signUpSetPassword.text!=signUpReTypePassword.text){
        toast.Toast.show("Passwords dont match!", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
      }
      else{
        data['username']=signUpUsername.text;
        data['password']=signUpSetPassword.text;
        data['email']=signUpEmail.text;
        signUpAsUser();
      }

    }
  }

  Future setToken(String token)async{
    final p= await getTokenPath();
    io.File file= new io.File(p);
    file.writeAsStringSync(token);
  }


  bool _visible = true;
  void changeVisibility() {
    setState(() {
      _visible = !_visible;
    });
  }



  Future loginAsUser(String username, String password) async {
    String device_id;
    _firebaseMessaging.getToken().then((token)async{
      device_id=token;
      String loginType=(type==0)?'alumni':(type==1)?'studenthead':'student';
      Map loginCreds= {
        'username':'$username',
        'password':'$password',
        'type':'$loginType',
        'device_id':'$device_id'
      };
      print(loginCreds);
      String url = LoginCreds().url;
      url+='login.php';
      print(url);
      try{
        await http.post(
          url,
          body: loginCreds,
        ).then((http.Response response){

          var res= jsonDecode(response.body);
          if(res['status']=="Success")
          {

            toast.Toast.show("Log In Successful.", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);

            Map tmp= {
              'username':'$username',
              'type':'$loginType',
              'device_id': '$device_id',
              'fullname': '${res['data'][0]['fullname']}',
              'passedoutyear':'${res['data'][0]['passedoutyear']}',
              'presentdesignation':'${res['data'][0]['presentdesignation']}',
              'pro_pic_url':''
            };
            print(res);
            setToken(jsonEncode(tmp)).then((dynamic){
              firebaseCloudMessaging_Listeners();
              Navigator.push(context, new MaterialPageRoute(builder: (context)=>(tmp['type']=='alumni')?AlumniMainPage(tmp):(tmp['type']=='studenthead')?StudentHeadMainPage(tmp):StudentPage(tmp)));
            });
          }
          else if (res['status']=="Wrong Password!"){
            toast.Toast.show("Wrong Password!", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          }
          else{
            toast.Toast.show("Log In Unsuccessful. Ensure you have an Account, else Sign In", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          }
        }).timeout(Duration(seconds: 2));
      }catch(e){
        print(e);
        toast.Toast.show("Error. Check your Internet Connection", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
      }
    });
  }


  Future signUpAsUser() async{
    String signUpType=(type==0)?'alumni':(type==1)?'studenthead':'student';
    data['type']=signUpType;
    print(data);
    String url = LoginCreds().url;
    url+='signup.php';
    try{
      await http.post(
        url,
        body: data,
      ).then((http.Response response){
        var res= jsonDecode(response.body);
        if(res['status']=="Success")
        {
          toast.Toast.show(
              "Sign Up Successful. Login for the first time.",
              context,
              duration: 4,
              backgroundColor: actualWhite,
              textColor: myGreen,
          );
          changeVisibility();
        }
        else if (res['status']=="Account already activated on this UserName/Email. Please verify the credentials or login."){
          toast.Toast.show(
              "Username/Email already taken.!",
              context,
              duration: 4,
              backgroundColor: actualWhite,
              textColor: myGreen,
          );
        }
        else{
          toast.Toast.show(
            "Unknown Error. Please try again.",
            context,
            duration: 4,
            backgroundColor: actualWhite,
            textColor: myGreen,
          );
        }
      }).timeout(Duration(seconds: 5));
    }catch(e){
      print(e);
      toast.Toast.show("Error. Check your Internet Connection", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
    }

  }

  NotificationDetails getPlatformSpecifics(){
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker', color: Colors.teal);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  int id=0;

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token){
      print(token);
    });
    _firebaseMessaging.setAutoInitEnabled(true);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        if(message['data']['type']=='message'){
          await flutterLocalNotificationsPlugin.show(++id, message['data']['sender'], message['data']['message'], getPlatformSpecifics(), payload: jsonEncode(message));
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  final loginEmail = new TextEditingController();
  final loginPassword = new TextEditingController();
  final signUpEmail = new TextEditingController();
  final signUpUsername = new TextEditingController();
  final signUpSetPassword = new TextEditingController();
  final signUpReTypePassword = new TextEditingController();
  final fullName = new TextEditingController();
  final passedOutYear = new TextEditingController();
  final presentDesignation = new TextEditingController();


  AnimationController controller;
  Animation<double> animation;


  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 10000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    Widget LoginPageView= Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white
          ),
          width: 250.0,


          child: TextField(
            controller: loginEmail,
            style: TextStyle(
              color: myGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Username",
            ),
            cursorRadius: Radius.circular(10.0),
          ),
        ),

        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white
          ),
          width: 250.0,
          child: TextField(
            controller: loginPassword,
            style: TextStyle(
              color: myGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Password",
            ),
            obscureText: true,
            cursorRadius: Radius.circular(10.0),
          ),
        ),
      ],
    );


    Widget SignUpPageView= Column(

      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white
          ),
          width: 250.0,
          child: TextField(
            controller: signUpUsername,
            style: TextStyle(
              color: myGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter username",
            ),
            cursorRadius: Radius.circular(10.0),
          ),
        ),

        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white
          ),
          width: 250.0,
          child: TextField(
            controller: signUpEmail,
            style: TextStyle(
              color: myGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter email-address",
            ),
            cursorRadius: Radius.circular(10.0),
          ),
        ),

        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white
          ),
          width: 250.0,
          child: TextField(
            controller: signUpSetPassword,
            style: TextStyle(
              color: myGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Set a Password",
            ),
            obscureText: true,
            cursorRadius: Radius.circular(10.0),
          ),
        ),

        Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.white
          ),
          width: 250.0,
          child: TextField(
            controller: signUpReTypePassword,
            style: TextStyle(
              color: myGreen,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Re-Type the password",
            ),
            obscureText: true,
            cursorRadius: Radius.circular(10.0),
          ),
        ),
      ],
    );




    double _height= MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
       body: Stack(
         fit: StackFit.passthrough,
         children: <Widget>[
           Container(
             height: _height,
               decoration: BoxDecoration(
                   gradient: LinearGradient(
                       colors: [Color.fromRGBO(2,170,176,1.0), Color.fromRGBO(0,205,172,1.0)],
                       begin: Alignment.topCenter,
                       end: Alignment.bottomCenter,
                       stops: [0.0,1.0],
                       tileMode: TileMode.mirror
                   ),
               ),
               child: SingleChildScrollView(
                 child: Column(
                   children: <Widget>[
                     Divider(
                       color: Colors.transparent,
                       height: 50.0,
                     ),
                     AnimatedContainer(
                       duration: Duration(milliseconds: 150),
                       constraints: BoxConstraints(maxWidth: _visible?200.0:150.0, maxHeight: _visible?200.0:150.0),
                       child: Hero(
                           tag: "IconTag",
                           child: Image.asset("assets/logo.png")),
                     ),

                     Divider(
                       color: Colors.transparent,
                       height: 15.0,
                     ),

                   Container(
                     child: Center(
                       child: Text("${(type==0)?"Alumni":(type==1)?"Student Head":"Student"} ${_visible?"Login":"Signup"}",
                         style: new TextStyle(
                           color: actualWhite,
                           fontWeight: FontWeight.w700,
                         ),
                         textAlign: TextAlign.center,
                       ),
                     ),
                   ),
                     Divider(
                       color: Colors.transparent,
                       height: 15.0,
                     ),
                  _visible?LoginPageView:SignUpPageView,




                     Divider(
                       color: Colors.transparent,
                       height: 15.0,
                     ),
                     FlatButton(
                       splashColor: Colors.transparent,
                       highlightColor: Colors.transparent,
                       onPressed: (){
                         if(_visible){
                           loginAsUser(loginEmail.text, loginPassword.text);
                         }
                         else{
                         checkData();
                         }
                         },
                       child: AnimatedContainer(
                         duration: Duration(seconds: 1),
                         margin: EdgeInsets.all(12.0),
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(50.0),
                             color: actualWhite
                         ),
                         width: 150.0,
                         height: 40.0,
                         child: Center(
                           child: Text(
                             _visible?"Login":"Signup",
                             style: TextStyle(
                               color: myGreen,
                               fontWeight: FontWeight.w700,
                             ),
                           ),
                         ),
                       ),
                     ),

                     Visibility(
                       visible: type!=1,
                       child: FlatButton(
                         highlightColor: Colors.transparent,
                         splashColor: Colors.transparent,
                         onPressed: (){
                           changeVisibility();
                         },
                         child: Text(
                           _visible?"Don't Have an Account?\nSign Up Instead.":"Already have an account?\nLogin Instead.",

                           style: TextStyle(
                             //decoration: TextDecoration.underline,
                             color: actualWhite,
                             fontWeight: FontWeight.w700,
                           ),
                           textAlign: TextAlign.center,

                         ),
                       ),
                     ),

                     Divider(
                       color: Colors.transparent,
                       height: 15.0,
                     ),
                   ],
                 ),
               ),

             ),
           Align(alignment: Alignment.topLeft,
           child: IconButton(icon: Icon(Icons.clear, color: Colors.white,), onPressed: ()=>Navigator.pop(context)),)
         ],
       ),
       ),
    );

  }
}



//TODO:
/*
* get talks and list of talks
* All firebase functions
* send message
* receive message
* */