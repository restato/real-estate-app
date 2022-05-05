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

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

Future<List<Transaction>> fetchTransaction(String selectedRoadCode) async {
  if (selectedRoadCode == '') {
    selectedRoadCode = '41135';
  }

  final myTranformer = Xml2Json();
  final response = await http.get(Uri.parse(
      'http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?ServiceKey=vp5RvL5ncgGVGqhnbaNFu5DePN1bHRd%2BE3DNYN2WdueSS6y9rS1RDLi45r0tqc7BIDJvsEZaUMhYxOk%2BdcdRdA%3D%3D&LAWD_CD=${selectedRoadCode}&type=json&pageNo=1&DEAL_YMD=202112'));
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

class RoadCode {
  String rcode;
  String siGunGu;
  RoadCode({required this.rcode, required this.siGunGu});
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbums;
  late Future<List<Transaction>> futureTransactions;
  late List<List<dynamic>> data;
  // List<RoadCode> roadCodes = [];
  List<String> roadCodes = [];
  List<String> siGunGus = [];
  String _selectedSiGunGu = '';
  int _selectedRoadCodeIndex = -1;
  String _selectedRoadCode = '41135';

  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';

  /// The method for [DateRangePickerSelectionChanged] callback, which will be
  /// called whenever a selection changed on the date picker widget.
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    setState(() {
      if (args.value is PickerDateRange) {
        _range = '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadAsset();
    futureAlbums = fetchAlbum();
    futureTransactions = fetchTransaction(_selectedRoadCode);
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
                          futureTransactions =
                              fetchTransaction(_selectedRoadCode);
                        });
                      },
                      selectedItem: siGunGus[roadCodes.indexWhere(
                          (element) => element == _selectedRoadCode)],
                    ),
                  ),
                  // Container(
                  //   width: 200,
                  //   child: DropdownSearch<String>(
                  //     mode: Mode.MENU,
                  //     showSelectedItems: true,
                  //     items: ["성남시 분당구"],
                  //     // ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
                  //     dropdownSearchDecoration: InputDecoration(
                  //       labelText: "Menu mode",
                  //       hintText: "country in menu mode",
                  //     ),
                  //     popupItemDisabled: (String s) => s.startsWith('I'),
                  //     onChanged: print,
                  //     selectedItem: "성남시 분당구",
                  //   ),
                  // ),
                ])
            // title: Container(
            //     height: 38,
            //     child: TextField(
            //       onChanged: (value) => onSearch(value),
            //       decoration: InputDecoration(
            //           filled: true,
            //           fillColor: Colors.grey[850],
            //           contentPadding: EdgeInsets.all(0),
            //           prefixIcon: Icon(
            //             Icons.search,
            //             color: Colors.grey.shade500,
            //           ),
            //           border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(50),
            //               borderSide: BorderSide.none),
            //           hintStyle:
            //               TextStyle(fontSize: 14, color: Colors.grey.shade500),
            //           hintText: "지역 검색"),
            //     ))
            ),
        body:
            // Container(
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     mainAxisSize: MainAxisSize.min,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: <Widget>[
            //       Text('Selected date: $_selectedDate'),
            //       Text('Selected date count: $_dateCount'),
            //       Text('Selected range: $_range'),
            //       Text('Selected ranges count: $_rangeCount')
            //     ],
            //   ),
            // ),
            // Container(
            //   child: SfDateRangePicker(
            //     view: DateRangePickerView.month,
            //     onSelectionChanged: _onSelectionChanged,
            //     selectionMode: DateRangePickerSelectionMode.single,
            //     initialSelectedRange: PickerDateRange(
            //         DateTime.now().subtract(const Duration(days: 4)),
            //         DateTime.now().add(const Duration(days: 3))),
            //   ),
            // ),
            // ListView
            // Container(child: Text("${roadCodes}")),
            Container(
                color: Colors.grey.shade900,
                child: FutureBuilder<List<Transaction>>(
                  future: futureTransactions,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (_, index) => TransactionCard(
                              transaction: snapshot.data![index]));
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
