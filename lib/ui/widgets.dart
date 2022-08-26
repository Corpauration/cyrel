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
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: scrollController,
              child: child,
            )));
  }
}
