import 'dart:async';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CountdownClock
//
// A self-contained widget that ticks every second and displays the time
// remaining until [releaseDate].
//
// Design: white background, black border, red digit blocks, grey labels.
// No dark backgrounds, no gradients — matches the JustDropd light aesthetic.
//
// The clock_style field is accepted but not yet used for styling — that will
// be wired up when users can choose their own clock colors.
//
// Usage:
//   CountdownClock(releaseDate: someDateTime)
//   CountdownClock(releaseDate: someDateTime, clockStyle: "digital_default")
// ─────────────────────────────────────────────────────────────────────────────
class CountdownClock extends StatefulWidget {
  final DateTime releaseDate;
  final String clockStyle;

  const CountdownClock({
    super.key,
    required this.releaseDate,
    this.clockStyle = "digital_default",
  });

  @override
  State<CountdownClock> createState() => _CountdownClockState();
}

class _CountdownClockState extends State<CountdownClock> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _remaining = _calcRemaining());
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: isReleased ? _buildReleasedState() : _buildTimerState(),
    );
  }

  // ── released ───────────────────────────────────────────────────────────────
  Widget _buildReleasedState() {
    return const Text(
      "OUT NOW! 🎶",
      style: TextStyle(
        color: Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  // ── live timer ─────────────────────────────────────────────────────────────
  Widget _buildTimerState() {
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _DigitBlock(value: days,    label: "DAYS"),
        const _Colon(),
        _DigitBlock(value: hours,   label: "HRS"),
        const _Colon(),
        _DigitBlock(value: minutes, label: "MIN"),
        const _Colon(),
        _DigitBlock(value: seconds, label: "SEC"),
      ],
    );
  }
}

// ── single digit block ────────────────────────────────────────────────────────
class _DigitBlock extends StatelessWidget {
  final int value;
  final String label;

  const _DigitBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFF3B30), width: 1.5),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFF3B30),
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── colon separator ───────────────────────────────────────────────────────────
class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 18, left: 3, right: 3),
      child: Text(
        ":",
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}