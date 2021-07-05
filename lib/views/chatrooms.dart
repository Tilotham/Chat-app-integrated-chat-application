import 'dart:async';

import 'package:chatapp/helper/authenticate.dart';
import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/helper/theme.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chat.dart';
import 'package:chatapp/views/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bot.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Stream chatRooms;
  String nameToShow;

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var userNameToShow = snapshot
                      .data.documents[index].data['chatRoomId']
                      .toString()
                      .split("_");
                  if (userNameToShow[0] == Constants.myName) {
                    nameToShow = userNameToShow[1][0].toUpperCase() +
                        userNameToShow[1].substring(1);
                  } else {
                    nameToShow = userNameToShow[0][0].toUpperCase() +
                        userNameToShow[0].substring(1);
                  }
                  return ChatRoomsTile(
                    userName: nameToShow,
                    chatRoomId:
                        snapshot.data.documents[index].data["chatRoomId"],
                  );
                })
            : Container();
      },
    );
  }

  Timer timer;

  @override
  void initState() {
    getUserInfogetChats();
    timer = Timer.periodic(Duration(seconds: 20), (timer) {
      DatabaseMethods().userStatusUpdate(DateTime.now().millisecondsSinceEpoch);
    });
    super.initState();
  }

  getUserInfogetChats() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.userEmail = await HelperFunctions.getUserEmailSharedPreference();
    DatabaseMethods().getUserChats(Constants.myName).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
      });
    });
  }

  Widget listForDrawer(String textToShow, Function function) {
    return ListTile(
      title: Text(textToShow),
      onTap: function(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text(
              "Chat App",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text(
              "Chat Bot",
              style: TextStyle(fontSize: 20),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Bot(
                            userName: "general",
                          )));
            },
          ),
          ListTile(
              title: Text(
                "Logout",
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                AuthService().signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Authenticate()));
              }),
        ],
      )),
      appBar: AppBar(
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.blue[700],
            statusBarIconBrightness: Brightness.light),
        title: Text("Chat App"),
        elevation: 0.0,
        centerTitle: false,
        actions: [],
      ),
      body: Container(
        child: chatRoomsList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Search()));
        },
      ),
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;

  ChatRoomsTile({this.userName, @required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chat(
                      chatRoomId: chatRoomId,
                    )));
      },
      child: Column(
        children: [
          Container(
            color: Colors.black12,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30)),
                  child: Text(userName[0].toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'OverpassRegular',
                          fontWeight: FontWeight.w300)),
                ),
                SizedBox(
                  width: 20,
                ),
                Text(userName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 19,
                        fontFamily: 'OverpassRegular',
                        fontWeight: FontWeight.w400))
              ],
            ),
          ),
          SizedBox(
            height: 0.7,
          )
        ],
      ),
    );
  }
}
