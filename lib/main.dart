import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

Future<Forecast> fetchForecast() async {
  final response = await http.get(
      'http://www.7timer.info/bin/civillight.php?lon=-119.4&lat=37.1&ac=0&unit=metric&output=json&tzshift=0');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Forecast.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load Forecast');
  }
}

class Forecast {
  final String product;
  final String init;
  final List<dynamic> dataseries;

  Forecast({this.product, this.init, this.dataseries});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      product: json['product'],
      init: json['init'],
      dataseries: json['dataseries'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Clima de la semana'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Forecast> futureForecast;

  @override
  void initState() {
    super.initState();
    futureForecast = fetchForecast();
  }

  Widget windColumn(int windLvl) {
    String wind = "";
    switch (windLvl) {
      case 1:
        wind = "calmado";
        break;
      case 2:
        wind = "ligero";
        break;
      case 3:
        wind = "moderado";
        break;
      case 4:
        wind = "fresco";
        break;
      case 5:
        wind = "fuerte";
        break;
      case 6:
        wind = "temporal";
        break;
      case 7:
        wind = "tormenta";
        break;
      case 8:
        wind = "huracán";
        break;
      default:
    }

    return Column(
      children: [
        Image.asset(
          "icons/wind.png",
          width: 40,
          height: 40,
        ),
        Text(wind),
      ],
    );
  }

  Widget dayForecast(Forecast forecast, int day) {
    String fecha = forecast.dataseries[day]["date"].toString();
    DateTime dtFecha = DateTime.parse(fecha);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(dtFecha.day.toString() +
                  '/' +
                  dtFecha.month.toString() +
                  '/' +
                  dtFecha.year.toString()),
              Column(
                children: [
                  Text("Max: " +
                      forecast.dataseries[day]["temp2m"]["max"].toString()),
                  Text("Min: " +
                      forecast.dataseries[day]["temp2m"]["min"].toString())
                ],
              ),
              Image.asset(
                "icons/" +
                    forecast.dataseries[day]["weather"].toString() +
                    ".png",
                height: 60,
              ),
              windColumn(forecast.dataseries[day]["wind10m_max"])
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: FutureBuilder<Forecast>(
            future: futureForecast,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    dayForecast(snapshot.data, 0),
                    dayForecast(snapshot.data, 1),
                    dayForecast(snapshot.data, 2),
                    dayForecast(snapshot.data, 3),
                    dayForecast(snapshot.data, 4),
                    dayForecast(snapshot.data, 5),
                    dayForecast(snapshot.data, 6),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
        ));
  }
}
