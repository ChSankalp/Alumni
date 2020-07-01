import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart' as toast;
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as f;
import 'logincreds.dart';
import 'fullrequest.dart';

Color actualBlack= Color.fromRGBO(0,0,0,1.0);
Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);
Color tealColor=  Colors.teal;

List<Message> _messages =<Message>[];
List<bool> _messageStatus = <bool>[];


class Talk extends StatefulWidget {
  Talk(this.myname, this.receiver, this.talkname, this.issue_id, this.parent);
  FullRequest parent;
  String myname, receiver, talkname;
  int issue_id;
  @override
  _TalkState createState() => _TalkState();
}

class _TalkState extends State<Talk> {

  final GlobalKey<AnimatedListState> _list2Key = new GlobalKey();
  FirebaseMessaging _firebaseMessaging= new FirebaseMessaging();
  f.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new f.FlutterLocalNotificationsPlugin();
  ScrollController controller1 = new ScrollController();

  f.NotificationDetails getPlatformSpecifics(){
    var androidPlatformChannelSpecifics = f.AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: f.Importance.Max, priority: f.Priority.High, ticker: 'ticker', color: Colors.teal);
    var iOSPlatformChannelSpecifics = f.IOSNotificationDetails();
    return f.NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  int id=0;

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if(message['data']['type']=='message' && message['data']['talkname']==widget.talkname){
          final time = new TimeOfDay.fromDateTime(DateTime.now());
          print(message['data']);
          Message j = new Message(message['data']['sender'].toString(), message['data']['receiver'].toString(), message['data']['message'].toString(), time, true);
          receiveMyMessage(j);
        }
        else{
          await flutterLocalNotificationsPlugin.show(0, message['data']['sender'], message['data']['message'], getPlatformSpecifics(), payload: jsonEncode(message));
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


  Future getMessageList() async {
    Map temp={
      'talkname':'${widget.talkname}'
    };
    String url = LoginCreds().url;
    url+='getmessages.php';
    try{
      await http.post(
        url,
        body: temp,
      ).then((http.Response response){
        var resp= jsonDecode(response.body);
        if(resp['status']=="Success"){
          for (int i=0; i<resp['data'].length; i++){
            Message tmsg = new Message(resp['data'][i]['sender'], resp['data'][i]['receiver'], resp['data'][i]['message'], TimeOfDay.now(), true);
            _messageStatus.insert(0, true);
            _messages.insert(0, tmsg);
            _list2Key.currentState.insertItem(0);
          }
          SchedulerBinding.instance.addPostFrameCallback((_) {
            controller1.animateTo(
              controller1.position.maxScrollExtent,
              duration: const Duration(milliseconds: 10),
              curve: Curves.easeOut,);
          });
        }
      }).timeout(Duration(seconds: 5));
    }catch(e){
      print(e);
    }
    
  }

  Future<String> getPath()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, "config.txt");
  }

  Future<String> getTokenPath()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, "config.txt");
  }

  void sendMyMessage(String messageText)async{
    await getTokenPath().then((String filePath){
      io.File _newFile = new io.File(filePath);
      String myusername = jsonDecode(_newFile.readAsStringSync())['username'];
      final time= new TimeOfDay.fromDateTime(DateTime.now());
      Message message = new Message(myusername, widget.receiver ,messageText,  time, false);
      _messageStatus.insert(_messages.length, false);
      _messages.insert(_messages.length,message);
      _list2Key.currentState.insertItem(_messages.length-1, duration: Duration(milliseconds: 100));
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller1.animateTo(
          controller1.position.maxScrollExtent,
          duration: const Duration(milliseconds: 10),
          curve: Curves.easeOut,);
      });
    });
}

  void receiveMyMessage(Message msg){
    _messageStatus.insert(_messages.length, true);
    _messages.insert(_messages.length, msg);
    _list2Key.currentState.insertItem(_messages.length-1, duration: Duration(milliseconds: 100));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller1.animateTo(
        controller1.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,);
    });
  }

  @override
  void initState(){
    super.initState();
    _messages.clear();
    _messageStatus.clear();
    getMessageList();
    firebaseCloudMessaging_Listeners();
  }


  @override
  void dispose() {
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
    super.dispose();
  }

  final messageController=  new TextEditingController();
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
            "${widget.receiver}",
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
          padding: EdgeInsets.only(left: 2.0,right: 2.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: AnimatedList(
                  shrinkWrap: false,
                  key: _list2Key,
                  controller: controller1,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  reverse: false,
                  itemBuilder: (BuildContext context, int index,Animation animation ){
                    return FadeTransition(
                      opacity: animation,
                      child: Padding(
                        padding: EdgeInsets.all(1.0),//_messages.length-index-1
                        child: new MyMessage(widget.talkname, widget.issue_id, _messages[index],widget.myname, _messages[index].isRcvd, index),
                      ),
                    );
                },
                  initialItemCount: _messages.length,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: height/3.5),
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: Colors.white
                      ),
                      child: TextField(
                        maxLines: null,
                        controller: messageController,
                        style: TextStyle(
                          color: actualBlack,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type Message here",
                        ),
                        cursorRadius: Radius.circular(10.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:10.0),
                    child: OutlineButton.icon(
                      onPressed: (){
                        String m= messageController.text.trim();
                        if(m!=''){
                          sendMyMessage(m);
                        }
                        messageController.clear();
                    },
                        padding: EdgeInsets.all(10.0),
                        highlightedBorderColor: actualWhite,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderSide: BorderSide(color: actualWhite, width: 2.0),
                        icon: Icon(Icons.send, color: actualWhite,),
                        label: Text("Send", style: TextStyle(color: actualWhite, fontWeight: FontWeight.w700),),
                      color: actualWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))
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


class MyMessage extends StatefulWidget {
  MyMessage(this.talkname, this.issue_id, this.msg, this.myname, this.isRcvd, this.index);
  String talkname,myname;
  int issue_id;
  bool isRcvd;
  Message msg;
  int index;


  @override
  _MyMessageState createState() => _MyMessageState(talkname, issue_id, msg, myname, isRcvd, index);
}

class _MyMessageState extends State<MyMessage> {
_MyMessageState(this.talkname, this.issue_id, this.msg, this.myname, this.isRcvd,this.index);

String talkname,myname;
int issue_id;
bool isRcvd;
Message msg;
int index;

int _isSent;
  void setMyState(int a){
    setState(() {
      _isSent=a;
    });
  }
  Future messageServerFunction(Map temp) async{
    setState(() {
      _isSent=2;
    });
    String url = LoginCreds().url;
    url+='sendMessage.php';
    try{
      await http.post(
        url,
        body: temp,
      ).then((http.Response response){
        var resp= jsonDecode(response.body);
        print(resp);
        if(resp['status']=="Success"){
          setState(() {
            isRcvd=true;
          });
          _messageStatus[index]= true;
          setMyState(0);
          print("message sent");
        }
        else{
          toast.Toast.show("Unknown Error Occured while fetching Talks. Please Try Again", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          setMyState(1);
        }
      }).timeout(Duration(seconds: 5));
    }catch(e){
      print(e);
      setMyState(1);
    }
  }

  @override
  void initState() {
    _isSent = 2;
    if(!_messageStatus[this.index]){

      Map temp= {
        'talkname':'${this.talkname}',
        'issue_id':'${this.issue_id}',
        'sender':'${this.msg.sender}',
        'receiver':'${this.msg.receiver}',
        'message':'${this.msg.message}'
      };
      this.messageServerFunction(temp);
    }
    else{
      _isSent=0;
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double width= MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: (widget.msg.sender==widget.myname)?CrossAxisAlignment.end:CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onHighlightChanged: null,
          onPressed: (){
            Map temp= {
              'talkname':'${this.talkname}',
              'issue_id':'${this.issue_id}',
              'sender':'${this.msg.sender}',
              'receiver':'${this.msg.receiver}',
              'message':'${this.msg.message}'
            };
            (!isRcvd)?this.messageServerFunction(temp):null;
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: width*0.6625 ),
            padding: EdgeInsets.all(15.0),
            decoration: BoxDecoration(
              color: actualWhite,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Text(
              widget.msg.message,
              style: new TextStyle(
            color: actualBlack,
            ),
            ),
          ),
        ),
        Divider(
          height: 3.0,
          color: Colors.transparent,
        ),
        (_isSent==1)?Text(
          "Fail. Tap to retry.",
          style: new TextStyle(
            color: actualWhite,
            fontSize: 11.0
          ),
        ):(_isSent==2)?Container(
          width: 20.0,
          alignment: Alignment.bottomRight,
          child: SpinKitChasingDots(
            color: actualWhite,
            size: 15.0,
            duration: Duration(milliseconds: 1000),
          ),
    ):Divider(
          height: 3.0,
          color: Colors.transparent,
        ),
      ],
    );
  }
}


class Message{
  Message(this.sender, this.receiver,this.message, this.time, this.isRcvd);
  String sender, receiver;
  String message;
  bool isRcvd;
  TimeOfDay time;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Message&&
              runtimeType == other.runtimeType &&
              sender== other.sender &&
              receiver == other.receiver &&
              message == other.message &&
              isRcvd == other.isRcvd &&
              time == other.time;
  @override
  int get hashCode =>
      sender.hashCode ^ receiver.hashCode ^ message.hashCode ^ isRcvd.hashCode ^ time.hashCode;

}

