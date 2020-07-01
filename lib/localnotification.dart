import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotificationWidget extends StatefulWidget {
  @override
  _LocalNotificationWidgetState createState() => _LocalNotificationWidgetState();
}

class _LocalNotificationWidgetState extends State<LocalNotificationWidget> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  NotificationDetails getPlatformSpecifics(){
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    return NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  @override
  void initState() {
    Future onSelectNotification(String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }

      await flutterLocalNotificationsPlugin.show(2, "Payload", payload, getPlatformSpecifics());
//      await Navigator.push(
//        context,
//        new MaterialPageRoute(builder: (context) => new SecondScreen(payload)),
//      );
    }
     var initializationSettingsAndroid =
    new AndroidInitializationSettings('logo');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (id, title, body, payload)=> onSelectNotification(payload));
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);


    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FlatButton(
          onPressed: ()async{
            await flutterLocalNotificationsPlugin.show(1, "Sunny Leone", "KamaSutra", getPlatformSpecifics(), payload: "Sunny");
        },
          child: Text("Show")),
    );
  }
}
