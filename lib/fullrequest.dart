import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tags/tag.dart';
import 'initiatetalks.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart' as toast;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'logincreds.dart';

Color actualBlack= Color.fromRGBO(0,0,0,1.0);
Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);
Color tealColor=  Colors.teal;

var userData;


class FullRequest extends StatefulWidget {
  FullRequest(this.dataMap, this.cats);
  Map dataMap;
  List<String> cats;

  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();


  int id=0;

  NotificationDetails getPlatformSpecifics(){
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker', color: Colors.teal);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  void firebaseCloudMessaging_Listeners() {
    print("Full Request Firebase");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print(message);
        if(message['data']['type']=='message'){
          await flutterLocalNotificationsPlugin.show(++id, message['data']['sender'], message['data']['message'], getPlatformSpecifics(), payload: jsonEncode(message));
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        if(message['data']['type']=='message'){
          await flutterLocalNotificationsPlugin.show(++id, message['data']['sender'], message['data']['message'], getPlatformSpecifics(), payload: jsonEncode(message));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }


  @override
  _FullRequestState createState() => _FullRequestState();
}

class _FullRequestState extends State<FullRequest> {


  bool _isUserNameEqual;
  int _isTalkPresent=2;
  String myUserName;
  List<Widget> myTalkWidgets=<Widget>[];

  Future checkAndGetData()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    String p= path.join(dir.path, "config.txt");
    io.File _newFile = new io.File(p);
    String o= jsonDecode(_newFile.readAsStringSync())['username'];
    myUserName=o;
    List _chats;
    myTalkWidgets.clear();
    Map temp = {
      'issue_id':'${widget.dataMap['issue_id']}'
    };
    String url = LoginCreds().url;
    url+='getchatsformyissue.php';
    try{
      await http.post(
        url,
        body: temp,
      ).then((http.Response response){
        var resp= jsonDecode(response.body);
        if(resp['status']=="Success"){
          if(o!=widget.dataMap['username']) {
            bool temp1=false;
            _chats = resp['data']['links'].toString().split('&');
            print(_chats);
            for (int i = 0; i < _chats.length; i++) {
              if (o == _chats[i]) {
                myTalkWidgets.add(talkHeading);
                myTalkWidgets.add(Talk1(o, widget.dataMap['username'],"issue${widget.dataMap['issue_id']}_${widget.dataMap['username']}_${_chats[i]}_talk", int.parse(widget.dataMap['issue_id'])));
                temp1=true;
                setState(() {
                  _isTalkPresent=0;
                  _isUserNameEqual = true;
                });
              }
            }
            if(!temp1){
              setState(() {
                _isUserNameEqual = false;
                _isTalkPresent= 1;
              });
            }

          }
          else{
            print("sajdnjsan");
            setState(() {
              _isUserNameEqual=true;
            });
            _chats = resp['data']['links'].toString().split('&');
            print(_chats);
            if(_chats.length>0)
              myTalkWidgets.add(talkHeading);
            for(int i=0; i<_chats.length;i++){
              if(_chats[i]!=''){
                print(_chats[i]);
                myTalkWidgets.add(Talk1(o, _chats[i],"issue${widget.dataMap['issue_id']}_${myUserName}_${_chats[i]}_talk", int.parse(widget.dataMap['issue_id'])));
              }
            }
            if(myTalkWidgets.length>1){
              setState(() {
                _isTalkPresent=0;
              });
            }
          }
        }
        else{
          toast.Toast.show("Unknown Error Occured while fetching Talks. Please Try Again", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          setState(() {
            _isTalkPresent=1;
          });
        }
      }).timeout(Duration(seconds: 5));
    }catch(e){
      toast.Toast.show("Can't get the Talks information. Check your connection and try again.", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
      setState(() {
        _isTalkPresent=1;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _isUserNameEqual=true;
    checkAndGetData();
  }


  Widget talkHeading = Center(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Talks",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: actualWhite,
        ),
      ),
    ),
  );


  Widget myLoader = Center(
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
  );




  @override
  Widget build(BuildContext context) {
    double height= MediaQuery.of(context).size.height;
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 8.0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: actualBlack,),
          title: Text(
            "Request Particular's",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: actualBlack,
              fontWeight: FontWeight.w700,
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
            ),
          ),
          child: SingleChildScrollView(
            dragStartBehavior:  DragStartBehavior.start,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top:9.0,left: 18.0,right: 18.0, bottom: 9.0),
                  child: Card(
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
                              widget.dataMap['subject'],
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
                              widget.dataMap['details'],
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          Divider(
                            height: 10.0,
                            color: actualWhite,
                          ),

                          Visibility(
                            visible: !(widget.cats.length==1 && widget.cats[0]=="all"),
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
                            visible: !(widget.cats.length==1 && widget.cats[0]=="all"),
                            child: Tags(
                              direction: Axis.horizontal,
                              itemCount: widget.cats.length,
                              itemBuilder: (int index){
                                return ItemTags(
                                  key: Key(index.toString()),
                                  index: index,
                                  title: widget.cats[index],
                                  textStyle: TextStyle( color: actualWhite,  fontSize: 17.0, ),
                                  combine: ItemTagsCombine.withTextBefore,
                                  activeColor: myGreen,
                                  color: myGreen,
                                  textActiveColor: actualWhite,
                                  textColor: actualWhite,
                                );
                              },
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
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.dataMap['username'],
                              style: TextStyle(color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Posted on :",
                              style: TextStyle(
                                  color: tealColor,
                                  fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.dataMap['date'],
                              style: TextStyle(color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          Visibility(
                            visible: !_isUserNameEqual,
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              alignment: Alignment.center,
                              child: RaisedButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                color: myGreen,
                                onPressed: (){
                                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)=>Talk(myUserName, widget.dataMap['username'], "issue${widget.dataMap['issue_id']}_${widget.dataMap['username']}_${myUserName}_talk",int.parse(widget.dataMap['issue_id']), widget)));
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                child: Text("Initiate Talks",
                                  style: TextStyle(
                                    color: actualWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.transparent,
                            height: 10.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                (_isTalkPresent==0)?Column(
                  children: myTalkWidgets,
                )
                    :(_isTalkPresent==1)?Divider()
                    :myLoader,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Talk1 extends StatelessWidget {
  Talk1(this.myname, this.receiver, this.talkname, this.issue_id);
  String myname, receiver, talkname;
  int issue_id;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        FullRequest fullRequest;
        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context)=>Talk(myname, receiver, talkname,issue_id, fullRequest)));
      },
      child: Card(
        color: actualWhite,
        margin: EdgeInsets.only(left: 25.0, right: 25.0, bottom: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: myGreen,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      "https://cdn-images-1.medium.com/max/1600/1*yklF4MMnb96xC5zu_QH8Rw.jpeg",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text("$receiver"),
              ),
              Expanded(
                child: Divider(
                  height: 1.0,
                  color: Colors.transparent,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}


