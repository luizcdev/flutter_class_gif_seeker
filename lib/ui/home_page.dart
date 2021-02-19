import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _search;

  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if(_search == null)
      response = await http.get("https://api.giphy.com/v1/gifs/trending?api_key=e1p4AZ5NcIcKxSbQ5YDQHr6ucbXS456E&limit=20&rating=g");
    else
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=e1p4AZ5NcIcKxSbQ5YDQHr6ucbXS456E&q=$_search&limit=20&offset=$_offset&rating=g&lang=pt");

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding:EdgeInsets.all(10.0),
             child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquise Aqui",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,)
          ),
          Expanded(
              child: FutureBuilder(
                future: _getGifs(),
                builder: _loadGifsBuilder,
              )
          )
        ],
      )
    );
  }

  Widget _loadGifsBuilder (BuildContext context, AsyncSnapshot snapshot){

    switch(snapshot.connectionState){
      case ConnectionState.waiting:
      case ConnectionState.none:
        return Container(
          width: 200.0,
          height: 200.0,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 5.0,
          ),
        );
      default:
        if (snapshot.hasError) return Container();
        else return _createGifTable(context, snapshot);
    }

  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {

    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0
        ),
        itemCount: snapshot.data["data"].length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
          ); 
        }
    );


  }
}

