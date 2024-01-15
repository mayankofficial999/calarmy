import 'dart:collection';

import 'package:calarmy/types/calarmy_event.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarController {
  CalendarController();
  
  bool isValidEmail(String? email) {
    // Regular expression for a basic email validation
    final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if(email!=null) {
      return emailRegex.hasMatch(email);
    } else {
      return false;
    }
  }

  Future<List<CalarmyEvent>> getTodaysEvents() async {
    List<CalarmyEvent> events = [];
    var cal = DeviceCalendarPlugin();
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year,now.month,now.day);
    DateTime eod = DateTime(now.year,now.month,now.day).add(const Duration(hours: 23,minutes: 59));
    Result<bool> permGranted = await cal.hasPermissions();
    if(!permGranted.data!) {
      await cal.requestPermissions();
    }
    var cals = await cal.retrieveCalendars();
    for(int i=0;i<cals.data!.length; i++) {
      if(isValidEmail(cals.data![i].name)) {
        // Getting all events linked to our emails
        Result<UnmodifiableListView<Event>> rst = await cal.retrieveEvents(
          cals.data![i].id,
          RetrieveEventsParams(
            startDate: today,
            endDate: eod
          )
        );
        // Extracting all events for today
        for(int j=0;j<rst.data!.length; j++) {
          CalarmyEvent ev = CalarmyEvent(
            rst.data![j].eventId,
            rst.data![j].title, 
            rst.data![j].start, 
            rst.data![j].end, 
            rst.data![j].reminders!
          );
          events.add(ev);
        }
      }
    }
    return events;
  }
}