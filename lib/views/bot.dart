import 'dart:async';

import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/addBotResponse.dart';
import 'package:chatapp/views/botResponseSearch.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Bot extends StatefulWidget {
  final String userName;

  Bot({this.userName});

  @override
  _BotState createState() => _BotState();
}

class _BotState extends State<Bot> {
  List<String> allBotQuesions = [];
  List<String> allBotAnswers = [];
  List<String> allBotQuesionsId = [];
  Stream<QuerySnapshot> botResponses;

  Widget botResponseList() {
    return StreamBuilder(
      stream: botResponses,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var question =
                      snapshot.data.documents[index].data["question"];
                  var answer = snapshot.data.documents[index].data["answer"];
                  var questionId = snapshot.data.documents[index].documentID;
                  if (allBotQuesions.contains(question)) {
                  } else {
                    allBotQuesions.add(question);
                    allBotAnswers.add(answer);
                    allBotQuesionsId.add(questionId);
                  }
                  return BotResponseTile(
                      question: question.toString(),
                      answer: answer.toString(),
                      questionId: questionId,
                      userName: widget.userName);
                })
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(
          context,
          widget.userName[0].toUpperCase() +
              widget.userName.substring(1) +
              " Bot"),
      body: botResponseList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Spacer(),
          FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddBotResponse(userName: widget.userName)));
              }),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            child: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BotResponseSearch(
                            userName: widget.userName,
                            allBotQuesions: allBotQuesions,
                            allBotAnswers: allBotAnswers,
                            allBotQuesionsId: allBotQuesionsId,
                          )));
            },
          ),
        ],
      ),
    );
  }

  Timer timer;

  @override
  void initState() {
    DatabaseMethods()
        .getBotResponse(Constants.userEmail, widget.userName)
        .then((val) {
      setState(() {
        botResponses = val;
      });
    });
    super.initState();
  }
}

class BotResponseTile extends StatelessWidget {
  final String question;
  final String answer;
  final String questionId;
  final String userName;

  BotResponseTile(
      {@required this.question,
      @required this.answer,
      @required this.questionId,
      @required this.userName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
        color: Colors.blueGrey[50],
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q. " + question,
                    style: TextStyle(color: Colors.black87, fontSize: 22),
                  ),
                  Text(
                    "A. " + answer,
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                AlertDialog alert = AlertDialog(
                  title: Text("Delete"),
                  content: Text("Do you want to delete this Response"),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No")),
                    FlatButton(
                        onPressed: () {
                          DatabaseMethods()
                              .deleteBotResponse(userName, questionId);
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
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(24)),
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
