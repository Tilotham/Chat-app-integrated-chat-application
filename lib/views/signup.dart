import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/chatrooms.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  SignUp(this.toggleView);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController usernameEditingController = new TextEditingController();

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool haveUserSearched = false;
  QuerySnapshot searchResultSnapshot;
  QuerySnapshot searchResultSnapshotEmail;

  userCheck(String name) async {
    await databaseMethods.searchByName(name).then((snapshot) {
      searchResultSnapshot = snapshot;
    });
  }

  userAlreadySignedInOrNot(String email) async {
    await databaseMethods.getUserInfo(email).then((snapshot) {
      searchResultSnapshotEmail = snapshot;
    });
  }

  signUp() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signUpWithEmailAndPassword(
              emailEditingController.text, passwordEditingController.text)
          .then((result) {
        if (result != null) {
          Map<String, String> userDataMap = {
            "userName": usernameEditingController.text.trim(),
            "userEmail": emailEditingController.text.trim(),
          };

          databaseMethods.addUserInfo(userDataMap, emailEditingController.text);
          databaseMethods.addUserStatus(usernameEditingController.text);
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              usernameEditingController.text);
          HelperFunctions.saveUserEmailSharedPreference(
              emailEditingController.text);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Spacer(),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: simpleTextStyle(),
                          controller: usernameEditingController,
                          validator: (val) {
                            userCheck(val);
                            if (searchResultSnapshot.documents.length == 0) {
                              return val.isEmpty || val.length < 5
                                  ? "Enter Username With 5+ characters"
                                  : null;
                            } else {
                              return "Username Already Taken";
                            }
                          },
                          decoration: textFieldInputDecoration("username"),
                        ),
                        TextFormField(
                          controller: emailEditingController,
                          style: simpleTextStyle(),
                          validator: (val) {
                            userAlreadySignedInOrNot(val);
                            if (searchResultSnapshotEmail.documents.length ==
                                0) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Enter correct email";
                            } else {
                              return "You Already Have An Account";
                            }
                          },
                          decoration: textFieldInputDecoration("email"),
                        ),
                        TextFormField(
                          obscureText: true,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("password"),
                          controller: passwordEditingController,
                          validator: (val) {
                            return val.length < 6
                                ? "Enter Password 6+ characters"
                                : null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      signUp();
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.grey[400]),
                    width: MediaQuery.of(context).size.width - 100,
                    child: Text(
                      "Sign Up with Google",
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: simpleTextStyle(),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.toggleView();
                        },
                        child: Text(
                          "SignIn now",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.cyan[800],
                              fontSize: 18,
                              decoration: TextDecoration.none),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
    );
  }
}
