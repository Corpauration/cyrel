import 'dart:math';

import 'package:cyrel/api/api.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/room_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({Key? key, required this.room}) : super(key: key);

  final RoomEntity room;

  @override
  Widget build(BuildContext context) {
    List<CourseEntity> nextCourses = room.courses
        .where((course) =>
            course.start.isAfter(DateTime.now()) &&
            course.start.isBefore(DateTime.now().apply(hour: 23)))
        .toList();
    nextCourses.sort((a, b) => a.start.compareTo(b.start));
    return Container(
      constraints: const BoxConstraints(maxWidth: 330),
      decoration: BoxDecoration(
          color: ThemesHandler.instance.theme.card,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                room.name,
                style: Styles().f_18,
              ),
              Visibility(
                  visible: room.computers,
                  child: SvgPicture.asset(
                    "assets/svg/computer.svg",
                    height: 20,
                  ))
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              nextCourses.isNotEmpty
                  ? "Prochain cours à ${nextCourses.first.start.toHourString()}"
                  : "Libre pour toute la journée",
              style: Styles().f_13,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${room.capacity} places",
              style: Styles().f_13,
            ),
          ),
        ],
      ),
    );
  }
}

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  late Future<List<RoomEntity>> _rooms;
  final sc = ScrollController();

  List<Widget> roomListBuilder(List<RoomEntity> list) {
    return list.map((e) => RoomCard(room: e)).toList();
  }

  Future<List<RoomEntity>> fetchFreeRooms() async {
    return await Api.instance.rooms.getFree();
  }

  @override
  void initState() {
    _rooms = fetchFreeRooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const screenRatio = 7 / 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        double horizontalMargin =
            constraints.maxHeight > (screenRatio * constraints.maxWidth)
                ? max(5, constraints.maxWidth / 48)
                : max(20, constraints.maxWidth / 12);

        return Container(
            color: ThemesHandler.instance.theme.background,
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10,),
                  Text(
                    "Salles libres",
                    style: Styles().f_24,
                  ),
                  Expanded(
                    child: FutureBuilder(
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              child: UiScrollBar(
                                scrollController: sc,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                      children: roomListBuilder(
                                          snapshot.data as List<RoomEntity>)),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                color: const Color.fromARGB(255, 38, 96, 170),
                                backgroundColor:
                                    ThemesHandler.instance.theme.card,
                                strokeWidth: 2,
                              ),
                            );
                          }
                        },
                        future: _rooms),
                  ),
                ]));
      },
    );
  }
}
