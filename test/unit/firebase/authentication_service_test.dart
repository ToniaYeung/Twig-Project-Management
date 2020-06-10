import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';

main() {
  String email = "tonia@gmail.com";
  String password = "password";

  test('Logout should call firebase sign out', () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    AuthenticationService auth = AuthenticationService(mockFirebaseAuth, null);

    //action
    await auth.logOut();

    //assert
    verify(mockFirebaseAuth.signOut()).called(1);
  });

  test('Login should call firebase auth sign in with email and password',
      () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    AuthenticationService auth = AuthenticationService(mockFirebaseAuth, null);

    //action
    await auth.login(email, password);

    //assert
    verify(mockFirebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .called(1);
  });

  test('getCurrentUser should call firebase auth and get current user',
      () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    AuthenticationService auth = AuthenticationService(mockFirebaseAuth, null);

    //action
    await auth.getCurrentUser();

    //assert
    verify(mockFirebaseAuth.currentUser()).called(1);
  });

  test('passwordReset should call firebase auth and send password reset email',
      () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    AuthenticationService auth = AuthenticationService(mockFirebaseAuth, null);
    String email = "tonia@gmail.com";

    //action
    await auth.passwordReset(email);

    //assert
    verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
  });

  test(
      'isUserLoggedIn should call firebase auth and return true if user is logged in',
      () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    AuthenticationService auth = AuthenticationService(mockFirebaseAuth, null);
    MockFirebaseUser firebaseUser = MockFirebaseUser();
    when(mockFirebaseAuth.currentUser())
        .thenAnswer((_) => Future.value(firebaseUser));
    when(firebaseUser.uid).thenReturn("someId");
    //action
    bool isUserLoggedIn = await auth.isUserLoggedIn();

    //assert
    expect(isUserLoggedIn, equals(true));
  });

  test(
      'isUserLoggedIn should call firebase auth and return false if user is not logged in',
      () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    AuthenticationService auth = AuthenticationService(mockFirebaseAuth, null);
    MockFirebaseUser firebaseUser = MockFirebaseUser();
    when(mockFirebaseAuth.currentUser())
        .thenAnswer((_) => Future.value(firebaseUser));
    when(firebaseUser.uid).thenReturn(null);
    //action
    bool isUserLoggedIn = await auth.isUserLoggedIn();

    //assert
    expect(isUserLoggedIn, equals(false));
  });

  test('signUp should call firebase auth and add user to database', () async {
    //setup
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    MockDatabase database = MockDatabase();
    AuthenticationService auth =
        AuthenticationService(mockFirebaseAuth, database);
    MockAuthResult authResult = MockAuthResult();
    MockFirebaseUser firebaseUser = MockFirebaseUser();

    when(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .thenAnswer((_) => Future.value(authResult));

    when(authResult.user).thenReturn(firebaseUser);

    when(firebaseUser.uid).thenReturn("id");

    //action
    await auth.signUp(email, password, "tonia", 123);

    //assert
    verify(mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password))
        .called(1);
    verify(database.addUser(any)).called(1);
  });
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements FirebaseUser {}

class MockAuthResult extends Mock implements AuthResult {}

class MockDatabase extends Mock implements Database {}
