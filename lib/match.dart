import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';
import 'package:nakama/rtapi.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MatchPage extends StatefulWidget {
  final Match match;
  const MatchPage({
    Key? key,
    required this.match,
  }) : super(key: key);

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final StreamSubscription onMatchDataSubscription;
  final matchDataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NakamaWebsocketClient.instance..onStreamData.listen((event) { 
      debugPrint(event.data);
    });
    onMatchDataSubscription = NakamaWebsocketClient.instance.onMatchData.listen((event) {
      print(
          'received match data: ${event.data} from ${event.presence.username}');
      // Sent the match content field to received data.
      matchDataController.text = String.fromCharCodes(event.data);
      setState(() {});
    });
    onMatchDataSubscription.onData((data) { 
      debugPrint(data);
    });
  }

  void sendMatchData(String data) async {
    // Send dummy match data via Websocket
    await NakamaWebsocketClient.instance.sendMatchData(
      matchId: widget.match.matchId,
      opCode: Int64(0),
      data: data.codeUnits,
    );
    // print('Match Data changed: $data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(widget.match.matchId + "ww");
          await NakamaWebsocketClient.instance.sendMatchData(
            matchId: widget.match.matchId,
            opCode: Int64(0),
            data: [2],
          ).then((value) => print(value));
          userAccelerometerEvents.listen((UserAccelerometerEvent event) async {
            // debugPrint("${event.x} ${event.y} ${event.z}");
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: StreamBuilder(
          stream: NakamaWebsocketClient.instance.onMatchData,
          builder: (_, AsyncSnapshot<MatchData> v) {
            return Column(
              children: [
                TextField(
                  controller: matchDataController,
                  maxLines: null,
                  onChanged: sendMatchData,
                ),
                ListTile(
                  title: Text(
                    matchDataController.text.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    debugPrint(v.data?.writeToJson());
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
