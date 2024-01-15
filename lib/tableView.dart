import 'dart:convert';
import 'package:demo/gridView.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class tableView extends StatefulWidget {
  const tableView({Key? key}) : super(key: key);

  @override
  State<tableView> createState() => _tableViewState();
}

class _tableViewState extends State<tableView> {
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    tracker();
  }

  Future<void> tracker() async {
    String url = 'https://intradayscreener.com/api/openhighlow/cash';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icons.window_outlined,
                color: Colors.white,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
            ),
          )
        ],
      ),
      body: Column(
        children: [

          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Icon(Icons
                    .chevron_left_outlined),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.blue,
              height: 60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SYMBOL',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'LTP',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'MOMENTUM',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: data.isEmpty
                  ? CircularProgressIndicator()
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        List<dynamic> intradayScans =
                            data[index]['allScans']['intradayScans'];

                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Container(
                            height: 130,
                            padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Stock Symbol and Logo
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            child: ClipOval(
                                              child: SvgPicture.network(
                                                'https://intradayscreener.com/app/assets/images/stock_logos/${data[index]['symbol']}.svg',
                                                width: 38,
                                                height: 38,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            data[index]['symbol'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // LTP
                                      SizedBox(width: 10),
                                      Column(
                                        children: [
                                          Text(data[index]['ltp'].toString()),
                                          SizedBox(height: 5),

                                          // Percentage Change
                                          Row(
                                            children: [
                                              Icon(
                                                data[index]['change'] >= 0
                                                    ? Icons.arrow_drop_up
                                                    : Icons.arrow_drop_down,
                                                color:
                                                    data[index]['change'] >= 0
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                              Text(
                                                data[index]['change']
                                                    .toString(),
                                                style: TextStyle(
                                                  color:
                                                      data[index]['change'] >= 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                              ),
                                              Text(
                                                '(${data[index]['pctChange'].toString()}%)',
                                                style: TextStyle(
                                                    color: data[index]
                                                                ['pctChange'] >=
                                                            0
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Momentum
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Row(
                                        children: [
                                          Text(data[index]['stockMomentumRank']
                                              .toString()),
                                          SizedBox(width: 10),
                                          Text(data[index]
                                                  ['stockOutperformanceRank']
                                              .toString()),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Intraday Scans
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: 100,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: intradayScans
                                            .map(
                                              (scan) => Card(
                                                color: Colors.grey,
                                                child: Text(
                                                    scan['scanShortcode']
                                                        .toString()),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
