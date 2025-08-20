import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<LiveScore> _listOfScore = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<void> _getLiveScore() async {
    _listOfScore.clear();
    final QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('football')
        .get();
    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      LiveScore liveScore = LiveScore(
        id: doc.id,
        team1Name: doc.get('team1'),
        team2Name: doc.get('team2'),
        team1Score: doc.get('team1_score'),
        team2Score: doc.get('team2_score'),
        isRunning: doc.get('its_running'),
        winnerTeam: doc.get('winner_team'),
      );
      _listOfScore.add(liveScore);
    }
    setState(() {});
  }

  //@override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _getLiveScore();
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: StreamBuilder(
        stream: db.collection('football').snapshots(),
        builder:
            (
              context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              if (snapshot.hasData) {
                _listOfScore.clear();
                for (QueryDocumentSnapshot<Map<String, dynamic>> doc
                    in snapshot.data!.docs) {
                  LiveScore liveScore = LiveScore(
                    id: doc.id,
                    team1Name: doc.get('team1'),
                    team2Name: doc.get('team2'),
                    team1Score: doc.get('team1_score'),
                    team2Score: doc.get('team2_score'),
                    isRunning: doc.get('its_running'),
                    winnerTeam: doc.get('winner_team'),
                  );
                  _listOfScore.add(liveScore);
                }
              }
              return ListView.builder(
                itemCount: _listOfScore.length,
                itemBuilder: (context, index) {
                  LiveScore liveScore = _listOfScore[index];

                  return ListTile(
                    onLongPress: (){
                      db.collection('football').doc(liveScore.id).delete();
                    },
                    leading: CircleAvatar(
                      backgroundColor: liveScore.isRunning
                          ? Colors.green
                          : Colors.grey,
                      radius: 10,
                    ),
                    title: Text(liveScore.id),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Text(liveScore.team1Name),
                            Text('vs'),
                            Text(liveScore.team2Name),
                          ],
                        ),
                        Text('Is Winner: ${liveScore.isRunning}'),
                        Text('Winner Team: ${liveScore.winnerTeam}'),
                      ],
                    ),
                    trailing: Text(
                      '${liveScore.team1Score} : ${liveScore.team2Score}',
                      style: TextStyle(fontSize: 24),
                    ),
                  );
                },
              );
            },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          LiveScore liveScore = LiveScore(
            id: 'argvsgermany',
            team1Name: 'Argentina',
            team2Name: 'Germany',
            team1Score: 3,
            team2Score: 5,
            isRunning: true,
            winnerTeam: '',
          );
          await db
              .collection('football')
              .doc(liveScore.id)
              .update(liveScore.toMap());
        },

        //add
    //       await db
    //       .collection('football')
    //       .doc(liveScore.id)
    //       .set(liveScore.toMap());
    // },
        child: Icon(Icons.add),
      ),
    );
  }
}

class LiveScore {
  final String id;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final bool isRunning;
  final String winnerTeam;

  LiveScore({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.isRunning,
    required this.winnerTeam,
  });

  Map<String, dynamic> toMap() {
    return {
      'team1': team1Name,
      'team2': team2Name,
      'team1_score': team1Score,
      'team2_score': team2Score,
      'its_running': isRunning,
      'winner_team': winnerTeam,
    };
  }
}