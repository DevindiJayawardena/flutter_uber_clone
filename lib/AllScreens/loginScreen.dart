import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber_clone/AllScreens/registrationScreen.dart';
import 'package:flutter_uber_clone/AllWidgets/progressDialog.dart';
import 'package:flutter_uber_clone/main.dart';

import 'mainscreen.dart';

class LoginScreen extends StatelessWidget {

  static const String idScreen = "login";

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0,),

              Image(
                image: AssetImage("images/logo.png",),
                width: 300.0,
                height: 300.0,
                alignment: Alignment.center,
              ),

              SizedBox(height: 1.0,),

              Text(
                "Login as a Rider",
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: "Brand Bold"
                ),
                textAlign: TextAlign.center,
              ),

              Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 5.0,),

                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize : 14.0,
                          fontFamily: "Brand-Regular",
                        ),
                        hintStyle: TextStyle(
                          color : Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),

                    SizedBox(height: 5.0,),

                    TextField(
                      controller: passwordTextEditingController,
                      //keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize : 14.0,
                          fontFamily: "Brand-Regular",
                        ),
                        hintStyle: TextStyle(
                          color : Colors.grey,
                          fontSize: 10.0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),

                    SizedBox(height: 20.0,),

                    ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.white12)
                          ),
                        ),
                      ),
                      child: Container(
                        height: 50.0,
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                            ),
                          ),
                        ),
                      ),
                      onPressed: (){
                        print("Login Button Clicked!");
                        if(!emailTextEditingController.text.contains("@")){
                          displayToastMessage("Email Address is not valid!", context);
                        }else if(passwordTextEditingController.text.isEmpty){
                          displayToastMessage("Password is necessary!", context);
                        }else{
                         loginAndAuthenticateUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),

              FlatButton(
                onPressed: () {
                  print("Not having account button Clicked !");
                  Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
                },
                child : Text(
                  "Do not have an Account? Register Here",
                  style: TextStyle(
                    fontFamily: "Brand Regular",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  //this is done bcz first of all we authenticate the users using the firebase authentication. So, that's why we create
  // an instance of the firebase authentication like below.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void loginAndAuthenticateUser(BuildContext context) async{
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return ProgressDialog(message: "Authenticating User.. Please wait!",);
        },
    );

    final User? firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(
      email: emailTextEditingController.text,
      password: passwordTextEditingController.text,
    ).catchError((errMsg) async{
      Navigator.pop(context); //this will close that dialogbox
      await displayToastMessage("Error: " + errMsg.toString(), context);
    })).user;

    if(firebaseUser != null){
      usersRef.child(firebaseUser.uid).once().then((DataSnapshot snap) {
        if(snap.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          displayToastMessage("You are logged in now!", context);
        }
        else{
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage("No record exists or this user. PLease Create a New Account!", context);
        }
      });
    }
    else{
      Navigator.pop(context);
      //error occured - display error message
      displayToastMessage("Error occured! Cannot Sign in", context);
    }
  }

}
