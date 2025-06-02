import 'dart:async';

import 'package:flutter/material.dart';

class RateLimitOverlay extends StatefulWidget {
  final Duration duration;
  final String operationName;
  final VoidCallback? onTimerComplete;

  const RateLimitOverlay({
    super.key,
    required this.duration,
    required this.operationName,
    this.onTimerComplete,
  });

  @override
  State<RateLimitOverlay> createState() => _RateLimitOverlayState();
}

class _RateLimitOverlayState extends State<RateLimitOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onTimerComplete?.call();
        }
      });
    _controller.reverse(from: 1.0);
    
    // Update UI every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingTime = widget.duration - Duration(seconds: timer.tick);
        if (_remainingTime.inSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Stack(
      children: [
        // Semi-transparent background blocker
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withOpacity(0.5),
        ),
        // Centered content
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(16),
            elevation: 8,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 48,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Too Many Requests',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait before attempting to ${widget.operationName} again',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 6,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _remainingTime.inSeconds > 0
                        ? 'Time remaining: ${_remainingTime.inSeconds}s'
                        : 'Ready to try again!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}