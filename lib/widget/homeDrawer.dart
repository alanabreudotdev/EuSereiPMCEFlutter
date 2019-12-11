import 'package:flutter/material.dart';
import '../utils/appsettings.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeDrawer extends StatefulWidget {
  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;
  HomeDrawer(
      {Key key, this.screenIndex, this.iconAnimationController, this.callBackIndex})
      : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList> drawerList;
  @override
  void initState() {
    setdDrawerListArray();
    super.initState();
  }

  void setdDrawerListArray() {
    drawerList = [
      DrawerList(
        index: DrawerIndex.HOME,
        labelName: 'Home',
        icon: new Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.Questoes,
        labelName: 'Questões',
        icon: new Icon(Icons.help),
      ),
      DrawerList(
        index: DrawerIndex.Teoria,
        labelName: 'Teoria',
        icon: new Icon(Icons.help),
      ),
      DrawerList(
        index: DrawerIndex.Profile,
        labelName: 'Meu Perfil',
        icon: new Icon(Icons.account_circle),
      ),
      DrawerList(
        index: DrawerIndex.Share,
        labelName: 'Compartilhar',
        icon: new Icon(Icons.share),
      ),
      DrawerList(
        index: DrawerIndex.About,
        labelName: 'Sobre',
        icon: new Icon(Icons.info),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: AppSettings.notWhite.withOpacity(0.5),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 40.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return new ScaleTransition(
                        scale: new AlwaysStoppedAnimation(
                            1.0 - (widget.iconAnimationController.value) * 0.2),
                        child: RotationTransition(
                          turns: new AlwaysStoppedAnimation(Tween(
                              begin: 0.0, end: 24.0)
                              .animate(CurvedAnimation(
                              parent: widget.iconAnimationController,
                              curve: Curves.fastOutSlowIn))
                              .value /
                              360),
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    offset: Offset(2.0, 4.0),
                                    blurRadius: 8),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 120,
                                  height: 120,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          colors: AppSettings.colorsLinearGradient)),
                                  child: GestureDetector(
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: model.isLoggedIn()
                                          ? model.userData['photoUrl'] == null
                                          ? AssetImage(
                                          'assets/images/user_perfil.png')
                                          : CachedNetworkImageProvider(
                                          model.userData['photoUrl'])
                                          : AssetImage('assets/images/user_perfil.png'),
                                    ),
                                    onTap: () {
                                     /* Navigator.of(context).push(
                                      !model.isLoggedIn()
                                      ? new PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => LoginScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                      new ScaleTransition(scale: animation, child: child),
                                      )
                                          :
                                      new PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => ProfileScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                      new FadeTransition(opacity: animation, child: child),
                                      ));*/
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      "${!model.isLoggedIn() ? "Concurseiro" : model.isLoggedIn() ? model.userData['name'] != null ? model.userData['name'] : 'Concurseiro' : "Concurseiro"}",

                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(0.0),
              itemCount: drawerList.length,
              itemBuilder: (context, index) {
                return inkwell(drawerList[index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              ListTile(
                title: new Text(
                  "Logout",
                  style: new TextStyle(
                    //fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    //color: AppTheme.darkText,
                  ),
                  textAlign: TextAlign.left,
                ),
                trailing: new Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () {},
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      );
  })
    );
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                    // decoration: BoxDecoration(
                    //   color: widget.screenIndex == listData.index
                    //       ? Colors.blue
                    //       : Colors.transparent,
                    //   borderRadius: new BorderRadius.only(
                    //     topLeft: Radius.circular(0),
                    //     topRight: Radius.circular(16),
                    //     bottomLeft: Radius.circular(0),
                    //     bottomRight: Radius.circular(16),
                    //   ),
                    // ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                    width: 24,
                    height: 24,
                    child: Image.asset(listData.imageName,
                        color: widget.screenIndex == listData.index
                            ? Colors.blue
                            : AppSettings.nearlyBlack),
                  )
                      : new Icon(listData.icon.icon,
                     ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  new Text(
                    listData.labelName,
                    style: new TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
              animation: widget.iconAnimationController,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.translationValues(
                      (MediaQuery.of(context).size.width * 0.75 - 64) *
                          (1.0 -
                              widget.iconAnimationController.value -
                              1.0),
                      0.0,
                      0.0),
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Container(
                      width:
                      MediaQuery.of(context).size.width * 0.75 - 64,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: new BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(28),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  void navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

enum DrawerIndex {
  HOME,
  Questoes,
  Teoria,
  Share,
  About,
  Profile,
  Testing,
}

class DrawerList {
  String labelName;
  Icon icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;

  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });
}
