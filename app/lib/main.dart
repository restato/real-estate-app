import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/album.dart';
import 'package:app/transaction.dart';
import 'package:app/transaction_card.dart';
import 'package:xml2json/xml2json.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class OpenAPIResult {
  String numOfRows;
  String totalCount;
  List<Transaction> transactions;

  OpenAPIResult(this.numOfRows, this.totalCount, this.transactions);
}

Future<OpenAPIResult> fetchTransaction(
    String selectedRoadCode, String selectedYear, String selectedMonth) async {
  String pageNo = '1';
  if (selectedRoadCode == '') {
    selectedRoadCode = '41135';
  }
  final myTranformer = Xml2Json();
  final response = await http.get(Uri.parse(
      'http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?ServiceKey=vp5RvL5ncgGVGqhnbaNFu5DePN1bHRd%2BE3DNYN2WdueSS6y9rS1RDLi45r0tqc7BIDJvsEZaUMhYxOk%2BdcdRdA%3D%3D&LAWD_CD=${selectedRoadCode}&type=json&pageNo=${pageNo}&DEAL_YMD=${selectedYear}${selectedMonth}'));
  if (response.statusCode == 200) {
    final utf16Body = utf8.decode(response.bodyBytes);
    myTranformer.parse(utf16Body);
    var jsonString = myTranformer.toParker();
    final parsed = jsonDecode(jsonString)['response']['body']['items']['item']
        .cast<Map<String, dynamic>>();
    String numOfRows = jsonDecode(jsonString)['response']['body']['numOfRows'];
    String totalCount =
        jsonDecode(jsonString)['response']['body']['totalCount'];
    return OpenAPIResult(numOfRows, totalCount,
        parsed.map<Transaction>((json) => Transaction.fromJson(json)).toList());
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

class RoadCode {
  String rcode;
  String siGunGu;
  RoadCode({required this.rcode, required this.siGunGu});
}

class AboutWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('data'),
    );
  }
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbums;
  late Future<List<Transaction>> futureTransactions;
  late Future<OpenAPIResult> openAPIResult;
  String _numOfRows = '';
  String _totalCount = '';
  late List<List<dynamic>> data;
  // List<RoadCode> roadCodes = [];
  List<String> roadCodes = [];
  List<String> siGunGus = [];
  String _selectedSiGunGu = '';
  int _selectedRoadCodeIndex = -1;
  String _selectedRoadCode = '41135';

  final years = List<String>.generate(
      20,
      (i) => DateFormat('yyyy').format(DateTime.utc(
            DateTime.now().year,
            DateTime.now().month,
          ).subtract(Duration(days: i * 365))));
  final List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  String _selectedMonth =
      DateFormat('MM').format(DateTime.utc(DateTime.now().month));
  String _selectedYear =
      DateFormat('yyyy').format(DateTime.utc(DateTime.now().year));

  @override
  void initState() {
    super.initState();
    loadAsset();
    futureAlbums = fetchAlbum();
    openAPIResult =
        fetchTransaction(_selectedRoadCode, _selectedYear, _selectedMonth);
  }

  loadAsset() async {
    var myData = await rootBundle.loadString("assets/res/road_code.csv");
    LineSplitter ls = new LineSplitter();
    List<String> lines = ls.convert(myData);
    setState(() {
      // data = csvTable;
      for (var i = 0; i < lines.length; i++) {
        roadCodes.add(lines[i].split(',')[0]);
        siGunGus.add(lines[i].split(',')[1]);
        // roadCodes.add(RoadCode(
        //     rcode: lines[i].split(',')[0], siGunGu: lines[i].split(',')[1]));
      }
    });
  }

  onSearch(String search) {
    setState(() {
      // _foundedUsers = _users
      //     .where((user) => user.name.toLowerCase().contains(search))
      //     .toList();
    });
  }

  Widget _dropdownBuilder(BuildContext context, String? item) {
    if (item == null) {
      return Container();
    }

    return Container(
      child: (item == null)
          ? ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: CircleAvatar(),
              title: Text("No item selected"),
            )
          : ListTile(
              contentPadding: EdgeInsets.all(0),
              // leading: CircleAvatar(
              //     // this does not work - throws 404 error
              //     // backgroundImage: NetworkImage(item.avatar ?? ''),
              //     ),
              title: Text(item, style: TextStyle(color: Colors.white)),
              // subtitle: Text(
              //   item.createdAt.toString(),
              // ),
            ),
    );
  }

  Widget _popupItemBuilder(
      BuildContext context, String? item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      // decoration: !isSelected
      //     ? null
      //     : BoxDecoration(
      //         border: Border.all(color: Theme.of(context).primaryColor),
      //         borderRadius: BorderRadius.circular(5),
      //         color: Colors.white,
      //       ),
      child: ListTile(
        selected: isSelected,
        title: Text(item ?? '', style: TextStyle(color: Colors.white)),
        // subtitle: Text(item?.createdAt?.toString() ?? ''),
        // leading: CircleAvatar(
        //     // this does not work - throws 404 error
        //     // backgroundImage: NetworkImage(item.avatar ?? ''),
        //     ),
      ),
    );
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
            elevation: 0,
            backgroundColor: Colors.grey.shade900,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 200,
                    child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSearchBox: true,
                      showSelectedItems: true,
                      items: siGunGus,
                      dropdownBuilder: _dropdownBuilder,
                      popupItemBuilder: _popupItemBuilder,
                      searchFieldProps: TextFieldProps(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "검색어를 입력해주세요.",
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          floatingLabelStyle:
                              TextStyle(color: Colors.grey[500]),
                          fillColor: Colors.white,
                          helperStyle: TextStyle(color: Colors.white),
                          prefixStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      popupBackgroundColor: Colors.grey.shade900,
                      dropdownSearchBaseStyle: TextStyle(color: Colors.white),
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "시군구",
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: "👇",
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      popupItemDisabled: (String s) => s.startsWith('I'),
                      onChanged: (String? data) {
                        setState(() {
                          // TODO: Object로 처리하도록 수정
                          _selectedSiGunGu = data!;
                          _selectedRoadCodeIndex = siGunGus.indexWhere(
                              (element) => element == _selectedSiGunGu);
                          _selectedRoadCode = roadCodes[_selectedRoadCodeIndex];

                          openAPIResult = fetchTransaction(
                              _selectedRoadCode, _selectedYear, _selectedMonth);
                        });
                      },
                      selectedItem: siGunGus[roadCodes.indexWhere(
                          (element) => element == _selectedRoadCode)],
                    ),
                  ),
                  Container(
                    width: 200,
                    child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSearchBox: true,
                      showSelectedItems: true,
                      items: years,
                      dropdownBuilder: _dropdownBuilder,
                      popupItemBuilder: _popupItemBuilder,
                      searchFieldProps: TextFieldProps(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "검색어를 입력해주세요.",
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          floatingLabelStyle:
                              TextStyle(color: Colors.grey[500]),
                          fillColor: Colors.white,
                          helperStyle: TextStyle(color: Colors.white),
                          prefixStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      popupBackgroundColor: Colors.grey.shade900,
                      dropdownSearchBaseStyle: TextStyle(color: Colors.white),
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "년",
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: "👇",
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      popupItemDisabled: (String s) => s.startsWith('I'),
                      onChanged: (String? data) {
                        _selectedYear = data!;
                        setState(() {
                          openAPIResult = fetchTransaction(
                              _selectedRoadCode, _selectedYear, _selectedMonth);
                        });
                      },
                      selectedItem: _selectedYear,
                    ),
                  ),
                  Container(
                    width: 200,
                    child: DropdownSearch<String>(
                      mode: Mode.MENU,
                      showSearchBox: true,
                      showSelectedItems: true,
                      items: months,
                      dropdownBuilder: _dropdownBuilder,
                      popupItemBuilder: _popupItemBuilder,
                      searchFieldProps: TextFieldProps(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                          labelText: "검색어를 입력해주세요.",
                          labelStyle: TextStyle(color: Colors.grey[500]),
                          floatingLabelStyle:
                              TextStyle(color: Colors.grey[500]),
                          fillColor: Colors.white,
                          helperStyle: TextStyle(color: Colors.white),
                          prefixStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      popupBackgroundColor: Colors.grey.shade900,
                      dropdownSearchBaseStyle: TextStyle(color: Colors.white),
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "월",
                        labelStyle: TextStyle(color: Colors.white),
                        hintText: "👇",
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      popupItemDisabled: (String s) => s.startsWith('I'),
                      onChanged: (String? data) {
                        _selectedMonth = data!;
                        setState(() {
                          openAPIResult = fetchTransaction(
                              _selectedRoadCode, _selectedYear, _selectedMonth);
                        });
                      },
                      selectedItem: _selectedMonth,
                    ),
                  ),
                ])),
        body: Container(
            color: Colors.grey.shade900,
            child: FutureBuilder<OpenAPIResult>(
              future: openAPIResult,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _numOfRows = snapshot.data!.numOfRows;
                  _totalCount = snapshot.data!.totalCount;
                  // print(_numOfRows);
                  // print(snapshot.data!.transactions.length);
                  // print(_totalCount);
                  return ListView.builder(
                      itemCount: snapshot.data!.transactions.length,
                      itemBuilder: (context, index) => TransactionCard(
                          transaction: snapshot.data!.transactions[index]));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default show a loading spinner.
                return Center(child: const CircularProgressIndicator());
              },
            )),
      ),
    );
  }
}
