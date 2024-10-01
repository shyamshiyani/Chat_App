import 'package:chat_app_firebase/Utils/Helper/Auth_Helper.dart';
import 'package:chat_app_firebase/Utils/Helper/Show_notification_from_firebase_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper databaseHelper = DatabaseHelper._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  // Add user
  /*addAuthenticatedUser({required String email}) async {
    bool isUserCreated = false;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> e) {
      Map<String, dynamic> docData = e.data();

      if (docData['email'] == email) {
        isUserCreated = true;
      }
    });

    if (isUserCreated == false) {
      DocumentSnapshot<Map<String, dynamic>> qs =
          await db.collection("records").doc("users").get();
      Map<String, dynamic>? data = qs.data();

      int id = data!['id'];

      int counter = data['counter'];

      id++;

      // manually id generated
      String? token = await ShowNotificationFromFirebasePanelHelper
          .showNotificationFromFirebasePanelHelper
          .getUserFCMToken();
      await db.collection("users").doc("$id").set(
        {
          "email": email,
          "FCMtoken": token,
        },
      );
      counter++;

      await db.collection("records").doc("users").update({
        "id": id,
        "counter": counter,
      });
    }
  }*/
  addAuthenticatedUser({required String email}) async {
    bool isUserCreated = false;
    String? existingDocId;

    // Get all users
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("users").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
        querySnapshot.docs;

    // Check if user exists and store the document ID
    allDocs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> e) {
      Map<String, dynamic> docData = e.data();

      if (docData['email'] == email) {
        isUserCreated = true;
        existingDocId = e.id; // Store the existing document ID
      }
    });

    if (!isUserCreated) {
      // User does not exist, create a new one
      DocumentSnapshot<Map<String, dynamic>> qs =
          await db.collection("records").doc("users").get();
      Map<String, dynamic>? data = qs.data();

      int id = data!['id'];
      int counter = data['counter'];

      id++;

      // Manually generated ID
      String? token = await ShowNotificationFromFirebasePanelHelper
          .showNotificationFromFirebasePanelHelper
          .getUserFCMToken();

      await db.collection("users").doc("$id").set({
        "email": email,
        "FCMtoken": token,
      });

      counter++;

      await db.collection("records").doc("users").update({
        "id": id,
        "counter": counter,
      });
    } else {
      // User exists, update the FCMtoken
      String? newToken = await ShowNotificationFromFirebasePanelHelper
          .showNotificationFromFirebasePanelHelper
          .getUserFCMToken();

      await db.collection("users").doc(existingDocId).update({
        "FCMtoken": newToken,
      });
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    required String email,
    required String displayName,
  }) async {
    await db.collection("users").doc(userId).update({
      "email": email,
      "displayName": displayName,
    });
  }

  // Fetch all user
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllUsers() {
    return db.collection("users").snapshots();
  }
  //Delete user

  deleteUser({required String idOfUser}) async {
    await db.collection("users").doc(idOfUser).delete();
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await db.collection("records").doc("users").get();
    int counter = userDoc.data()!['counter'];
    counter--;
    await db.collection("records").doc("users").update({
      "counter": counter,
    });
  }

  // send and store massage
  Future<void> sendMassages({
    required String msg,
    required String receiverEmail,
  }) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;

    bool isChatRoomChecked = false;
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatRooms =
        querySnapshot.docs;
    String? chatRoomId;
    allChatRooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatRoom) {
      List user = chatRoom.data()['user'];
      if (user.contains(receiverEmail) && user.contains(senderEmail)) {
        isChatRoomChecked = true;
        chatRoomId = chatRoom.id;
      }
    });
    if (isChatRoomChecked == false) {
      DocumentReference<Map<String, dynamic>> documentReference =
          await db.collection("chatrooms").add({
        "user": [senderEmail, receiverEmail],
      });
      chatRoomId = documentReference.id;
    }

    //storeMassages
    db.collection("chatrooms").doc(chatRoomId).collection("massages").add({
      "msg": msg,
      "senderEmail": senderEmail,
      "receiverEmail": receiverEmail,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
  //fetchAllMassages

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> fetchAllChats({
    required String receiverEmail,
  }) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;
    QuerySnapshot<Map<String, dynamic>> querySnapshots =
        await db.collection("chatrooms").get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatRooms =
        querySnapshots.docs;
    String? chatRoomId;

    allChatRooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatroom) {
      List user = chatroom.data()['user'];
      if (user.contains(receiverEmail) && user.contains(senderEmail)) {
        chatRoomId = chatroom.id;
      }
    });
    return db
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("massages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

// Update massages
  updateMassages(
      {required String receiverEmail,
      required String msg,
      required String messageDocId}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatRooms =
        querySnapshot.docs;
    String? chatRoomId;
    allChatRooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatRoom) {
      List user = chatRoom.data()['user'];
      if (user.contains(receiverEmail) && user.contains(senderEmail)) {
        chatRoomId = chatRoom.id;
      }
    });
    await db
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("massages")
        .doc(messageDocId)
        .update({
      "msg": msg,
      "UpdatedTime": FieldValue.serverTimestamp(),
    });
  }

  // delete massages
  deleteMassages(
      {required String receiverEmail, required String messageDocId}) async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("chatrooms").get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> allChatRooms =
        querySnapshot.docs;
    String? chatRoomId;
    allChatRooms
        .forEach((QueryDocumentSnapshot<Map<String, dynamic>> chatRoom) {
      List user = chatRoom.data()['user'];
      if (user.contains(receiverEmail) && user.contains(senderEmail)) {
        chatRoomId = chatRoom.id;
      }
    });
    await db
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("massages")
        .doc(messageDocId)
        .delete();
  }

  Future<String?> senderEmail() async {
    String senderEmail = AuthHelper.firebaseAuth.currentUser!.email!;
    return senderEmail;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String searchTerm) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
        .collection("users")
        .where('email', isGreaterThanOrEqualTo: searchTerm)
        .where('email', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .get();

    List<Map<String, dynamic>> userList = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => doc.data())
        .toList();

    return userList;
  }
}
