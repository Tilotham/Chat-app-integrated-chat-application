import 'dart:async';

import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/bot.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:flutter/material.dart';

class BotResponseSearch extends StatefulWidget {
  final String userName;
  List<String> allBotQuesions;
  List<String> allBotAnswers;
  List<String> allBotQuesionsId;

  BotResponseSearch(
      {@required this.userName,
      @required this.allBotQuesions,
      @required this.allBotAnswers,
      @required this.allBotQuesionsId});

  @override
  _BotResponseSearchState createState() => _BotResponseSearchState();
}

class _BotResponseSearchState extends State<BotResponseSearch> {
  TextEditingController botResonseSearchEditingController =
      new TextEditingController();
  bool isLoading = false;
  bool haveBotResponseSearched = false;
  bool deleted = false;
  int noOfBotResponse = 0;
  List<String> botResponseSearchedQuestions = [];
  List<String> botResponseSearchedAnswers = [];
  List<String> botResponseSearchedQuestionIds = [];

  initiateSearch() {
    botResponseSearchedQuestions = [];
    botResponseSearchedAnswers = [];
    botResponseSearchedQuestionIds = [];
    if (botResonseSearchEditingController.text.isNotEmpty) {
      for (var i = 0; i < widget.allBotAnswers.length; i++) {
        if (widget.allBotQuesions[i]
            .contains(botResonseSearchEditingController.text)) {
          noOfBotResponse += 1;
          haveBotResponseSearched = true;
          botResponseSearchedQuestions.add(widget.allBotQuesions[i]);
          botResponseSearchedAnswers.add(widget.allBotAnswers[i]);
          botResponseSearchedQuestionIds.add(widget.allBotQuesionsId[i]);
          setState(() {});
        }
      }
    }
    setState(() {});
  }

  Widget botResponseList() {
    return haveBotResponseSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: botResponseSearchedQuestions.length,
            itemBuilder: (context, index) {
              return botResponseTile(
                  botResponseSearchedQuestions[index],
                  botResponseSearchedAnswers[index],
                  botResponseSearchedQuestionIds[index]);
            })
        : Container();
  }

  Widget botResponseTile(String question, String answer, String questionId) {
    return haveBotResponseSearched
        ? GestureDetector(
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
                                Navigator.pop(context);
                              },
                              child: Text("No")),
                          FlatButton(
                              onPressed: () {
                                DatabaseMethods().deleteBotResponse(
                                    widget.userName, questionId);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Bot(
                                              userName: widget.userName,
                                            )));
                              },
                              child: Text("Yes"))
                        ],
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(24)),
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBarMain(
          context,
          widget.userName[0].toUpperCase() +
              widget.userName.substring(1) +
              " Bot Search"),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    color: Colors.grey[400],
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              initiateSearch();
                            },
                            controller: botResonseSearchEditingController,
                            style: simpleTextStyle(),
                            decoration: InputDecoration(
                                hintText: "search Response ...",
                                hintStyle: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                                border: InputBorder.none),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            initiateSearch();
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey[500],
                                  borderRadius: BorderRadius.circular(40)),
                              padding: EdgeInsets.all(12),
                              child: Image.asset(
                                "assets/images/search_white.png",
                                height: 25,
                                width: 25,
                              )),
                        )
                      ],
                    ),
                  ),
                  botResponseList()
                ],
              ),
            ),
    );
  }
}
