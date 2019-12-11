import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:convert';


class UserModel extends Model {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //ranking
  SharedPreferences localStorage;
  

  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();
  Map<String, dynamic> userRanking = Map();

  bool isLoading = false;


  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    _loadCurrentUser();
  }

  bool isLoggedIn(){
    return firebaseUser !=null;
  }

  void signOut() async {
    await _auth.signOut();
    if(_googleSignIn.currentUser != null)
      await _googleSignIn.disconnect();

    userData = Map();
    firebaseUser = null;

    //await localStorage.setInt('totalQuestoes',0);
    //await localStorage.setInt('totalAcertos',0);
    //await localStorage.setInt('totalErros',0);


    notifyListeners();
  }

  void recoverPass(String email){
      _auth.sendPasswordResetEmail(email: email);
  }
  /**  LOGIN WITH FACEBOOK **/
  Future<FirebaseUser> loginWithFacebook() async {

    isLoading = true;
    notifyListeners();

    var facebookLogin = new FacebookLogin();
    var result =  await facebookLogin.logInWithReadPermissions(['email', 'public_profile']);
    print('RESULTADO: ${result.status}');
    if (result.status == FacebookLoginStatus.cancelledByUser) {
      // user canceled the sign-in, do your cancellation logic here.
      isLoading = false;
      notifyListeners();
    }

    if (result.status == FacebookLoginStatus.loggedIn) {
      FacebookAccessToken myToken = result.accessToken;
      AuthCredential credential =
      FacebookAuthProvider.getCredential(accessToken: myToken.token);

      firebaseUser =  (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      print(firebaseUser);

      userData = {
        'name' : firebaseUser.displayName,
        'photoUrl' : firebaseUser.photoUrl,
        'email' : firebaseUser.email,
        'UID': firebaseUser.uid,
      };

      print("signed in " + firebaseUser.displayName);
      print("photo " + firebaseUser.photoUrl);

      localStorage = await SharedPreferences.getInstance();
      var dadosUser = jsonEncode(userData);
      await localStorage.setString('userDados',dadosUser);

      await _saveUserData(userData);

      //await getRanking();

      isLoading = false;
      notifyListeners();

      return firebaseUser;
    }
  }

  /**LOGIN WITH GOOGLE **/
  Future<FirebaseUser> handleSignInGoogle() async {
    isLoading = true;
    notifyListeners();

    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    print("GOOGLE USER: $googleUser");
    if (googleUser == null) {
      // user canceled the sign-in, do your cancellation logic here.
      isLoading = false;
      notifyListeners();

    }else{
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("ACCESS TOKEN: ${googleAuth.accessToken}");
      print("ID TOKEN: ${googleAuth.idToken}");

      await _auth.signInWithCredential(credential).then((user) async{

        firebaseUser = user.user;

        userData = {
          'name' : firebaseUser.displayName,
          'photoUrl' : firebaseUser.photoUrl,
          'email' : firebaseUser.email,
          'UID': firebaseUser.uid,
        };

        print("signed in " + firebaseUser.displayName);
        print("photo " + firebaseUser.photoUrl);

        localStorage = await SharedPreferences.getInstance();
        var dadosUser = jsonEncode(userData);
        await localStorage.setString('userDados',dadosUser);

        await _saveUserData(userData);

        await _loadCurrentUser();

        isLoading = false;
        notifyListeners();

      }).catchError((e){
        print(e);
        isLoading = false;
        notifyListeners();
      });


      print('GOOGLE RETORNO:$firebaseUser');
      return firebaseUser;
    }


  }

  /*
   * METHOD CREATE USER
   */
  Future<void> signUp({@required Map<String, dynamic> userData, @required String pass, @required VoidCallback onSuccess, @required VoidCallback onFail}){
    isLoading = true;
    notifyListeners();


    print(userData);

    _auth.createUserWithEmailAndPassword(
      email: userData['email'],
      password: pass
    ).then((user) async{
      firebaseUser = user.user;
      print("FIREBASE USER: ${firebaseUser}");

      userData = {
        'name' : userData['name'],
        'photoUrl' : firebaseUser.photoUrl,
        'email' : userData['email'],
        'UID': firebaseUser.uid,
      };


      localStorage = await SharedPreferences.getInstance();
      var dadosUser = jsonEncode(userData);
      await localStorage.setString('userDados',dadosUser);

      await _saveUserData(userData);
      await _loadCurrentUser();

      onSuccess();
      isLoading = false;
      notifyListeners();

    }).catchError((e){
      onFail();
      print(e);
      isLoading = false;
    notifyListeners();
    });
  }

    /*
    * METHOD LOGIN
     */
  void signIn({@required String email, @required String pass,
      @required VoidCallback onSuccess, @required VoidCallback onFail}) async{

    isLoading = true;
    notifyListeners();

    _auth.signInWithEmailAndPassword(email: email, password: pass).then(
        (user) async{

          firebaseUser = user.user;
          print("FIREBASE USER: ${firebaseUser}");
          userData = {
            'name' : firebaseUser.displayName,
            'photoUrl' : firebaseUser.photoUrl,
            'email' : firebaseUser.email,
            'UID': firebaseUser.uid,
          };


          localStorage = await SharedPreferences.getInstance();
          var dadosUser = jsonEncode(userData);
          await localStorage.setString('userDados',dadosUser);

          await _loadCurrentUser();


          onSuccess();
          isLoading = false;
          notifyListeners();

        }).catchError((e){
            onFail();
            isLoading = false;
            notifyListeners();
    });

    isLoading = false;
    notifyListeners();
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async{
    this.userData = userData;

    localStorage = await SharedPreferences.getInstance();
    var dadosUser = jsonEncode(userData);
    await localStorage.setString('userDados',dadosUser);
    await Firestore.instance.collection("users").document(firebaseUser.uid).setData(this.userData);
  }

  Future<Null> _loadCurrentUser() async{
    if(firebaseUser == null)
      firebaseUser = await _auth.currentUser();
    if(firebaseUser != null){
      //if(userData['name'] == null){
        DocumentSnapshot docUser =
            await Firestore.instance.collection('users').document(firebaseUser.uid).get();
        userData = docUser.data;

        if(userData.containsKey('UID')){
          print('## TEM USERUID ## : ${userData["UID"]}');
        }else{
          await Firestore.instance.collection('users')
             .document(firebaseUser.uid)
             .updateData({'UID': firebaseUser.uid});
          userData = {
            'name' : firebaseUser.displayName,
            'photoUrl' : firebaseUser.photoUrl,
            'email' : firebaseUser.email,
            'UID': firebaseUser.uid,
          };
          print('## nao tem ## : ${userData}');
          //await signOut();
        }

        localStorage = await SharedPreferences.getInstance();
        var dadosUser = jsonEncode(userData);
        await localStorage.setString('userDados',dadosUser);
        print('## USERDATA ## : ${dadosUser}');
      //}
    }
    notifyListeners();
  }


  Future updateProfile() async {

    _loadCurrentUser();
  }


}