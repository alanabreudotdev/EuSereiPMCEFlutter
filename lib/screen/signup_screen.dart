import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';
import '../model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'home_screen.dart';
import '../utils/appsettings.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model){
          if(model.isLoading)
          return Center(child: AppSettings().buildProgressIndicator(isLoading: model.isLoading),);

          return SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80.0),
            Stack(
              children: <Widget>[
                Positioned(
                  left: 20.0,
                  top: 15.0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20.0)),
                    width: 70.0,
                    height: 20.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: Text(
                    "Nova Conta",
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 8.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: "Nome", hasFloatingPlaceholder: true),
                validator: (text){
                  if(text.isEmpty  ) return "Nome é obrigatório!";
                },
              ),

            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 8.0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                    labelText: "Email", hasFloatingPlaceholder: true),
                validator: (text){
                  if(text.isEmpty || !text.contains("@") ) return "Email inválido";
                },
              ),

            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 8.0),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: "Senha", hasFloatingPlaceholder: true),
                validator: (text){
                  if(text.isEmpty  ) return "Senha é obrigatória!";
                },
              ),
            ),
            
            
            const SizedBox(height: 20.0),
            Align(
              alignment: Alignment.center,
              child: RaisedButton(
                padding: const EdgeInsets.fromLTRB(40.0, 16.0, 30.0, 16.0),
                color: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(30.0))),
                onPressed: () {
                  if(_formKey.currentState.validate()){
                    Map<String, dynamic> userData = {
                      "name": nameController.text,
                      "email": emailController.text,
                    };

                    model.signUp(
                        userData: userData ,
                        pass: passwordController.text,
                        onFail: _onFail,
                        onSuccess: _onSuccess
                    );
                  }

                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    model.isLoading ? AppSettings().buildProgressIndicator(isLoading: model.isLoading) : Text(
                      "CADASTRAR".toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
                    ),

                   
                  ],
                ),
              ),
            ),
            const SizedBox(height: 70.0,),
            Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                padding: const EdgeInsets.fromLTRB(40.0, 16.0, 30.0, 16.0),
                color: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0))),
                onPressed: () {
                   Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => LoginScreen()));

                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Entrar".toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
                    ),
                    const SizedBox(width: 40.0),
                    Icon(
                      FontAwesomeIcons.arrowRight,
                      size: 18.0,
                      color: Colors.white
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlineButton.icon(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 30.0,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.red),
                  color: Colors.red,
                  highlightedBorderColor: Colors.red,
                  textColor: Colors.red,
                  icon: Icon(
                    FontAwesomeIcons.googlePlusG,
                    size: 18.0,
                  ),
                  label: Text("Google"),
                  onPressed: () async{
                    await model.handleSignInGoogle().then((result){
                      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context)=>HomeScreen()));
                    }).catchError((e) {
                      Navigator.of(context).pushReplacement(
                          new MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    });
                  },
                ),
                /*
                const SizedBox(width: 10.0),
                OutlineButton.icon(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 30.0,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  highlightedBorderColor: Colors.indigo,
                  borderSide: BorderSide(color: Colors.indigo),
                  color: Colors.indigo,
                  textColor: Colors.indigo,
                  icon: Icon(
                    FontAwesomeIcons.facebookF,
                    size: 18.0,
                  ),
                  label: Text("Facebook"),
                  onPressed: () async{
                    await model.loginWithFacebook().then((result){
                      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context)=>HomeScreen()));
                    }).catchError((e){
                      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context)=>HomeScreen()));
                    });
                  },
                ),
                */
              ],
            ),
            SizedBox(height: 10,),
            Container(
                padding: const EdgeInsets.only(right: 16.0),
                alignment: Alignment.center,
                child: FlatButton(
                  onPressed: (){
                    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (builder)=>HomeScreen()));
                  },
                  child: Text("continuar sem logar",),)
            ),
          ],
        ),
        )
      );
        },
      )
    );
  }

  void _onSuccess(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('Usuário criado com sucesso'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: Duration(seconds: 2)
      )
    );
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => HomeScreen()));
    });

  }

  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('Falha ao criar usuário!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2)
        )
    );
  }

}