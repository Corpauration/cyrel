import 'dart:math';

import 'package:cyrel/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  Widget dayBox(Widget? child, Color? color) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: color,
        ),
        width: 35,
        height: 35,
        child: child);
  }

  List<Widget> getDays() {
    DateTime temp = DateTime(date.year, date.month, 1, 12);
    List<Widget> res = [];

    for (int j = 0; j < 6; j++) {
      List<Widget> row = [];

      if (j == 5 && temp.weekday != 1) {
        break;
      }

      for (int i = 0; i < 7; i++) {
        if (temp.weekday == i + 1 && temp.month == date.month) {
          int year = temp.year.toInt();
          int month = temp.month.toInt();
          int day = temp.day.toInt();
          bool isDate = date.year == temp.year &&
              date.month == temp.month &&
              date.day == temp.day;

          row.add(dayBox(
              BoxButton(
                onTap: () => setState(() {
                  date = DateTime(year, month, day, 12);
                }),
                child: Center(
                    child: Text(
                  temp.day.toString(),
                  style: TextStyle(
                      fontFamily: "Montserrat",
                      color: isDate ? Colors.white : Colors.black),
                )),
              ),
              isDate
                  ? const Color.fromARGB(255, 38, 96, 170)
                  : Colors.grey[100]));
          temp = temp.add(const Duration(days: 1));
        } else {
          row.add(dayBox(null, Colors.transparent));
        }
      }
      res.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row,
          )));
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
            return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: EdgeInsets.only(top: constraints.maxHeight/5),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  width: min(400, constraints.maxWidth),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(height: 30, child: Row()),
                    SizedBox(
                        height: 40,
                        child: Center(
                            child: Text(
                          "${WeekDay.name(date.weekday)} ${date.day.toString().padLeft(2, "0")}",
                          style: const TextStyle(
                              fontFamily: "Montserrat", fontSize: 18),
                        ))),
                    SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Month.name(date.month), style: const TextStyle(fontFamily: "Montserrat", fontSize: 15),),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: BoxButton(
                                        onTap: () =>
                                          setState(() {
                                            date = DateTime(date.year,
                                                (date.month + 11 % 13));
                                          })
                                        ,
                                        child: SvgPicture.asset(
                                            "assets/svg/arrow_left.svg",
                                            height: 20)),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: BoxButton(
                                        onTap: () => setState(() {
                                            date = DateTime(date.year,
                                                (date.month%12+1));
                                        }),
                                        child: SvgPicture.asset(
                                            "assets/svg/arrow_right.svg",
                                            height: 20)),
                                  )
                                ],
                              )
                            ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: getDays(),
                      ),
                    )
                  ]),
                ),
              ),
            ]);
          },
        )
      ],
    );
  }
}
