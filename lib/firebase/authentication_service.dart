import 'package:firebase_auth/firebase_auth.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/user.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final Database _database;

  AuthenticationService(this._firebaseAuth, this._database);

  Future<void> login(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> signUp(
    String email,
    String password,
    String name,
    int colour,
  ) async {
    // Store the result of the creation of the user, which means we can then extract the id from it to add to Firestore
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    String id = result.user.uid;
    // Email needs to always be lowercase so we can search for it easily later
    User user = User(name, id, email.toLowerCase(), colour);
    await _database.addUser(user);
  }

  Future<FirebaseUser> getCurrentUser() async {
    return await _firebaseAuth.currentUser();
  }

  Future<bool> isUserLoggedIn() async {
    // Get the current user.
    final FirebaseUser user = await getCurrentUser();
    // If the user and their uid are not null, then the user is logged in
//user?.uid means if user is null, then do not try and get the field uid. This avoids a null pointer exception
    return user?.uid != null;
  }

  Future<void> passwordReset(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
