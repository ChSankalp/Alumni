import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'logincreds.dart';
import 'package:toast/toast.dart' as toast;

Color actualBlack= Color.fromRGBO(0,0,0,1.0);
Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);
Color tealColor=  Colors.teal;


class EditPreferences extends StatefulWidget {
  EditPreferences(this.userData, this.presentPrefs);
  String presentPrefs;
  Map userData;
  @override
  _EditPreferencesState createState() => _EditPreferencesState();
}

class _EditPreferencesState extends State<EditPreferences> {


  final fullName = new TextEditingController();
  final passedOutYear = new TextEditingController();
  final presentDesignation = new TextEditingController();






  Future <Null> updatePreferences() async {
    String username = widget.userData['username'];
    String type = widget.userData['type'];
    String query = "Update users set fullname='${fullName.text}',passedoutyear=${passedOutYear.text},presentdesignation='${presentDesignation.text}' where username = '$username' and type='$type'";
    String url = LoginCreds().url;
    url+='setpreferences.php';
    print(query);
    Map b = {
      'query': '$query'
    };
    try{
      await http.post(
        "$url",
        body: b
      ).then((http.Response response){
        var res = jsonDecode(response.body);
        if(res['status']=="Success"){
          toast.Toast.show("Update Successful.", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          Navigator.pop(context);
        }
        else{
          toast.Toast.show("Error.", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);

        }
      }).timeout(Duration(seconds: 5));
    }catch (e){
      toast.Toast.show("Unknown Error.", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
    }
  }

  @override
  void initState() {
    fullName.text = widget.userData['fullname'];
    passedOutYear.text = widget.userData['passedoutyear'];
    presentDesignation.text = widget.userData['presentdesignation'];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text("Edit Profile",
            style: TextStyle(
              color: actualBlack,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: IconThemeData(color: actualBlack),
          elevation: 0.0,
          backgroundColor: actualWhite,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:30.0, bottom: 5.0, left: 15.0),
                  child: Text("Full Name",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left:20.0, right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.grey[200],
                  ),
                  width: width,
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
                Padding(
                  padding: EdgeInsets.only(top:30.0, bottom: 5.0, left: 15.0),
                  child: Text("Passed Out Year",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(left:20.0, right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.grey[200],
                  ),
                  width: width,
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

                Padding(
                  padding: EdgeInsets.only(top:30.0, bottom: 5.0, left: 15.0),
                  child: Text("Present designation",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(left:20.0, right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Colors.grey[200],
                  ),
                  width: width,
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
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(50.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: actualWhite),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    color: actualWhite,
                    onPressed: (){
                      updatePreferences();
                    },
                    child: Text("Update Changes!",
                      style: new TextStyle(
                          color: myGreen
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
