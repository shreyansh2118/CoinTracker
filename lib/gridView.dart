import 'package:demo/tableView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String api1Url = "https://intradayscreener.com/api/openhighlow/cash";
  String api2Url =
      "https://intradayscreener.com/api/allQuotesCompact/?isPivots=true";

  List<dynamic> api1Data = [];
  List<dynamic> api2Data = [];

  List<String> api1Fields = [
    'openHighLowSignal',
    'ltp',
    'pctChange',
    'stockOutperformanceRank'
  ];

  List<String> api2Fields = [
    'open',
    'oiChange',
    'low',
    'intradayPivots.pp',
    'intradayPivots.r1',
    'intradayPivots.r2',
    'intradayPivots.r3',
    'intradayPivots.s1',
    'intradayPivots.s2',
    'intradayPivots.s3'
  ];

  bool isLoading = true; // loading indicator

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Show loader while fetching data
    });

    try {
      await fetchApiData(api1Url).then((data) {
        setState(() {
          api1Data = data;
        });
      });

      await fetchApiData(api2Url).then((data) {
        setState(() {
          api2Data = data;
          isLoading = false; // Hide loader after fetching data
        });
      });
    } catch (e) {
      // Handle error (e.g., show an error message)
      print('Error fetching data: $e');
      setState(() {
        isLoading = false; // Hide loader on error
      });
    }
  }

  Future<List<dynamic>> fetchApiData(String apiUrl) async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  List getCommonSymbols() {
    List<String> symbolsApi1 =
        api1Data.map((entry) => entry['symbol']).cast<String>().toList();
    List<String> symbolsApi2 =
        api2Data.map((entry) => entry['symbol']).cast<String>().toList();

    Set commonSymbols =
        Set.from(symbolsApi1).intersection(Set.from(symbolsApi2));
    return commonSymbols.toList();
  }


  dynamic getFieldValue(Map<String, dynamic> data, String field) {
    List<String> fieldParts = field.split('.');
    dynamic value = data;

    for (var part in fieldParts) {
      if (value != null && value is Map<String, dynamic>) {
        value = value[part];
      } else {
        return null; // Handle null or unexpected data structure
      }
    }

    return value;
  }

  Widget buildSymbolCard(String symbol) {
    List<Map<String, dynamic>> api1Values = api1Data
        .where((entry) => entry['symbol'] == symbol)
        .toList()
        .cast<Map<String, dynamic>>();
    List<Map<String, dynamic>> api2Values = api2Data
        .where((entry) => entry['symbol'] == symbol)
        .toList()
        .cast<Map<String, dynamic>>();

    // Extracting values for comparison
    double ltpValue = api1Values[0]['ltp'];
    double s3 = getFieldValue(api2Values[0], 'intradayPivots.s3');
    double s2 = getFieldValue(api2Values[0], 'intradayPivots.s2');
    double s1 = getFieldValue(api2Values[0], 'intradayPivots.s1');
    double pp = getFieldValue(api2Values[0], 'intradayPivots.pp');
    double r1 = getFieldValue(api2Values[0], 'intradayPivots.r1');
    double r2 = getFieldValue(api2Values[0], 'intradayPivots.r2');
    double r3 = getFieldValue(api2Values[0], 'intradayPivots.r3');

    String minstr = "";
    double minvalue = 0;
    String maxstr = "";
    double maxvalue = 1;

    // Implementing the logic
    if (s3 < ltpValue && ltpValue < s2) {
      minstr = "S3";
      minvalue = s3;
      maxstr = "S2";
      maxvalue = s2;
    } else if (s2 < ltpValue && ltpValue < s1) {
      minstr = "S2";
      minvalue = s2;
      maxstr = "S1";
      maxvalue = s1;
    } else if (s1 < ltpValue && ltpValue < pp) {
      minstr = "S1";
      minvalue = s1;
      maxstr = "PP";
      maxvalue = pp;
    } else if (pp < ltpValue && ltpValue < r1) {
      minstr = "PP";
      minvalue = pp;
      maxstr = "R1";
      maxvalue = r1;
    } else if (r1 < ltpValue && ltpValue < r2) {
      minstr = "R1";
      minvalue = r1;
      maxstr = "R2";
      maxvalue = r2;
    } else if (r2 < ltpValue && ltpValue < r3) {
      minstr = "R2";
      minvalue = r2;
      maxstr = "R3";
      maxvalue = r3;
    } else if (s3 > ltpValue || ltpValue > r3) {
      minstr = "";
      minvalue = 0;
      maxstr = "";
      maxvalue = 1;
    }

    var minValue = minvalue;
    var maxValue = maxvalue;

    List<dynamic> intradayScans = api1Values[0]['allScans']['intradayScans'];  // list fro allScans

    //horizontal scrollable list of cards
    Widget horizontalScanList = Container(
      width: 150,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: intradayScans.map((scan) {
            return Card(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  scan['scanShortcode'].toString(),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                        child: SvgPicture.network(
                          'https://intradayscreener.com/app/assets/images/stock_logos/${symbol}.svg',
                          width: 38,
                          height: 38,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('$symbol',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline)),
                    // slider list call
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3.5,
                    ),
                    horizontalScanList,
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // First Container
                  Container(
                    width: 175,
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Range"),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text('${api2Values[0]['low']}'),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              width: 30,
                              child: LinearProgressIndicator(
                                value: (api2Values[0]['high'] -
                                        api2Values[0]['low']) /
                                    100.0,
                                backgroundColor:
                                    Colors.blue[50], // Background color
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue), // Progress color
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('${api2Values[0]['high']}'),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        // Text('Pivot PP: ${getFieldValue(api2Values[0], 'intradayPivots.pp')}'),
                        // SizedBox(height: 10,),
                        // Text('Min: $minstr (${minvalue.toString()})'),
                        // Text('Max: $maxstr (${maxvalue.toString()})'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pivot'),
                            Row(
                              children: [
                                Text(
                                  '$minstr',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                                SizedBox(width: 10.0),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
                                  width: 50,
                                  height: 7,
                                  child: LinearProgressIndicator(
                                    value: (maxValue - minValue) / 100.0,
                                    backgroundColor:
                                        Colors.blue[50], // Background color
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green), // Progress color
                                  ),
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  '$maxstr',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Second Container
                  Container(
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Momentum'),
                        Row(
                          children: [
                            Container(color:Colors.grey,
                                child: Text('${api1Values[0]['stockMomentumRank']}')),
                            SizedBox(
                              width: 10,
                            ),
                            Container(color:Colors.grey,
                                child: Text('${api1Values[0]['stockOutperformanceRank']}')),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('LTP'),
                        Row(
                          children: [
                            Text(
                              api1Values[0]['ltp'].toString(),
                            ),
                            Text(
                              '(${api1Values[0]['pctChange'].toString()}%)',
                              style: TextStyle(
                                color: api1Values[0]['pctChange'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Third Container
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text('OI Ch.% '),
                        Row(
                          children: [
                            Icon(
                              api1Values[0]['pctChange'] >= 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: api1Values[0]['pctChange'] >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            Text(
                              '${api1Values[0]['pctChange'].toString()}%',
                              style: TextStyle(
                                color: api1Values[0]['pctChange'] >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(color:Colors.grey.shade300,
                          width: 85,
                          height: 35,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              ' ${api1Values[0]['openHighLowSignal']}',
                              style: TextStyle(
                                color: api1Values[0]['openHighLowSignal'] ==
                                        'Open=High'
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    List<String>? commonSymbols = getCommonSymbols().cast<String>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Open High Low Scanner',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.question_mark_outlined,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(
                Icons.grid_on_sharp,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => tableView()),
                );
              },
            ),
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Icon(Icons.chevron_left_outlined),
                      ),
                      Container(
                          height: 50,
                          width: 260,
                          // color: Colors.redAccent,
                          child: Container(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    height: 40,
                                    color: Colors.blueAccent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Open High Low',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 40,
                                    color: Colors.grey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Open = High+PRB',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 40,
                                    color: Colors.grey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Open High Low',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      TextButton(
                        onPressed: () {},
                        child: Icon(Icons.chevron_right_outlined),
                      )
                    ],
                  ),
                  ...commonSymbols
                          ?.map((symbol) => buildSymbolCard(symbol))
                          .toList() ??
                      [],
                ],
              ),
            ),
    );
  }
}
