import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HorizontalNumberPicker extends StatelessWidget {
  HorizontalNumberPicker({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: child,
        ),
        Image(
          height: 20.0,
          width: 35.0,
          image: AssetImage('assets/ArrowUp.png'),
        ),
      ],
    );
  }
}

// TODO: Implement StepSize
// TODO: Implement DisplayItemAmount
class HorizontalSlider extends StatelessWidget {
  HorizontalSlider({
    Key key,
    this.minValue = 1,
    this.maxValue = 999,
    @required this.width,
    @required this.value,
    @required this.onChanged,
  }) : scrollController = new ScrollController(
    initialScrollOffset: (value - minValue) * width / 3,
  ),
        super(key: key);

  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;
  final double width;
  final ScrollController scrollController;
  double get itemExtent => width / 3;

  int _indexToValue(int index) => (minValue + (index - 1));

  @override
  Widget build(BuildContext context) {
    int itemCount = (maxValue - minValue) + 3;

    return NotificationListener(
      onNotification: _onNotification,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemExtent: itemExtent,
        itemCount: itemCount,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final int itemValue = _indexToValue(index);
          bool isExtra = index == 0 || index == itemCount - 1;

          return isExtra ? new Container() : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _animateTo(itemValue, durationMilliseconds: 50),
            child: FittedBox(
              child: new Text(
                itemValue.toString(),
                style: _getTextStyle(itemValue),
              ),
              fit: BoxFit.scaleDown,
            ),
          );
        },
      ),
    );
  }

  TextStyle _getDefaultTextStyle() {
    return new TextStyle(
      fontSize: 20.0,
      color: Colors.white70,
    );
  }

  TextStyle _getHighlightTextStyle() {
    return new TextStyle(
      fontSize: 30.0,
      color: Colors.white,
    );
  }

  TextStyle _getTextStyle(int itemValue) {
    return itemValue == value ? _getHighlightTextStyle() : _getDefaultTextStyle();
  }

  bool _userStoppedScrolling(Notification notification) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity; // TODO: Fix error "Use of protected member"
  }

  void _animateTo(int valueToSelect, {int durationMilliseconds = 200}) {
    double targetExtent = (valueToSelect - minValue) * itemExtent;

    scrollController.animateTo(
      targetExtent,
      duration: new Duration(milliseconds: durationMilliseconds),
      curve: Curves.decelerate,
    );
  }

  int _offsetToMiddleIndex(double offset) => (offset + width / 2) ~/ itemExtent;

  int _offsetToMiddleValue(double offset) {
    int indexOfMiddleElement = _offsetToMiddleIndex(offset);
    int middleValue = _indexToValue(indexOfMiddleElement);
    middleValue = math.max(minValue, math.min(maxValue, middleValue));
    return middleValue;
  }

  bool _onNotification(Notification notification) {
    if (notification is ScrollNotification) {
      int middleValue = _offsetToMiddleValue(notification.metrics.pixels);

      if (_userStoppedScrolling(notification)) {
        _animateTo(middleValue);
      }

      if (middleValue != value) {
        onChanged(middleValue); // Update selection
      }
    }
    return true;
  }
}
