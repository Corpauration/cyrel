import 'package:cyrel/ui/homework.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.amber, child: const HomeworkCreatingPage());
  }
}
