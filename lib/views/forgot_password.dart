import 'package:chatapp/services/database.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/services/auth.dart';
import 'package:toast/toast.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailForPasswordReset = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  QuerySnapshot searchResultSnapshotEmail;
  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  bool isLoading = false;

  resetPassword() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService.resetPass(emailForPasswordReset.text).then((result) {
        if (result == null) {
          setState(() {
            isLoading = false;
            Toast.show("An Email Has Sent To Your Account", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          });
        }
      });
    }
  }

  userAlreadySignedInOrNot(String email) async {
    await databaseMethods.getUserInfo(email).then((snapshot) {
      searchResultSnapshotEmail = snapshot;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(
              child: CircularProgressIndicator(),
            ))
          : Container(
              child: Column(
                children: [
                  Spacer(),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          validator: (val) {
                            userAlreadySignedInOrNot(val);
                            if (RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val)) {
                              return (searchResultSnapshotEmail
                                          .documents.length !=
                                      0)
                                  ? null
                                  : "You Don't Have An Account";
                            } else {
                              return "Enter correct email";
                            }
                          },
                          controller: emailForPasswordReset,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("email"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      resetPassword();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff2A75BC)
                            ],
                          )),
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),
    );
  }
}
