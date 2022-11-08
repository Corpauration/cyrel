import 'dart:math';

import 'package:cyrel/api/room_entity.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/ui/widgets.dart';
import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({Key? key, required this.room}) : super(key: key);

  final RoomEntity room;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: ThemesHandler.instance.theme.card,
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [Text(room.name, style: Styles().f_18,)],
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

  @override
  void initState() {
    _rooms = Future(() {
      return List.generate(
          5,
          (index) => RoomEntity(
              "a", "$index C'est ma salle", 10, false, List.empty()));
    });
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
