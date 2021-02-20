import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:gif_seeker/ui/gif_page.dart';
import 'package:share/share.dart';

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
      response = await http.get("https://api.giphy.com/v1/gifs/search?api_key=e1p4AZ5NcIcKxSbQ5YDQHr6ucbXS456E&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt");

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
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
             )
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

  int _getCount(List data){
    return _search==null ? data.length : data.length +1;
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {

    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0
        ),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length) {
            return GestureDetector(
              child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GifPage(snapshot.data["data"][index]))
                );
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.white, size: 70.0),
                    Text("Carregar mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22.0)
                    )
                  ]
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        }
    );


  }
}

