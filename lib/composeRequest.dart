import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:toast/toast.dart' as toast;
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_tags/tag.dart';

import 'logincreds.dart';


Color actualBlack= Color.fromRGBO(0,0,0,1.0);
Color actualWhite= Color.fromRGBO(255,255,255,1.0);
Color myGreen= Color.fromRGBO(2,170,176,1.0);
Color tealColor=  Colors.teal;

class ComposeRequest extends StatefulWidget {
  ComposeRequest(this.type);
  String type;
  @override
  _ComposeRequestState createState() => _ComposeRequestState(type);
}

class _ComposeRequestState extends State<ComposeRequest> {

  bool studentCheck, alumniCheck;

  _ComposeRequestState(this.type);
  final subjectController = new TextEditingController();
  final detailsController = new TextEditingController();
  String type;


  Future<String> getTokenPath()async{
    io.Directory dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, "config.txt");
  }

  List<String> _tags = <String>[];


  Future createIssue() async{
    await getTokenPath().then((String path) async {
      String catgs = "";
      if(_tags.length==0)catgs="all";else{
        for(int i=0; i<_tags.length;i++){
          catgs+=_tags[i];
          if(i<_tags.length-1)catgs+="&";
        }
      }
      print(catgs);
      Map profileData = jsonDecode(io.File(path).readAsStringSync());
      Map temp= {
        'username': '${profileData['username']}',
        'type':'${profileData['type']}',
        'subject': subjectController.text,
        'details': detailsController.text,
        'alumniaudience': '$alumniCheck',
        'studentaudience': '$studentCheck',
        'categories':'$catgs'
      };
      String url = LoginCreds().url;
      url+='createIssue.php';
      try{
        print(temp);
        await http.post(
          url,
          body: temp,
        ).then((http.Response response){
          var resp= jsonDecode(response.body);
          if ( resp['status']== "Success" ){
            toast.Toast.show("Request Successfully Created", context,  duration: 4, backgroundColor: actualWhite, textColor: myGreen);
            subjectController.clear();
            detailsController.clear();
            Navigator.pop(context);
          }
          else{
            toast.Toast.show("Error, please try again!", context, duration: 4, backgroundColor: actualWhite, textColor: myGreen);
          }
        }).timeout(Duration(seconds: 5));
      }catch(e){
        print(e);
        toast.Toast.show("Error creating the request. Try Again", context, duration: 4, backgroundColor: actualWhite, textColor: myGreen);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    alumniCheck= false;
    studentCheck=  false;
  }

  @override
  Widget build(BuildContext context) {
    double width= MediaQuery.of(context).size.width;
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
            "Compose Request",
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:20.0, left: 15.0),
                  child: Text("Subject",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  padding: EdgeInsets.only(left:25.0, right: 20.0,bottom: 20.0),
                  constraints: BoxConstraints(maxHeight: width/2),
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17.5),
                      color: Colors.white
                  ),
                  child: TextField(
                    maxLength: 300,
                    controller: subjectController,
                    style: TextStyle(
                      color: actualBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter the subject...",
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.multiline,
                    cursorRadius: Radius.circular(10.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:20.0, left: 15.0),
                  child: Text("Details",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
                  padding: EdgeInsets.only( left:20.0, right: 20.0),
                  width: width/1,
                  constraints: BoxConstraints(minHeight:width/5, maxHeight: width/2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17.5),
                      color: Colors.white
                  ),
                  child: TextField(
                    controller: detailsController,
                    style: TextStyle(
                      color: actualBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Provide the synopsis regarding the request...",
                      alignLabelWithHint: false,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.multiline,
                    cursorRadius: Radius.circular(10.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:30.0, bottom: 5.0, left: 15.0),
                  child: Text("Who should see your Issue?",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:20.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            color:  (alumniCheck)?actualWhite:Colors.transparent,
                            onPressed: (){
                              setState(() {
                                alumniCheck=!alumniCheck;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              side: BorderSide(
                                width: 2.0,
                                  color: (alumniCheck)?Colors.transparent:actualWhite)
                            ),
                            child: Text("Alumni",
                              style: TextStyle(
                                color: (alumniCheck)?tealColor:actualWhite,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            color:  (studentCheck)?actualWhite:Colors.transparent,
                            onPressed: (){
                              setState((){
                                studentCheck=!studentCheck;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                              side: BorderSide(
                                width: 2.0,
                                color: (studentCheck)?Colors.transparent:actualWhite,
                              ),
                            ),
                            child: Text("Students",
                              style: TextStyle(
                                color: (studentCheck)?tealColor:actualWhite,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top:20.0, left: 15.0),
                  child: Text("Related Tags..!",
                    style: new TextStyle(
                      color: actualWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Tags(
                    textField: TagsTextFiled(
                      autofocus: false,
                      hintTextColor: actualWhite,
                      textStyle: TextStyle(
                        color: actualWhite,
                        fontSize: 16.0,
                      ),

                      onSubmitted: (String str) {
                        setState(() {
                          _tags.add(str);
                        });
                      },
                    ),
                    direction: Axis.horizontal,
                    itemCount: _tags.length,
                    itemBuilder: (int index){
                      return ItemTags(
                        key: Key(index.toString()),
                        index: index,
                        title: _tags[index],
                        textStyle: TextStyle( color: actualWhite,  fontSize: 17.0, ),
                        combine: ItemTagsCombine.withTextBefore,
                        removeButton: ItemTagsRemoveButton(color: actualWhite, backgroundColor: myGreen),
                        onRemoved: (){
                          setState(() {
                            _tags.removeAt(index);
                          });
                        },
                        activeColor: actualWhite,
                        color: actualWhite,
                        textActiveColor: myGreen,
                        textColor: myGreen,
                      );
                    },
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
                          if(subjectController.text.trim()=="") {
                            toast.Toast.show("Please add a Subject to Request . !", context, duration: 4, backgroundColor: actualWhite, textColor: myGreen);
                          }
                          else if(detailsController.text.trim()=="") {
                            toast.Toast.show("Please provide synopsis of Request . !", context, duration: 4, backgroundColor: actualWhite, textColor: myGreen);
                          }
                          else if(!(alumniCheck || studentCheck)){
                            toast.Toast.show("Select at least one set of Audience . !", context, duration: 4, backgroundColor: actualWhite, textColor: myGreen);
                          }
                          else{
                            createIssue();
                          }
                    },
                    child: Text("Submit",
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

