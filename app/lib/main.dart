import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/album.dart';
import 'package:app/transaction.dart';
import 'package:xml2json/xml2json.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

Future<List<Transaction>> fetchTransaction() async {
  final myTranformer = Xml2Json();

  final response = await http.get(Uri.parse(
      'http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?ServiceKey=vp5RvL5ncgGVGqhnbaNFu5DePN1bHRd%2BE3DNYN2WdueSS6y9rS1RDLi45r0tqc7BIDJvsEZaUMhYxOk%2BdcdRdA%3D%3D&LAWD_CD=41135&type=json&pageNo=1&DEAL_YMD=202112'));
  if (response.statusCode == 200) {
    final utf16Body = utf8.decode(response.bodyBytes);
    myTranformer.parse(utf16Body);
    var jsonString = myTranformer.toParker();
    final parsed = jsonDecode(jsonString)['response']['body']['items']['item']
        .cast<Map<String, dynamic>>();
    return parsed
        .map<Transaction>((json) => Transaction.fromJson(json))
        .toList();
  } else {
    throw Exception('Failed to load album');
  }
}

Future<List<Album>> fetchAlbum() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    return parsed.map<Album>((json) => Album.fromJson(json)).toList();
    // return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbums;
  late Future<List<Transaction>> futureTransactions;

  @override
  void initState() {
    super.initState();
    futureAlbums = fetchAlbum();
    futureTransactions = fetchTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: FutureBuilder<List<Transaction>>(
          future: futureTransactions,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (_, index) => Container(
                      child: ListTile(
                          title: Text("${snapshot.data![index].year}"),
                          subtitle: Text("${snapshot.data![index].year}"))));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
