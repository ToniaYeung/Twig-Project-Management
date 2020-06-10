import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/screens/login/login.dart';
import 'common/utility/loading_future_builder.dart';
import 'firebase/database.dart';
import 'firebase/storage.dart';
import 'screens/home/home.dart';

void main() {
  runApp(Twig());
}

class Twig extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Database database = Database(Firestore.instance);
    AuthenticationService auth =
        AuthenticationService(FirebaseAuth.instance, database);
    return MultiProvider(
      providers: [
        // Producing the authentication service to the rest of the app
        // To consume, use Provider.of
        Provider<Database>(create: (context) {
          return database;
        }),
        Provider<AuthenticationService>(create: (context) {
          return auth;
        }),
        Provider<Storage>(create: (context) {
          return Storage(FirebaseStorage.instance);
        }),
      ],
      child: LoadingFutureBuilder<bool>(
          future: auth.isUserLoggedIn(),
          builder: (context, bool isUserLoggedIn) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                textTheme: TextTheme(
                  bodyText2: TextStyle(
                    fontFamily: 'PatrickHand',
                    fontSize: 17.0,
                  ),
                ),
              ),
              //if user is logged in, send them to home screen
              // other wise, send them to login screen
              initialRoute: isUserLoggedIn ? Home.id : Login.id,
              //for app navigation
              routes: {
                //mapping home ID to home object
                Login.id: (context) => Login(),
                Home.id: (context) => Home(),
              },
            );
          }),
    );
  }
}
