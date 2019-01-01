/********************************************************************/
/* This is the login page. The look and feel of the google login    */
/* can be edited from here.                                         */
/********************************************************************/
import 'package:flutter/material.dart';

import 'package:firebase_login/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState(){
    super.initState();
    isSignedIn();
  }
  void isSignedIn() async {
    this.setState((){
      isLoading = true;
    });
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn){
      Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => MainScreen(currentUserId: prefs.getString('id'))
        ));
    }

    this.setState(() {
      isLoading = false;
    });
  }


  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'name': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('name', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('name', documents[0]['name']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Welcome ${firebaseUser.displayName}"); //Check this line when toast throws an error
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  currentUserId: firebaseUser.uid,
                )),
      );
    } else {
      Fluttertoast.showToast(msg: "We could not sign you in, try again..."); //Try again if login fails
      this.setState(() {
        isLoading = false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return 
Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("Co-SocialNet",
              style: TextStyle(fontSize: 30.0, color: Colors.white)
              ),
              SizedBox(height: 16.0,),
            new RaisedButton(
              onPressed: handleSignIn,
              shape: StadiumBorder(),
              splashColor: Colors.transparent,
              child: new Text("SIGN IN WITH GOOGLE",
                style: TextStyle(fontSize: 16.0, color: Colors.deepOrange)
                ),
            ),
            isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      color: Colors.deepOrange,
                    )
                  : Container(),
          ],
        ),
      ),
    );
  }
}








// Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "Co-SocialNet",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//         ),
//         body: Stack(
//           children: <Widget>[
//             Center(
//               child: FlatButton(
//                   onPressed: handleSignIn,
//                   child: Text(
//                     'SIGN IN WITH GOOGLE',
//                     style: TextStyle(fontSize: 16.0),
//                   ),
//                   color: Color(0xffdd4b39),
//                   highlightColor: Color(0xffff7f7f),
//                   splashColor: Colors.transparent,
//                   textColor: Colors.white,
//                   padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
//             ),

//             // Loading
//             Positioned(
//               child: isLoading
//                   ? Container(
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(themeColor),
//                         ),
//                       ),
//                       color: Colors.white.withOpacity(0.8),
//                     )
//                   : Container(),
//             ),
//           ],
//         ));