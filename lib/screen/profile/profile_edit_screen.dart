import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:share/share.dart';
import '../../utils/appsettings.dart';
import '../home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';


class ProfileEditScreen extends StatefulWidget {
  @override
  State createState() => new ProfileEditScreenState();
}

class ProfileEditScreenState extends State<ProfileEditScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  TextEditingController controllerName;
  TextEditingController controllerEmail;

  SharedPreferences prefs;

  UserModel modelTest;

  var userData;
  var userDados;

  String uid = '';
  String name = '';
  String email = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();

  @override
  void initState() {

    super.initState();
    readLocal();

  }

  void readLocal() async {
    print("ENTREIII AQUIIII");
    prefs = await SharedPreferences.getInstance();
    
    String dados = await prefs.getString('userDados');

    setState(() {
       userDados = jsonDecode(dados);
       print('USERRRRRR: $userDados');
    });
    

    setState(() {
        uid = userDados["UID"] ?? '';
        name = userDados["name"] ?? '';
        email = userDados["email"] ?? '';
        photoUrl = userDados["photoUrl"] ?? '';
      });

    
      print("DADOSSSSSS: $userDados");
     
    print("USUARIO ID $uid");

    controllerName = new TextEditingController(text: name);
    controllerEmail = new TextEditingController(text: email);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    print("AVATAR: $uid");
    String fileName = uid;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(uid)
              .updateData({'name': name, 'email': email, 'photoUrl': photoUrl}).then((data) async {
            var dados;
            setState(() {
              userData = {
                'name' : name,
                'photoUrl' : photoUrl,
                'email' : email,
                'UID': uid,
              };
              dados = jsonEncode(userData);

            });
            print('SALVANDO...');
            await _updateRankingUser();
            await prefs.setString('userDados',dados);
            await modelTest.updateProfile();
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Enviado com sucesso!");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Este arquivo não é uma imagem.');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Este arquivo não é uma imagem.');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {

    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    if(photoUrl == "" || photoUrl == null){
      photoUrl = "http://www.appdoantigao.com.br/uploads/user_default.png";
    }

    print('PHOTOURL: $photoUrl');

    Firestore.instance
        .collection('users')
        .document(uid)
        .updateData({'name': name, 'email': email, 'photoUrl': photoUrl}).then((data) async {
     

      var dados;
      setState(() {
        userData = {
          'name' : name,
          'photoUrl' : photoUrl,
          'email' : email,
          'UID': uid,
        };

        dados = jsonEncode(userData);

      });
      await _updateRankingUser();
      print('SALVANDO...$uid');
      await prefs.setString('userDados',dados);

      await modelTest.updateProfile();

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Atualizado com sucesso!");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  _updateRankingUser() async {
    var userRanking = {
      'user_id'     : uid,
      'name'        : name,
      'photo_url'   : photoUrl
    };

    var response =   await CallApi().postData(userRanking, 'ranking/update');


    print("RESPONSE: ${response['success']}");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffold,
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          modelTest = model;
          return Stack(
            children: <Widget>[

              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 6),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: IconButton(
                                icon:
                                Icon(FontAwesomeIcons.reply),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ),
                          SizedBox(
                            width: 120,
                            child: Text(
                              "Editar Perfil",
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Expanded(child: SizedBox()),
                          Expanded(child: SizedBox()),

                        ],
                      ),
                    ),
                    Container(
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            (avatarImageFile == null)
                                ? (photoUrl != ''
                                ? Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                  width: 90.0,
                                  height: 90.0,
                                  padding: EdgeInsets.all(20.0),
                                ),
                                imageUrl: photoUrl,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            )
                                : Icon(
                              Icons.account_circle,
                              size: 90.0,
                            ))
                                : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                              ),
                              onPressed: getImage,
                              padding: EdgeInsets.all(30.0),
                              splashColor: Colors.transparent,
                              iconSize: 30.0,
                            ),
                          ],
                        ),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.all(20.0),
                    ),

                    // Input
                    Column(
                      children: <Widget>[
                        // Username
                        Container(
                          child: Text(
                            'Nome',
                            style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                        ),
                        Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(primaryColor: Colors.green),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Nome',
                                contentPadding: new EdgeInsets.all(5.0),
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              controller: controllerName,
                              onChanged: (value) {
                                name = value;
                              },
                              focusNode: focusNodeNickname,
                            ),
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),

                        // About me
                        Container(
                          child: Text(
                            'Email',
                            style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                        ),
                        Container(
                          child: Theme(
                            data: Theme.of(context).copyWith(primaryColor: Colors.red),
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                //hintText: 'digite seu email...',
                                contentPadding: EdgeInsets.all(5.0),
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              controller: controllerEmail,
                              onChanged: (value) {
                                email = value;
                              },
                              focusNode: focusNodeAboutMe,
                            ),
                          ),
                          margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),

                    // Button
                    Container(
                      child: FlatButton(
                        onPressed: handleUpdateData,
                        child: Text(
                          'SALVAR',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        color: Colors.red,
                        highlightColor: new Color(0xff8d93a0),
                        splashColor: Colors.transparent,
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                      ),
                      margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
              ),

              // Loading
              Positioned(
                child: isLoading
                    ? Container(
                  child: Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
                    : Container(),
              ),
            ],
          );
    }
      ),
    ),
    );
  }
}