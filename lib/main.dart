import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gyro_accel_3d_movement/match.dart';
import 'package:nakama/nakama.dart';

void main() async {
  NakamaBaseClient? client;
  try {
    client = getNakamaClient(
      host: '192.168.1.4',
      ssl: false,
      serverKey: 'defaultkey',
    );
  } on Exception catch (e) {
    debugPrint("ERROR AT CONNECTING $e");
  }
  try {
    var user = Random().nextInt(10).toString();
    await client!
        .authenticateEmail(
      email: "$user@gmail.com",
      password: "password",
    )
        .then((value) async {
      NakamaWebsocketClient.init(
        host: '192.168.1.4',
        ssl: false,
        token: value.token,
      );
      runApp(const MyApp());
    });
  } on Exception catch (e) {  
    debugPrint("ERROR AT CREATING ACCOUNT $e");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Loading(),
    );
  }
}

class Loading extends StatefulWidget {
  const Loading({
    Key? key,
  }) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    Future.delayed(const Duration(milliseconds: 500)).then((value) async {
      await NakamaWebsocketClient.instance.createMatch().then((value) {
        NakamaWebsocketClient.instance
            .joinMatch(value.matchId)
            .then((value) async => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchPage(
                      match: value,
                    ),
                  ),
                ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: CircularProgressIndicator(),
    ));
  }
}
