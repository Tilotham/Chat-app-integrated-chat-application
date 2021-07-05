import 'dart:async';
import 'package:string_similarity/string_similarity.dart';
import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/bot.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  String nameToShowInChatAppbar;
  String userLastSeen = "Offline";
  bool userOffline = true;
  var mapOfSpecificQAs = new Map();
  var mapOfGeneralQAs = new Map();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var dateTime = new DateTime.fromMillisecondsSinceEpoch(
                      snapshot.data.documents[index].data["time"]);
                  return MessageTile(
                    message: snapshot.data.documents[index].data["message"],
                    sendByMe: Constants.myName ==
                        snapshot.data.documents[index].data["sendBy"],
                    time: dateTime.toString(),
                    collectionId:
                        snapshot.data.documents[index].documentID.toString(),
                    chatRoomID: widget.chatRoomId,
                  );
                })
            : Container();
      },
    );
  }

  addMessageByBot(String chatBotMessage) {
    Map<String, dynamic> botChatMessageMap = {
      "sendBy": nameToShowInChatAppbar.toLowerCase(),
      "message": chatBotMessage,
      'time': DateTime.now().millisecondsSinceEpoch,
    };

    DatabaseMethods().addMessage(widget.chatRoomId, botChatMessageMap);

    setState(() {});
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
    }
  }

  Timer timer;

  userStatusUpdate() {
    DatabaseMethods()
        .getUserLastseen(nameToShowInChatAppbar.toLowerCase())
        .then((value) {
      setState(() {
        if (DateTime.now().millisecondsSinceEpoch -
                int.parse(value.data['time']) >
            30000) {
          userLastSeen = "Offline";
          userOffline = true;
        } else {
          userLastSeen = "Online";
          userOffline = false;
        }
      });
    });
  }

  getBotResponses() async {
    QuerySnapshot otherUserDocument = await DatabaseMethods()
        .getUserEmail(nameToShowInChatAppbar.toLowerCase());
    String userEmail = otherUserDocument.documents[0].data["userEmail"];
    QuerySnapshot botGeneralResponses =
        await DatabaseMethods().getBotQAs(userEmail, "general");
    int lengthOfTheDocumnents1 = botGeneralResponses.documents.length;
    for (int i = 0; i < lengthOfTheDocumnents1; i++) {
      mapOfGeneralQAs[botGeneralResponses.documents[i].data["question"]] =
          botGeneralResponses.documents[i].data["answer"];
    }
    QuerySnapshot botSpecificResponses = await DatabaseMethods().getBotQAs(
        userEmail,
        Constants.myName[0].toUpperCase() + Constants.myName.substring(1));
    int lengthOfTheDocumnents2 = botSpecificResponses.documents.length;
    for (int i = 0; i < lengthOfTheDocumnents2; i++) {
      mapOfSpecificQAs[botSpecificResponses.documents[i].data["question"]] =
          botSpecificResponses.documents[i].data["answer"];
    }
  }

  chatBotMessage() {
    if (userOffline) {
      String chatBotMessage;
      String userQuestion = messageEditingController.text;
      double bestStringCompare = 0;
      for (int i = 0; i < mapOfGeneralQAs.length; i++) {
        if (userQuestion.similarityTo(mapOfGeneralQAs.keys.elementAt(i)) >
                bestStringCompare &&
            userQuestion.similarityTo(mapOfGeneralQAs.keys.elementAt(i)) >
                0.5) {
          chatBotMessage = mapOfGeneralQAs.values.elementAt(i);
          bestStringCompare =
              userQuestion.similarityTo(mapOfGeneralQAs.keys.elementAt(i));
        }
      }
      for (int i = 0; i < mapOfSpecificQAs.length; i++) {
        if (userQuestion.similarityTo(mapOfSpecificQAs.keys.elementAt(i)) >
                bestStringCompare &&
            userQuestion.similarityTo(mapOfSpecificQAs.keys.elementAt(i)) >
                0.5) {
          chatBotMessage = mapOfSpecificQAs.values.elementAt(i);
          bestStringCompare =
              userQuestion.similarityTo(mapOfSpecificQAs.keys.elementAt(i));
        }
      }
      if (chatBotMessage != null) {
        addMessageByBot(chatBotMessage);
      }
    }
    setState(() {
      messageEditingController.text = "";
    });
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });

    findTheOppositeUser();
    getBotResponses();
    userStatusUpdate();
    timer = Timer.periodic(Duration(seconds: 20), (timer) {
      userStatusUpdate();
    });
    super.initState();
  }

  findTheOppositeUser() {
    var nameToShow = widget.chatRoomId.split("_");
    if (nameToShow[0] == Constants.myName) {
      nameToShowInChatAppbar =
          nameToShow[1][0].toUpperCase() + nameToShow[1].substring(1);
    } else {
      nameToShowInChatAppbar =
          nameToShow[0][0].toUpperCase() + nameToShow[0].substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backwardsCompatibility: false,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.blue[700],
            statusBarIconBrightness: Brightness.light),
        title: Row(
          children: [
            Text(nameToShowInChatAppbar),
            Spacer(),
            Text(
              userLastSeen,
              style: TextStyle(
                fontSize: 15,
              ),
            )
          ],
        ),
        elevation: 0.0,
        centerTitle: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Bot(
                              userName: nameToShowInChatAppbar,
                            )));
              })
        ],
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
                padding: EdgeInsets.only(bottom: 80), child: chatMessages()),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                color: Colors.grey[400],
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageEditingController,
                      style: simpleTextStyle(),
                      decoration: InputDecoration(
                          hintText: "Message ...",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                          border: InputBorder.none),
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                        chatBotMessage();
                      },
                      child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius: BorderRadius.circular(40)),
                          padding: EdgeInsets.all(11),
                          child: Image.asset(
                            "assets/images/send.png",
                            height: 20,
                            width: 20,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final String time;
  final bool sendByMe;
  final String collectionId;
  final String chatRoomID;

  MessageTile(
      {@required this.message,
      @required this.time,
      @required this.sendByMe,
      @required this.collectionId,
      @required this.chatRoomID});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (sendByMe) {
          AlertDialog alert = AlertDialog(
            title: Text("Delete"),
            content: Text("Do you want to delete this message"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No")),
              FlatButton(
                  onPressed: () {
                    DatabaseMethods().deleteChat(chatRoomID, collectionId);
                    Navigator.pop(context);
                  },
                  child: Text("Yes"))
            ],
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: sendByMe ? 0 : 10,
            right: sendByMe ? 10 : 0),
        alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin:
              sendByMe ? EdgeInsets.only(left: 55) : EdgeInsets.only(right: 55),
          padding: EdgeInsets.only(top: 14, bottom: 10, left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(13),
                    bottomLeft: Radius.circular(13))
                : BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(13)),
            color: sendByMe ? Colors.blue : Colors.grey[300],
          ),
          child: Column(
            children: [
              Text(message,
                  textAlign: sendByMe ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                      color: sendByMe ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontFamily: 'OverpassRegular',
                      fontWeight: FontWeight.w500)),
              Text(
                time.substring(0, 16),
                style: TextStyle(
                    color: sendByMe ? Colors.white : Colors.black54,
                    fontSize: 12,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
      ),
    );
  }
}
