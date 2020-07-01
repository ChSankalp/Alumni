import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tags/tag.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart' as toast;
import 'dart:convert';
import 'fullrequest.dart';
import 'initiatetalks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'logincreds.dart';

Color actualBlack= Color.fromRGBO(0,0,0,1.0);
Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);
Color tealColor=  Colors.teal;

var data;

class StudentHeadMainPage extends StatefulWidget {
  Map userData;
  StudentHeadMainPage(this.userData);
  @override
  _StudentHeadMainPageState createState() => _StudentHeadMainPageState();
}

class _StudentHeadMainPageState extends State<StudentHeadMainPage> {
  @override
  int _present=2;
  int _pagestate=0;
  int pagetype=0;
  String filters;
  String noDataString;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  FirebaseMessaging _firebaseMessaging= new FirebaseMessaging();


  NotificationDetails getPlatformSpecifics(){
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker', color: Colors.teal);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token){
      print(token);
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        if(message['data']['type']=='message'){
          await flutterLocalNotificationsPlugin.show(0, message['data']['sender'], message['data']['message'], getPlatformSpecifics(), payload: jsonEncode(message));
        }
        else{

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



  Future<String> getTokenPath()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, "config.txt");
  }

  Future deleteToken() async{
    io.File file= new io.File(await getTokenPath());
    file.deleteSync();
  }



  Future logout() async {
    await getTokenPath().then((String path) async {
      Map profileData = jsonDecode(io.File(path).readAsStringSync());
      Map temp = {
        'username': '${profileData['username']}',
        'type': '${profileData['type']}'
      };
      String url = LoginCreds().url;
      url += 'logout.php';
      try {
        await http.post(
          url,
          body: temp,
        ).then((http.Response response) {
          var res = jsonDecode(response.body);
          if (res['status'] == 'Success') {
            deleteToken().then((dynamic){
              Navigator.pop(context);
              Navigator.pop(context);
            });
          }
          else {
            toast.Toast.show(
                "Log Out Error. PLease Try Again!", context, duration: 4,
                backgroundColor: actualWhite,
                textColor: myGreen);
          }
        }).timeout(Duration(seconds: 5));
      }catch(e){
        toast.Toast.show(
            "Error. Please Check Internet COnnectivity.", context, duration: 4,
            backgroundColor: actualWhite,
            textColor: myGreen);
      }
    });
  }


  Future getData() async{
    String typeOfProfile= (pagetype==0)?"student":"alumni";
    String miniUrl= (_pagestate==0)?"getactiveissues":"getacceptedrequests";
    Map tempMap = {};

    if (_pagestate == 0)
      tempMap = {
        'type': '$typeOfProfile',
        'typeOfProfile': 'studenthead',
        'categories': 'all'
      };
    else
      tempMap = {
        'type': '$typeOfProfile',
      };
    String url = LoginCreds().url;
    url += '$miniUrl.php';
    print(url);
    try {
      await http.post(
        url,
        body: tempMap,
      ).then((http.Response response) {
        data = jsonDecode(response.body);
        if (data['status'] == "Success") {
          setState(() {
            _present = 0;
          });
        }
        else if (data['status'] == "No Data Present")
          setState(() {
            noDataString = "No Requests found...!";
            _present = 1;
          });
        else
          setState(() {
            noDataString = "Unknown Error Occured.\nPlease Try Again";
            _present = 1;
          });
      }).timeout(Duration(seconds: 5));
    } catch (e) {
      setState(() {
        noDataString =
        "Error Retreiving Data. \n\nClick to try again. \nCheck for the Internet Connectivity issues, if any.";
        _present = 1;
      });
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Map temp= jsonDecode(payload);
    FullRequest fullRequest;
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new Talk(temp['receiver'], temp['sender'], temp['talkname'], int.parse(temp['issue_id']), fullRequest)),
    );
  }

  void initState(){
    super.initState();
    _pagestate=0;
    pagetype=0;
    getData();
  }


  Widget build(BuildContext context) {
    double ht= MediaQuery.of(context).size.height;
    double wt= MediaQuery.of(context).size.width;
    return SafeArea(
        top: true,
        child: Scaffold(
            backgroundColor: actualWhite,
            appBar: AppBar(
              centerTitle: true,
              elevation: 8.0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: true,
              iconTheme: IconThemeData(color: Colors.black,),
              title: Text(
                  "Student's Head Main Page",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: actualBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          bottomNavigationBar: BottomAppBar(
            color: Color.fromRGBO(255,255,255,1.0),
            elevation: 4.0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: CircularNotchedRectangle(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: FlatButton.icon(
                    onPressed: (){
                      setState(() {
                        pagetype=0;
                        _present=2;
                        data=null;
                      });
                      getData();
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.person, color: (pagetype==0)?myGreen:actualBlack,),
                    label: Text("Student",
                      style: new TextStyle(
                        color: (pagetype==0)?myGreen:actualBlack,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton.icon(
                    onPressed: (){
                      setState(() {
                        pagetype=1;
                        _present=2;
                        data=null;
                      });
                      getData();
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.school, color: (pagetype==1)?myGreen:actualBlack),
                    label: Text("Alumni",
                      style: new TextStyle(
                        color: (pagetype==1)?myGreen:actualBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          drawer: new Drawer(
            elevation: 0.0,
            child: Container(
              color: actualWhite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text('Dashboard', style: TextStyle(
                        fontSize: 18.0,

                      ),),
                      margin: EdgeInsets.all(15.0),
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 2.0,
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(0.0),
                      onPressed: (){
                        setState(() {
                          _pagestate=0;
                          Navigator.pop(context);
                          _present=2;
                          data=null;
                        });
                        getData();
                      },
                      color: (_pagestate==0)?myGreen:actualWhite,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 35.0,top: 18.0, bottom: 18.0),
                        child: Text('Active Requests',
                          style: TextStyle(
                            color: (_pagestate==0)?Colors.white:Colors.black,
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(0.0),
                      onPressed: (){
                        setState(() {
                          _pagestate=1;
                          Navigator.pop(context);
                          _present=2;
                          data=null;
                        });
                        getData();
                      },
                      color: (_pagestate==1)?myGreen:actualWhite,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 35.0,top: 18.0, bottom: 18.0),
                        child: Text('Accepted Requests',
                          style: TextStyle(
                            color: (_pagestate==1)?Colors.white:Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 35.0,
                      color: Colors.grey,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Profile ${widget.userData['username']} : ",
                          style: new TextStyle(
                            color: actualBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Colors.grey,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              "https://cdn-images-1.medium.com/max/1600/1*yklF4MMnb96xC5zu_QH8Rw.jpeg",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Student Head\n\n${widget.userData['fullname']}\n${widget.userData['presentdesignation']}\nExp. Pass Out : ${widget.userData['passedoutyear']}",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: (){
                            logout();
                          },
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            color: actualWhite,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Log Out",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: myGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color.fromRGBO(2,170,176,1.0), Color.fromRGBO(0,205,172,1.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    stops: [0.0,1.0],
                    tileMode: TileMode.mirror
                )
            ),
            child: (_present==0)?Container(
              color: Colors.transparent,
              child: (_pagestate==0)?ActiveRequests(this):ProcessedRequests(_pagestate),
            ):(_present==1)?Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: FlatButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: (){
                          setState(() {
                            _present=2;
                          });
                          getData();
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            SpinKitRipple(
                              color: actualWhite,
                              size: 90.0,
                              duration: Duration(milliseconds: 1000),
                            ),
                            Icon(
                              Icons.error_outline,
                              size: 55.0,
                              color: actualWhite,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      noDataString,
                      style: TextStyle(color: actualWhite, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ):Center(
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
                )
            ),
          ),
      ),
    );
  }
}

class ActiveRequests extends StatefulWidget {
  ActiveRequests(this.parent);
  _StudentHeadMainPageState parent;
  @override
  _ActiveRequestsState createState() => _ActiveRequestsState(parent);
}

class _ActiveRequestsState extends State<ActiveRequests> {
  _ActiveRequestsState(this.parent);
  _StudentHeadMainPageState parent;
  final GlobalKey<AnimatedListState> _list2Key = new GlobalKey();

  @override
  Widget build(BuildContext context){
    return Container(
      child: AnimatedList(
        key: _list2Key,
        itemBuilder: (BuildContext context, int index, animation)=> StudentHeadActiveRequest(index, this.parent),
        initialItemCount: data['data'].length,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      ),
    );
  }
}

class ProcessedRequests extends StatefulWidget {
  ProcessedRequests(this._pagestate);
  int _pagestate;
  @override
  _ProcessedRequestsState createState() => _ProcessedRequestsState();
}

class _ProcessedRequestsState extends State<ProcessedRequests> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index)=>MyOrLinkedRequest(index, widget._pagestate),
        itemCount: data['data'].length,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      ),
    );
  }
}



class StudentHeadActiveRequest extends StatefulWidget {
  StudentHeadActiveRequest(this.index, this.parent);
  int index;
  _StudentHeadMainPageState parent;
  @override
  _StudentHeadActiveRequestState createState() => _StudentHeadActiveRequestState();
}

class _StudentHeadActiveRequestState extends State<StudentHeadActiveRequest> {
  List<String> cats = <String>[];




  Future submitHeadResponse(int id,  String response) async{
    Map tempMap={
      'issue_id': '$id',
      'myresponse': '$response'
    };

    String url = LoginCreds().url;
    url+='headresponse.php';
    try{
      await http.post(
        url,
        body: tempMap,
      ).then((http.Response response){
        data= jsonDecode(response.body);
        if(data['status']=="Success"){
          toast.Toast.show("Response Updated", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          widget.parent.setState((){
            widget.parent._present= 2;
          });
          widget.parent.getData();
        }
        else
          toast.Toast.show("Fail. Please Try Again", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);

      }).timeout(Duration(seconds: 5));
    }catch (e){
      toast.Toast.show("Unknown Error Occured while Updating Response. Please Try Again", context,  duration: 2, backgroundColor: actualWhite, textColor: myGreen);

    }
  }




  @override
  void initState() {
    setState(() {
      this.cats= data['data'][widget.index]['categories'].toString().split('&');
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    double height= MediaQuery.of(context).size.height;
    return  Container(
      margin: EdgeInsets.only(top:9.0,left: 18.0,right: 18.0, bottom: 9.0),
      child:Card(
        color: actualWhite,
        borderOnForeground: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0.0,
        margin: EdgeInsets.only(top:5.0, left: 5.0,right: 5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top:18.0, right: 18.0, left: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Subject",
                      style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                    ),
                    Image.asset("icons/descibe1.png", height: height/30, width: height/30, color: tealColor, ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['subject'],
                  maxLines: 2,
                  style: TextStyle(color: actualBlack,),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Details",
                  style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['details'],
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  textAlign: TextAlign.justify,
                ),
              ),//The Synopsis Data

              Divider(
                height: 10.0,
                color: Colors.white,
              ),

              Visibility(
                visible: !(cats.length==1 && cats[0]=="all"),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Category:",
                        style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                      ),
                      Image.asset("icons/category.png", height: height/30, width: height/30, color: tealColor,),
                    ],
                  ),
                ),
              ),

              Visibility(
                visible: !(cats.length==1 && cats[0]=="all"),
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Tags(

                    direction: Axis.horizontal,
                    itemCount: this.cats.length,
                    itemBuilder: (int index){
                      return ItemTags(
                        key: Key(index.toString()),
                        index: index,
                        title: this.cats[index],
                        elevation: 1.0,
                        textStyle: TextStyle( color: actualWhite,  fontSize: 15.0, ),
                        combine: ItemTagsCombine.withTextBefore,
                        activeColor: myGreen,
                        color: myGreen,
                        textActiveColor: actualWhite,
                        textColor: actualWhite,
                      );
                    },
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Posted By:",
                      style: TextStyle(
                        color: tealColor,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                    ),
                    Icon(Icons.person_outline, color: tealColor,),
                  ],
                ),
              ),//This is heading. No need to add variable.



              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['username'],
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: RaisedButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        color: myGreen,
                        onPressed: (){
                          Map tempMap = {
                            'issue_id': '${data['data'][widget.index]['id']}',
                            'subject': '${data['data'][widget.index]['subject']}',
                            'details': '${data['data'][widget.index]['details']}',
                            'username': '${data['data'][widget.index]['username']}',
                            'status': '${data['data'][widget.index]['status']}',
                            'date':'${data['data'][widget.index]['updateDate']}'
                          };
                          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)=>FullRequest(tempMap, cats)));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text("View Request",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: actualWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: RaisedButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        color: myGreen,
                        onPressed: (){
                          submitHeadResponse(int.parse(data['data'][widget.index]['id']), 'Active');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text("Accept",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: actualWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: RaisedButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        color: myGreen,
                        onPressed: (){
                          submitHeadResponse(int.parse(data['data'][widget.index]['id']), 'Rejected');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text("Reject",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: actualWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyOrLinkedRequest extends StatefulWidget {
  MyOrLinkedRequest(this.index,  this._pagestate);
  int index, _pagestate;
  @override
  _MyOrLinkedRequestState createState() => _MyOrLinkedRequestState();
}

class _MyOrLinkedRequestState extends State<MyOrLinkedRequest> {

  List<String> cats = <String>[];



  @override
  void initState() {
    setState(() {
      this.cats= data['data'][widget.index]['categories'].toString().split('&');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height= MediaQuery.of(context).size.height;
    return  Container(
      margin: EdgeInsets.only(top:9.0,left: 18.0,right: 18.0, bottom: 9.0),
      child:Card(
        color: Colors.white,
        borderOnForeground: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 0.0,
        margin: EdgeInsets.only(top:5.0, left: 5.0,right: 5.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Padding(
          padding: EdgeInsets.only(top:18.0, right: 18.0, left: 18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Subject",
                      style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                    ),
                    Image.asset("icons/descibe1.png", height: height/30, width: height/30, color: tealColor, ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['subject'],
                  maxLines: 2,
                  style: TextStyle(color: actualBlack,),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Details",
                  style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['details'],
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                  textAlign: TextAlign.justify,
                ),
              ),//The Synopsis Data

              Divider(
                height: 10.0,
                color: Colors.white,
              ),

              Visibility(
                visible: !(cats.length==1 && cats[0]=="all"),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Category:",
                        style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                      ),
                      Image.asset("icons/category.png", height: height/30, width: height/30, color: tealColor,),
                    ],
                  ),
                ),
              ),

              Visibility(
                visible: !(cats.length==1 && cats[0]=="all"),
                child: Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Tags(
                    direction: Axis.horizontal,
                    itemCount: this.cats.length,
                    itemBuilder: (int index){
                      return ItemTags(
                        key: Key(index.toString()),
                        index: index,
                        title: this.cats[index],
                        textStyle: TextStyle( color: actualWhite,  fontSize: 15.0,),
                        elevation: 1.0,
                        combine: ItemTagsCombine.withTextBefore,
                        activeColor: myGreen,
                        color: myGreen,
                        textActiveColor: actualWhite,
                        textColor: actualWhite,
                      );
                    },
                  ),
                ),
              ),
              Visibility(
                visible: (widget._pagestate==2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Posted By:",
                        style: TextStyle(
                          color: tealColor,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                      ),
                      Icon(Icons.person_outline, color: tealColor,),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: (widget._pagestate==2),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data['data'][widget.index]['username'],
                    style: TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Posted By: ",
                  style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['username'],
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Status",
                      style: TextStyle(color: tealColor, fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                    ),
                    Icon(Icons.done_all,  color: tealColor,)
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data['data'][widget.index]['status'],
                  style: TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(10.0),
                child: RaisedButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  color: myGreen,
                  onPressed: (){
                    Map tempMap = {
                      'issue_id': '${data['data'][widget.index]['id']}',
                      'subject': '${data['data'][widget.index]['subject']}',
                      'details': '${data['data'][widget.index]['details']}',
                      'username': '${data['data'][widget.index]['username']}',
                      'status': '${data['data'][widget.index]['status']}',
                      'date':'${data['data'][widget.index]['updateDate']}'
                    };
                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)=>FullRequest(tempMap,cats)));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Text("View Whole Request",
                    style: TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



