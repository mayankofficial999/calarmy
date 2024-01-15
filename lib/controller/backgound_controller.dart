import 'package:calarmy/controller/calendar_controller.dart';
import 'package:calarmy/controller/notification_controller.dart';
import 'package:calarmy/types/calarmy_event.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundController {
  BackgroundController();

  void init() {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: true
    );
    Workmanager().cancelAll();
    NotificationsAPI().initialize();
    scheduleAlarmTasks();
  }

  void registerNextTask(CalarmyEvent ev) {
    if(ev.remindTimings.isNotEmpty) {
      for(int i=0;i<ev.remindTimings.length;i++) {
        print(ev.remindTimings[i]);
        if(ev.remindTimings[i].compareTo(DateTime.now()) > 0 && ev.remindTimings.isNotEmpty) {
          Duration timeLeft = ev.remindTimings[i].difference(DateTime.now());
          print('Time left: $timeLeft');
          Workmanager().registerOneOffTask(
            '${ev.eventId!}_reminder$i', 
            ev.title!,
            initialDelay: timeLeft
          ).then((value) {
            print('Registered ${ev.title!}, reminder $i');
          });
        }
      }
    }
  }

  void scheduleAlarmTasks() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year,now.month,now.day);
    DateTime tomm = today.add(const Duration(days: 1));
    var calendarController = CalendarController();
    calendarController.getTodaysEvents().then((events) {
      for(var event in events) {
        // print(event.toJson().toString());
        registerNextTask(event);
      }
      Workmanager().registerOneOffTask(
        'refreshEvents', 
        'refreshEvents',
        initialDelay: tomm.difference(now)
      ).then((value) {
        print('Registered refreshEvents ${tomm.difference(now)}');
      });
    });
  }
}

@pragma('vm:entry-point') 
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    BackgroundController bgCon = BackgroundController();
    print("Native called background task: $task");
    if(task == 'refreshEvents') { 
      bgCon.scheduleAlarmTasks();
      return Future.value(true);
    }
    try {
      await NotificationsAPI().
      sendNotification(
        'Event Reminder:',
        body: task
      );
    } catch (error) {
      print('ERROR in worker: $error');
      NotificationsAPI().sendNotification('Error accessing calendar events',
          body: 'Calendar alarm is not working. Please sign in again.');
    } finally {
      // Even if e.g. auth fails we will retry
      // bgCon.scheduleAlarmTasks();
    }

    return Future.value(true);
  });
}