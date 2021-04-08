// Adapted from https://pub.dev/packages/control_pad
// https://github.com/artrmz/flutter_control_pad
import 'dart:math' as _math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'circle_view.dart';

typedef JoystickDirectionCallback = void Function(Offset xy);

class JoystickView extends StatelessWidget {
  /// The size of the joystick.
  ///
  /// Defaults to half of the width in the portrait
  /// or half of the height in the landscape mode
  final double size;

  /// Color of the icons
  ///
  /// Defaults to [Colors.white54]
  final Color iconsColor;

  /// Color of the joystick background
  ///
  /// Defaults to [Colors.blueGrey]
  final Color backgroundColor;

  /// Color of the inner (smaller) circle background
  ///
  /// Defaults to [Colors.blueGrey]
  final Color innerCircleColor;

  /// Opacity of the joystick
  ///
  /// The opacity applies to the whole joystick including icons
  ///
  /// Defaults to [null] which means there will be no [Opacity] widget used
  final double opacity;

  /// Callback to be called when user pans the joystick
  ///
  /// Defaults to [null]
  final JoystickDirectionCallback onDirectionChanged;

  /// Indicates how often the [onDirectionChanged] should be called.
  ///
  /// Defaults to [null] which means there will be no lower limit.
  /// Setting it to ie. 1 second will cause the callback to be not called more often
  /// than once per second.
  ///
  /// The exception is the [onDirectionChanged] callback being called
  /// on the [onPanStart] and [onPanEnd] callbacks. It will be called immediately.
  final Duration interval;

  /// Shows top/right/bottom/left arrows on top of Joystick
  ///
  /// Defaults to [true]
  final bool showArrows;

  final bool snapX;
  final bool snapY;
  final double initX;
  final double initY;

  JoystickView({
    this.size,
    this.iconsColor = Colors.white54,
    this.backgroundColor = Colors.blueGrey,
    this.innerCircleColor = Colors.blueGrey,
    this.opacity,
    this.onDirectionChanged,
    this.interval,
    this.showArrows = true,
    this.snapX = true,
    this.snapY = true,
    this.initX = 0,
    this.initY = 0,
  });

  @override
  Widget build(BuildContext context) {
    double actualSize = size != null
        ? size
        : _math.min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.5;
    double innerCircleSize = actualSize / 4;
    Offset lastGesturePosition = _getInitLocalPosition(actualSize);
    Offset joystickInnerPosition = _calculatePositionOfInnerCircle(
        lastGesturePosition, innerCircleSize, actualSize, lastGesturePosition);

    DateTime _callbackTimestamp;

    return Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          Widget joystick = Stack(
            children: <Widget>[
              CircleView.joystickCircle(
                actualSize,
                backgroundColor,
              ),
              Positioned(
                child: CircleView.joystickInnerCircle(
                  innerCircleSize,
                  innerCircleColor,
                ),
                top: joystickInnerPosition.dy,
                left: joystickInnerPosition.dx,
              ),
              if (showArrows) ...createArrows(),
            ],
          );

          return GestureDetector(
            onPanStart: (details) {
              _callbackTimestamp = _processGesture(
                  actualSize, details.localPosition, _callbackTimestamp);
              setState(() => lastGesturePosition = details.localPosition);
            },
            onPanEnd: (details) {
              _callbackTimestamp = null;
              if (!snapX && !snapY) {
                return;
              }

              Offset localPosition = _getInitLocalPosition(actualSize);
              localPosition = Offset(
                  snapX ? localPosition.dx : lastGesturePosition.dx,
                  snapY ? localPosition.dy : lastGesturePosition.dy);

              _processGesture(actualSize, localPosition, _callbackTimestamp);

              joystickInnerPosition = _calculatePositionOfInnerCircle(
                  localPosition, innerCircleSize, actualSize, localPosition);
              setState(() => lastGesturePosition = localPosition);
            },
            onPanUpdate: (details) {
              _callbackTimestamp = _processGesture(
                  actualSize, details.localPosition, _callbackTimestamp);
              joystickInnerPosition = _calculatePositionOfInnerCircle(
                  lastGesturePosition,
                  innerCircleSize,
                  actualSize,
                  details.localPosition);

              setState(() => lastGesturePosition = details.localPosition);
            },
            child: (opacity != null)
                ? Opacity(opacity: opacity, child: joystick)
                : joystick,
          );
        },
      ),
    );
  }

  List<Widget> createArrows() {
    return [
      Positioned(
        child: Icon(
          Icons.arrow_upward,
          color: iconsColor,
        ),
        top: 16.0,
        left: 0.0,
        right: 0.0,
      ),
      Positioned(
        child: Icon(
          Icons.arrow_back,
          color: iconsColor,
        ),
        top: 0.0,
        bottom: 0.0,
        left: 16.0,
      ),
      Positioned(
        child: Icon(
          Icons.arrow_forward,
          color: iconsColor,
        ),
        top: 0.0,
        bottom: 0.0,
        right: 16.0,
      ),
      Positioned(
        child: Icon(
          Icons.arrow_downward,
          color: iconsColor,
        ),
        bottom: 16.0,
        left: 0.0,
        right: 0.0,
      ),
    ];
  }

  DateTime _processGesture(
      double size, Offset offset, DateTime callbackTimestamp) {
    double middle = size / 2.0;

    DateTime _callbackTimestamp = callbackTimestamp;
    if (onDirectionChanged != null &&
        _canCallOnDirectionChanged(callbackTimestamp)) {
      _callbackTimestamp = DateTime.now();
      onDirectionChanged(Offset((offset.dx.clamp(0, size) - middle) / middle,
          (offset.dy.clamp(0, size) - middle) / middle));
    }

    return _callbackTimestamp;
  }

  /// Checks if the [onDirectionChanged] can be called.
  ///
  /// Returns true if enough time has passed since last time it was called
  /// or when there is no [interval] set.
  bool _canCallOnDirectionChanged(DateTime callbackTimestamp) {
    if (interval != null && callbackTimestamp != null) {
      int intervalMilliseconds = interval.inMilliseconds;
      int timestampMilliseconds = callbackTimestamp.millisecondsSinceEpoch;
      int currentTimeMilliseconds = DateTime.now().millisecondsSinceEpoch;

      if (currentTimeMilliseconds - timestampMilliseconds <=
          intervalMilliseconds) {
        return false;
      }
    }

    return true;
  }

  Offset _calculatePositionOfInnerCircle(Offset lastGesturePosition,
      double innerCircleSize, double size, Offset offset) {
    double middle = size / 2.0;

    double angle = _math.atan2(offset.dy - middle, offset.dx - middle);
    double degrees = angle * 180 / _math.pi;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }
    bool isStartPosition =
        lastGesturePosition.dx == middle && lastGesturePosition.dy == middle;
    double lastAngleRadians =
        (isStartPosition) ? 0 : (degrees) * (_math.pi / 180.0);

    var rBig = size / 2;
    var rSmall = innerCircleSize / 2;

    var x = (lastAngleRadians == -1)
        ? rBig - rSmall
        : (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
    var y = (lastAngleRadians == -1)
        ? rBig - rSmall
        : (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);

    var xPosition = lastGesturePosition.dx - rSmall;
    var yPosition = lastGesturePosition.dy - rSmall;

    var angleRadianPlus = lastAngleRadians + _math.pi / 2;
    if (angleRadianPlus < _math.pi / 2) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < _math.pi) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < 3 * _math.pi / 2) {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    }
    return Offset(xPosition, yPosition);
  }

  Offset _getInitLocalPosition(double actualSize) {
    double middle = actualSize / 2;
    return Offset(middle + (initX * middle), middle + (initY * middle));
  }
}
