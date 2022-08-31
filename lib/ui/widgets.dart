import 'dart:math';

import 'package:flutter/material.dart';

class BoxButton extends StatelessWidget {
  const BoxButton({Key? key, required this.child, required this.onTap})
      : super(key: key);

  final Widget child;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: child,
    );
  }
}

class UiButton extends StatelessWidget {
  const UiButton(
      {Key? key,
      required this.onTap,
      required this.height,
      required this.width,
      required this.color,
      required this.child})
      : super(key: key);

  final Function() onTap;
  final double height;
  final double width;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BoxButton(
        onTap: onTap,
        child: Container(
            width: width,
            height: height,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: child)));
  }
}

class UiContainer extends StatelessWidget {
  const UiContainer(
      {Key? key, required this.backgroundColor, required this.child})
      : super(key: key);

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      body: SafeArea(child: child),
    );
  }
}

class UiScrollBar extends StatelessWidget {
  const UiScrollBar(
      {Key? key, required this.child, required this.scrollController})
      : super(key: key);

  final ScrollController? scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: scrollController,
        thickness: 4,
        thumbVisibility: true,
        radius: const Radius.circular(10),
        child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false)
                .copyWith(overscroll: false),
            child: SingleChildScrollView(
              controller: scrollController,
              child: child,
            )));
  }
}

class UiDatePicker extends StatefulWidget {
  const UiDatePicker({
    Key? key,
    required this.child,
    this.initialDate,
    required this.onSubmit,
  }) : super(key: key);

  final Widget child;
  final DateTime? initialDate;
  final Function(DateTime) onSubmit;

  @override
  State<UiDatePicker> createState() => UiDatePickerState();
}

class UiDatePickerState extends State<UiDatePicker> {
  late DateTime date;
  late Widget mask;

  @override
  void initState() {
    date = widget.initialDate == null ? DateTime.now() : widget.initialDate!;

    mask = GestureDetector(
      onTap: () {
        widget.onSubmit(date);
      },
      child: Container(color: const Color(0x88000000)),
    );

    super.initState();
  }

  List<Widget> get_days() {
    DateTime temp = DateTime(date.year, date.month, 1, 12);
    List<Widget> res = [];

    for (int j = 0; j < 6; j++) {
      List<Widget> row = [];

      for (int i = 0; i < 7; i++) {
        int index = (i + 1) % 8;

        if (temp.weekday == index && temp.month == date.month) {
          int year = temp.year.toInt();
          int month = temp.month.toInt();
          int day =  temp.day.toInt();

          row.add(SizedBox(
            width: 20,
            height: 20,
            child: Center(child: BoxButton(
              onTap: () => setState(() {
                date = DateTime(year, month, day, 12);
              }),
              child: Text(temp.day.toString())))));
          temp = temp.add(const Duration(days: 1));
        } else {
          row.add(SizedBox(
            width: 20,
            height: 20,
            child: Container(color: Colors.red,)));
        }
      }
      res.add(Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: row,)));
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        mask,
        LayoutBuilder(
          builder: (context, constraints) {
            List<Widget> calendar = get_days();

            return Center(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                width: min(500, constraints.maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  SizedBox(
                    height: 30,
                    child: Row()),
                   SizedBox(
                    height: 40,
                    child: Center(child: Text(date.toString(), style: const TextStyle(fontFamily: "Montserrat", fontSize: 18),))),
                  SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(date.month.toString()),
                          Text(date.month.toString())
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(children: 
                      calendar
                    ,),
                  ) 
                ]),
              ),
            );
          },
        )
      ],
    );
  }
}
