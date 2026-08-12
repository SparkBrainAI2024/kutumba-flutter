import 'dart:math';
import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );

    final position =
    Duration(milliseconds: widget.position.inMilliseconds.round());

    final positionText = [position.inMinutes, position.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');

    final duration =
    Duration(milliseconds: widget.duration.inMilliseconds.round());

    final durationText = [duration.inMinutes, duration.inSeconds]
        .map((seg) => seg.remainder(60).toString().padLeft(2, '0'))
        .join(':');

    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }

    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: (value) {
            if (!_dragging) {
              _dragging = true;
            }

            setState(() {
              _dragValue = value;
            });

            widget.onChanged?.call(
              Duration(milliseconds: value.round()),
            );
          },
          onChangeEnd: (value) {
            widget.onChangeEnd?.call(
              Duration(milliseconds: value.round()),
            );

            _dragging = false;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: -2.0,
          child: Text(
            '$positionText / $durationText',
            style: const TextStyle(
              color: Color.fromARGB(255, 175, 175, 175),
            ),
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}