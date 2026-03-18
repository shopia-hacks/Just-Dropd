import 'dart:async';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CountdownClock
// A self-contained widget that ticks every second and displays the time
// remaining until [releaseDate] in a retro LED digital style.
//
// Usage:
//   CountdownClock(releaseDate: someDateTime)
//
// When the countdown hits zero it shows "Out Now!" instead of the timer.
// ─────────────────────────────────────────────────────────────────────────────
class CountdownClock extends StatefulWidget {
  final DateTime releaseDate;

  const CountdownClock({super.key, required this.releaseDate});

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

    // tick every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = _calcRemaining();
      });
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

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isReleased = _remaining == Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3B30).withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: isReleased ? _buildReleasedState() : _buildTimerState(),
    );
  }

  // ── released state ─────────────────────────────────────────────────────────
  Widget _buildReleasedState() {
    return const Text(
      "OUT NOW!",
      style: TextStyle(
        color: Color(0xFFFF3B30),
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
        fontFamily: 'Courier',
      ),
    );
  }

  // ── live timer ─────────────────────────────────────────────────────────────
  Widget _buildTimerState() {
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── digit row ───────────────────────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _DigitBlock(value: days,    label: "DAYS"),
            _Colon(),
            _DigitBlock(value: hours,   label: "HRS"),
            _Colon(),
            _DigitBlock(value: minutes, label: "MIN"),
            _Colon(),
            _DigitBlock(value: seconds, label: "SEC"),
          ],
        ),
      ],
    );
  }
}

// ── single digit block (e.g. "07\nDAYS") ─────────────────────────────────────
class _DigitBlock extends StatelessWidget {
  final int value;
  final String label;

  const _DigitBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // the number itself
        Container(
          width: 54,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFF3B30), // red LED colour
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier', // monospace keeps digits from jumping
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // the label below
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── colon separator ───────────────────────────────────────────────────────────
class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 18, left: 4, right: 4),
      child: Text(
        ":",
        style: TextStyle(
          color: Color(0xFFFF3B30),
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
