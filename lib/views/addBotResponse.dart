import 'dart:async';

import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class AddBotResponse extends StatefulWidget {
  final String userName;

  AddBotResponse({@required this.userName});

  @override
  _AddBotResponseState createState() => _AddBotResponseState();
}

class _AddBotResponseState extends State<AddBotResponse> {
  TextEditingController questionToAdd = new TextEditingController();
  TextEditingController answerToAdd = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  QuerySnapshot checkBotResponse;

  responseAlreadyThereOrNot() async {
    await DatabaseMethods()
        .checkBotResponseUnique(widget.userName, questionToAdd.text)
        .then((snapshot) {
      checkBotResponse = snapshot;
    });
  }

  addQuestionAndAnswer() {
    responseAlreadyThereOrNot();
    if (questionToAdd.text.isNotEmpty &&
        answerToAdd.text.isNotEmpty &&
        checkBotResponse.documents.length == 0) {
      Map<String, dynamic> botResponse = {
        "question": questionToAdd.text,
        "answer": answerToAdd.text
      };

      DatabaseMethods().addBotResponse(widget.userName, botResponse);
    }
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarMain(
            context,
            widget.userName[0].toUpperCase() +
                widget.userName.substring(1) +
                " Bot Response"),
        body: Container(
          child: Column(
            children: [
              Spacer(),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      controller: questionToAdd,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDecoration("Question"),
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: formKey2,
                    child: TextFormField(
                      controller: answerToAdd,
                      style: simpleTextStyle(),
                      decoration: textFieldInputDecoration("Answer"),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  responseAlreadyThereOrNot();
                  if (checkBotResponse.documents.length != 0) {
                    questionToAdd.text = "";
                    answerToAdd.text = "";
                    Toast.show("Question already exists", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                  } else {
                    addQuestionAndAnswer();
                    Navigator.pop(context);
                  }
                  ;
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xff007EF4),
                          const Color(0xff007EF4)
                        ],
                      )),
                  width: MediaQuery.of(context).size.width - 100,
                  child: Text(
                    "Add Response",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Spacer()
            ],
          ),
        ));
  }
}
