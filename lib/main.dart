import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AllScreens/registrationScreen.dart';

import 'AllScreens/loginScreen.dart';
import 'AllScreens/mainscreen.dart';
import 'DataHandler/appData.dart';

void main() async{
  //here we have to initialize the firebase app. Otherwise, we'll get errors.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


//this is done to create a reference to the firebase real-time database.
//whenever a brand new account has been created by a new user, those information will be saved in this 'users' node in the
// firebase real-time database.
DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users");



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),  //here we initialize the 'AppData' class. (import 'DataHandler/appData.dart';)
            //without initialising that we can't access all of there data from other screens in our application.
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uber Clone App',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null ? LoginScreen.idScreen : MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen: (context) => RegistrationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) => MainScreen(),
        },
      ),
    );
  }
}


