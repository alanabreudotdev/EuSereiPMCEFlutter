import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' show Future;
import 'home_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import '../utils/appsettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



class LeiSecaScreen extends StatefulWidget {

  final titulo;
  final nameLei;

  LeiSecaScreen(this.titulo, this.nameLei);

  @override
  _LeiSecaScreenState createState() => _LeiSecaScreenState();
}

class _LeiSecaScreenState extends State<LeiSecaScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  var lei;
  bool _isLoading = false;
  String assetPDFPath = "";

  PDFDocument document;

  @override
  void initState()  {
    _isLoading = true;
    // TODO: implement initState
    super.initState();
    loadAsset();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    document = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
            child: AppSettings()
                .buildProgressIndicator(isLoading: _isLoading))
            : Column(
          children: <Widget>[
            AppSettings().appBar(
                context: context,
                title: widget.titulo,
                hasMenu: false,
                hasBack: true,
                scaffoldkey: _scaffold.currentState,
                icon: FontAwesomeIcons.listOl),
            Expanded(child: PDFViewer(
              document: document,

              tooltip: PDFViewerTooltip(
                  pick: "Selecione uma página",
                  next: "Próximo",
                  last: "Última",
                  previous: "Anterior",
                  first: "Primeira",
                  jump: "Pular"),))
          ],
        )
      ),
    );
  }


  Future<PDFDocument> loadAsset() async {

    document = await PDFDocument.fromAsset('assets/pdfs/${widget.nameLei}');
    setState(() {
      _isLoading = false;
    });

    return document;

  }



}


