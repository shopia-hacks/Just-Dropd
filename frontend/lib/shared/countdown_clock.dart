import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_dropd/theme/theme.dart';

class CountdownClock extends StatefulWidget {
  final DateTime releaseDate;
  final String clockStyle;
  final bool compact;
  final bool isMain;

  const CountdownClock({
    super.key,
    required this.releaseDate,
    this.clockStyle = 'blue',
    this.compact = false,
    this.isMain = false,
  });

  @override
  State<CountdownClock> createState() => _CountdownClockState();
}

class _CountdownClockState extends State<CountdownClock> {
  late Timer _timer;
  late Duration _remaining;

  String get _effectiveStyle =>
      AppClockTheme.effectiveStyle(widget.clockStyle, isMain: widget.isMain);

  Color get _shellColor     => AppClockTheme.shellColor(_effectiveStyle);
  Color get _highlightColor => AppClockTheme.highlightColor(_effectiveStyle);

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _calcRemaining());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _calcRemaining() {
    final diff = widget.releaseDate.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  Widget build(BuildContext context) {
    final isReleased = _remaining == Duration.zero;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 12 : AppLayout.cardPadding,
        vertical:   widget.compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: _shellColor,
        borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      ),
      child: isReleased
          ? _buildReleasedState(context)
          : _buildTimerState(context),
    );
  }

  Widget _buildReleasedState(BuildContext context) {
    return Text(
      'OUT NOW! 🎶',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: widget.compact ? 18 : 24,
            letterSpacing: 2,
            color: _highlightColor,
          ),
    );
  }

  Widget _buildTimerState(BuildContext context) {
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _DigitBlock(value: days,    label: 'DAYS', compact: widget.compact, shellColor: _shellColor, highlightColor: _highlightColor),
        _Colon(compact: widget.compact, color: _highlightColor),
        _DigitBlock(value: hours,   label: 'HRS',  compact: widget.compact, shellColor: _shellColor, highlightColor: _highlightColor),
        _Colon(compact: widget.compact, color: _highlightColor),
        _DigitBlock(value: minutes, label: 'MIN',  compact: widget.compact, shellColor: _shellColor, highlightColor: _highlightColor),
        _Colon(compact: widget.compact, color: _highlightColor),
        _DigitBlock(value: seconds, label: 'SEC',  compact: widget.compact, shellColor: _shellColor, highlightColor: _highlightColor),
      ],
    );
  }
}

class _DigitBlock extends StatelessWidget {
  final int value;
  final String label;
  final bool compact;
  final Color shellColor;     // digit text color = shell color
  final Color highlightColor; // label color

  const _DigitBlock({
    required this.value,
    required this.label,
    required this.compact,
    required this.shellColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final boxWidth  = compact ? AppLayout.digitBoxWidthCompact : AppLayout.digitBoxWidthFull;
    final digitFont = compact ? AppLayout.digitFontCompact     : AppLayout.digitFontFull;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: boxWidth,
          padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white,                    // always white behind digits
            borderRadius: BorderRadius.circular(AppLayout.radiusSm),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: shellColor,                    // digits = shell color
              fontSize: digitFont,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: compact ? 4 : 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppLayout.labelFontSize,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            color: highlightColor,                  // label = highlight color
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  final bool compact;
  final Color color;

  const _Colon({required this.compact, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: compact ? 20 : 24,
        left:   compact ? 4  : 6,
        right:  compact ? 4  : 6,
      ),
      child: Text(
        ':',
        style: TextStyle(
          color: color,
          fontSize: compact ? 26 : 34,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}