import 'package:device_calendar/device_calendar.dart';

class CalarmyEvent {
  late String? eventId;
  late String? title;
  late DateTime? startTime;
  late DateTime? endTime;
  late List<DateTime> remindTimings = [];

  CalarmyEvent(this.eventId, this.title, this.startTime, this.endTime, List<Reminder> reminders) {
    for(int i=0;i<reminders.length;i++) {
      remindTimings.add(startTime!.subtract(Duration(minutes: reminders[i].minutes ?? 0)));
    }
    remindTimings.sort();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'remindTimings': remindTimings.toString()
    };
  }
}