
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/appsettings.dart';
import '../utils/api.dart';
import 'package:flutter/material.dart';

class VideosScreen extends StatefulWidget {
  @override
  _VideosScreenState createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {


  DEV dev;

  bool _isLoading = false;
  var dadosVideo;
  var videoList;

  bool theme;

  initState(){
    setState(() {
      _isLoading = true;
    });
    super.initState();
    _getDados();
  }

  Widget _buildContent(BuildContext context) {

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatar(),
          _buildInfo(),
          _buildVideoScroller(),
          //_buildbuton(context),
        ],
      ),
    );
  }

  Widget _buildbuton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RaisedButton(
          color: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            'Voltar',
            style: TextStyle(color: Colors.white70),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 110.0,
      height: 110.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Color(int.parse(AppSettings.primaryColor))),
      ),
      margin: const EdgeInsets.only(top: 60.0, left: 16.0),
      padding: const EdgeInsets.all(3.0),
      child: ClipOval(
        child: CachedNetworkImage(imageUrl: dev.avatar),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            dev.firstName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          Text(dev.lastName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 16.0),
            width: 225.0,
            height: 1.0,
          ),
          Text(
            dev.biography,
            style: TextStyle(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoScroller() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox.fromSize(
        size: Size.fromHeight(245.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: videoList.length,
          itemBuilder: (BuildContext context, int index) {
            print(videoList);
            var video = videoList[index];

            return Container(
              width: 175.0,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    spreadRadius: 2.0,
                    blurRadius: 10.0,
                    color: Colors.black26,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(flex: 3, child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(imageUrl: video['thumbnail'],),
                        Positioned(
                          bottom: 12.0,
                          right: 12.0,
                          child: Material(
                            color: Colors.black87,
                            type: MaterialType.circle,
                            child: InkWell(
                              onTap: () async {
                                if (await canLaunch(video['url'])) {
                                  await launch(video['url']);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  Flexible(flex: 2, child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 4.0, right: 4.0),
                    child: Text(
                      video['title'],
                    ),
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: AppSettings().buildProgressIndicator(isLoading: _isLoading),):Stack(
        fit: StackFit.expand,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 50.0,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CachedNetworkImage(imageUrl: dev.backdropPhoto, fit: BoxFit.cover),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: theme ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7) ,
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  _getDados() {
     Future.delayed(Duration(seconds: 1)).then((_) async{
      var response = await CallApi().getData('canaldomoral');
      theme = await AppSettings().getThemeDefault();
      setState(() {
        dadosVideo = response['dadosCanal'];
        videoList = response['videos'];
        print(dadosVideo);
        dev = DEV(
          avatar:dadosVideo['thumbnails'],
          backdropPhoto: '${AppSettings.url}/media/photos/photo3@2x.jpg',
          biography:  dadosVideo['description'],
          firstName:  dadosVideo['title'],
          lastName: "Lembre-se, quanto mais estudamos, menos serão as injustiças!",
          location: "",
          //videos: videoList
        );
        //print(dadosVideo['videos']);
        _isLoading = false;
      });
    });
  }
}





class DEV {
  DEV({
    @required this.firstName,
    @required this.lastName,
    @required this.avatar,
    @required this.backdropPhoto,
    @required this.location,
    @required this.biography,
    //@required this.videos,
  });

  final String firstName;

  final String lastName;

  final String avatar;

  final String backdropPhoto;

  final String location;

  final String biography;

  //final List videos;
}

class Video {
  Video({
    @required this.title,
    @required this.thumbnail,
    @required this.url,
  });

  final String title;

  final String thumbnail;

  final String url;
}



