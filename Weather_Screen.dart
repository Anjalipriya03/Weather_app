import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:weather_app/addition_info.dart';
import 'package:weather_app/hourly_forecast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

    Future<Map<String, dynamic>> getcurrentweather() async {
    try {
      String cityname = 'London';

      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityname&APPID=$opemweatherkey'),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }

  }
  @override
  void initState() {
    super.initState();
    weather = getcurrentweather();
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Weather App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: (){
                  setState(() {
                    weather=getcurrentweather();
                  });
                }
                , icon: const Icon(Icons.refresh),
              )
            ],
          ),
          body: FutureBuilder(
              future: weather,
              builder: (context, snapshot) {
                print(snapshot);

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: const CircularProgressIndicator.adaptive());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(snapshot.error.toString()));
                }
                final data = snapshot.data;
                final currentweatherdata = data!['list'][0];
                final currenttemp = currentweatherdata['main']['temp'];
                final currentsky = currentweatherdata['weather'] [0]['main'];
                final currentPressure = currentweatherdata['main']['pressure'];
                final currentWindSpeed = currentweatherdata['wind']['speed'];
                final currentHumidity = currentweatherdata['main']['humidity'];


                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      //main card
                      Container(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currenttemp K ',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      currentsky == 'Cloud' ||
                                          currentsky == 'Rain'
                                          ? Icons.cloud : Icons.sunny,
                                      size: 64,
                                    ),
                                    Text(
                                      currentsky,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                     const SizedBox(
                        height: 30,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                         Text(
                          'Weather Forecast',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                     const  SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                           final hourlyforecast=data['list'][index+1];
                           final hourlysky=data['list'][index+1]['weather'] [0]['main'];
                           final hourlytemp=hourlyforecast['main']['temp'].toString();
                           final time=DateTime.parse(hourlyforecast['dt_txt']);
                           return Hourlyforecastitem(
                             time:DateFormat.j().format(time),
                             temperature:hourlytemp,
                             icon:hourlysky=='Clouds' || hourlysky =='Rain' ? Icons.cloud : Icons.sunny,
                           );
                        },
                        ),
                      ),

                    const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Additional Information',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Additionalinfoitem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: currentHumidity.toString(),
                          ),
                          Additionalinfoitem(
                            icon: Icons.air,
                            label: 'Wind Speed',
                            value: currentWindSpeed.toString(),
                          ),
                          Additionalinfoitem(
                            icon: Icons.beach_access,
                            label: 'Pressure',
                            value: currentPressure.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }));
    }
  }


