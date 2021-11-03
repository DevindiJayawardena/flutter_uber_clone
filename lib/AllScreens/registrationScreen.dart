import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber_clone/AllWidgets/progressDialog.dart';
import '/AllScreens/loginScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import 'mainscreen.dart';

class RegistrationScreen extends StatelessWidget {

  static const String idScreen = "register";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 0.0,),

              Image(
                image: AssetImage("images/logo.png",),
                width: 280.0,
                height: 280.0,
                alignment: Alignment.center,
              ),


              Text(
                "Register as a Rider",
                style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: "Brand Bold"
                ),
                textAlign: TextAlign.center,
              ),

              Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 1.0,),

                    TextField(
                      controller : nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Name",
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

                    SizedBox(height: 1.0,),

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

                    SizedBox(height: 1.0,),

                    TextField(
                      controller : phoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
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

                    SizedBox(height: 1.0,),

                    TextField(
                      controller: passwordTextEditingController,
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

                    SizedBox(height: 15.0,),

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
                            "Create Account",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold",
                            ),
                          ),
                        ),
                      ),
                      //shape: new RoundedRectangleBorder(
                      //borderRadius: new BorderRadius.circular(24.0),
                      //),
                      onPressed: (){
                        if(nameTextEditingController.text.length < 3) {
                          displayToastMessage("Name must be at least 3 characters!", context);
                        }else if(!emailTextEditingController.text.contains("@")){
                          displayToastMessage("Email Address is not valid!", context);
                        }else if(phoneTextEditingController.text.isEmpty){
                          displayToastMessage("Phone number is necessary!", context);
                        }else if(passwordTextEditingController.text.length < 6){
                          displayToastMessage("Password must be at least 6 characters!", context);
                        }else{
                          registerNewUser(context);
                        }
                      },
                    ),
                  ],
                ),
              ),

              FlatButton(
                onPressed: () {
                  print("Having an account button Clicked !");
                  Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                },
                child : Text(
                  "Already have an Account? Login Here",
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

  void registerNewUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return ProgressDialog(message: "Registering User.. Please wait!",);
      },
    );

    final User? firebaseUser = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text,
        password: passwordTextEditingController.text,
    ).catchError((errMsg) async{
      Navigator.pop(context);
      await displayToastMessage("Error: " + errMsg.toString(), context);
    })).user;

    if(firebaseUser != null){ //user created
      //save user into firebase real-time database
      Map userDataMap = {
        "name" : nameTextEditingController.text.trim(),
        "email" : emailTextEditingController.text.trim(),
        "phone" : phoneTextEditingController.text.trim(),
      };

      usersRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage("Congratulations! Your account has been created", context);
      
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
    }
    else{
      Navigator.pop(context);
      //error occured - display error message
      displayToastMessage("New user account has not been created", context);
    }
  }

}



displayToastMessage(String message, BuildContext context){
  Fluttertoast.showToast(msg: message);
}


