import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  bool datePicker = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.amber,
        child: LayoutBuilder(
          builder: (context, constraints) {
            Widget view = Center(
                child: IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: (() {
                      setState(() {
                        datePicker = true;
                      });
                    })));

            if (datePicker) {
              return UiDatePicker(
                  child: view,
                  onSubmit: (DateTime _) {
                    setState(() {
                      datePicker = false;
                    });
                  });
            } else {
              return view;
            }
          },
        ));
  }
}
