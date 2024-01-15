import 'package:calarmy/controller/backgound_controller.dart';
import 'package:calarmy/controller/calendar_controller.dart';
import 'package:calarmy/types/calarmy_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
  BackgroundController().init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calarmy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var calendarController = CalendarController();
  Future<List<CalarmyEvent>> getEventsList() {
    return calendarController.getTodaysEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(10, 20, 20, 0.8),
        title: Text(widget.title,style: const TextStyle(color: Colors.white),),
      ),
      backgroundColor: const Color.fromRGBO(10, 20, 20, 0.8),
      body: 
        FutureBuilder(
          future: getEventsList(), 
          builder: (context, snapshot) {
          ConnectionState connection = snapshot.connectionState;
          return Center(
            child: connection!= ConnectionState.done ? 
            const CircularProgressIndicator() :
            ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
              int reverseIndex = snapshot.data!.length - 1 - index;
              CalarmyEvent eventData = snapshot.data![reverseIndex];
              String startTime = DateFormat('HH:mm:ss').format(eventData.startTime!);
              String nearestReminder = DateFormat('HH:mm:ss').format(eventData.remindTimings[0]);
              String endTime = DateFormat('HH:mm:ss').format(eventData.endTime!);
              return ListTile(
                key: Key('$index'),
                title: Text(snapshot.data![reverseIndex].title!, style: const TextStyle(color: Colors.white)),
                subtitle: Text('Nearest Reminder: $nearestReminder', style: const TextStyle(color: Colors.white)),
                leading: Text(startTime, style: const TextStyle(color: Colors.white)),
                trailing: Text(endTime, style: const TextStyle(color: Colors.white)),
                tileColor: index % 2 == 0 ? Colors.black38 : Colors.black26,
              );
            })); 
          })
        );
    }
}
