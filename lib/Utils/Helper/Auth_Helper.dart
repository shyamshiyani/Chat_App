import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  AuthHelper._();
  static final AuthHelper authHelper = AuthHelper._();
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> guestUserLogin() async {
    Map<String, dynamic> res = {};
    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "Operation not allowed";
          break;
        case "weak-password":
          res['error'] = "Weak password";
          break;
        case "email-already-in-use":
          res['error'] = "Email already in use";
          break;
        case "invalid-credential":
          res['error'] = "Invalid credential";
          break;
        default:
          res['error'] = "An error occurred: ${e.message}";
      }
    }

    return res;
  }

  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {};
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "operation-not-allowed":
          res['error'] = "Operation not allowed";
          break;
        case "weak-password":
          res['error'] = "Weak password";
          break;
        case "email-already-in-use":
          res['error'] = "Email already in use";
          break;
        case "invalid-credential":
          res['error'] = "Invalid credential";
          break;
        default:
          res['error'] = "An error occurred: ${e.message}";
      }
    }
    return res;
  }

  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {};
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "network-request-failed":
          res['error'] = "No Internet Available";
          break;
        case "user-not-found":
          res['error'] = "User not found";
          break;
        case "wrong-password":
          res['error'] = "Wrong password";
          break;
        case "invalid-email":
          res['error'] = "Invalid email";
          break;
        default:
          res['error'] = "An error occurred: ${e.message}";
      }
    }
    return res;
  }

  Future<Map<String, dynamic>> googleUserLogin() async {
    Map<String, dynamic> res = {};
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;
      res['user'] = user;
    } on FirebaseAuthException catch (e) {
      res['error'] = "An error occurred: ${e.message}";
    } catch (e) {
      res['error'] = "An unknown error occurred.";
    }
    return res;
  }

  // contactUserLogin({
  //   required String phoneNumber,
  //   required String smsCode,
  //   required Function onVerificationCompleted,
  //   required Function onVerificationFailed,
  //   required Function onCodeSent,
  //   required Function onCodeAutoRetrievalTimeout,
  // }) async {
  //   try {
  //     await firebaseAuth.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         await firebaseAuth.signInWithCredential(credential);
  //         onVerificationCompleted();
  //       },
  //       verificationFailed: (FirebaseAuthException e) {
  //         print("Verification failed: ${e.message}");
  //         onVerificationFailed(e);
  //       },
  //       codeSent: (String verificationId, int? resendToken) async {
  //         try {
  //           PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //               verificationId: verificationId, smsCode: smsCode);
  //
  //           await firebaseAuth.signInWithCredential(credential);
  //           onCodeSent();
  //         } catch (e) {
  //           print("Error during sign in with credential: $e");
  //           onVerificationFailed(FirebaseAuthException(
  //               code: 'invalid-verification-code',
  //               message: 'The verification code is invalid.'));
  //         }
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {
  //         onCodeAutoRetrievalTimeout();
  //       },
  //     );
  //   } catch (e) {
  //     print("Error in contactUserLogin: $e");
  //     onVerificationFailed(FirebaseAuthException(
  //         code: 'unknown-error', message: 'An unknown error occurred.'));
  //   }
  // }

  //  Sign out
  Future<Map<String, dynamic>> signOutUser() async {
    Map<String, dynamic> res = {};
    try {
      await firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      res['success'] = "Signed out successfully";
    } catch (e) {
      res['error'] = "An error occurred while signing out.";
    }
    return res;
  }
}
