import 'package:chatapp/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData, String email) async {
    Firestore.instance.collection("users").document(email).setData(userData);
  }

  getUserInfo(String email) async {
    return Firestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .getDocuments();
  }

  getAllUsersInfo() async {
    return Firestore.instance.collection("users").getDocuments();
  }

  searchByName(String searchField) {
    return Firestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .getDocuments();
  }

  Future<bool> addChatRoom(chatRoom, chatRoomId) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .setData(chatRoom);
  }

  getChats(String chatRoomId) async {
    return Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy('time', descending: true)
        .snapshots();
  }

  getBotResponse(String email, String userName) async {
    return Firestore.instance
        .collection("users")
        .document(email)
        .collection(userName)
        .snapshots();
  }

  checkBotResponseUnique(String userName, String questionToAdd) async {
    return Firestore.instance
        .collection("users")
        .document(Constants.userEmail)
        .collection(userName)
        .where("question", isEqualTo: questionToAdd)
        .getDocuments();
  }

  getUserLastseen(String userName) async {
    return Firestore.instance.collection("lastSeen").document(userName).get();
  }

  getUserEmail(String userName) async {
    return Firestore.instance
        .collection("users")
        .where("userName", isEqualTo: userName)
        .getDocuments();
  }

  getBotQAs(String userEmail, String userName) async {
    return Firestore.instance
        .collection("users")
        .document(userEmail)
        .collection(userName)
        .getDocuments();
  }

  Future<void> addUserStatus(String userName) async {
    Firestore.instance
        .collection("lastSeen")
        .document(userName)
        .setData({"time": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Future<void> userStatusUpdate(int time) async {
    Firestore.instance
        .collection("lastSeen")
        .document(Constants.myName)
        .updateData({"time": time.toString()});
  }

  Future<void> addBotResponse(String userName, newBotResponse) async {
    Firestore.instance
        .collection("users")
        .document(Constants.userEmail)
        .collection(userName)
        .add(newBotResponse);
  }

  Future<void> deleteBotResponse(String userName, String questionId) async {
    Firestore.instance
        .collection("users")
        .document(Constants.userEmail)
        .collection(userName)
        .document(questionId)
        .delete();
  }

  Future<void> addMessage(String chatRoomId, chatMessageData) {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomId)
        .collection("chats")
        .add(chatMessageData);
  }

  Future<void> deleteChat(
      String chatRoomIdForDeleting, String collectionId) async {
    Firestore.instance
        .collection("chatRoom")
        .document(chatRoomIdForDeleting)
        .collection("chats")
        .document(collectionId)
        .delete();
  }

  getUserChats(String itIsMyName) async {
    return await Firestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }
}
