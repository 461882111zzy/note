import 'dart:async';
import 'package:flutter/material.dart';

class IndexView extends StatefulWidget {
  const IndexView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _IndexViewState createState() => _IndexViewState();
}

class _IndexViewState extends State<IndexView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late AnimationController _controller;
  late Timer _timer;
  bool _isRunning = false;
  bool _isEnding = false;
  static int remainig = 1800;
  int _secondsRemaining = remainig;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: remainig),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    _isEnding = false;
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _controller.forward(from: _controller.value);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _secondsRemaining--;
        });
        if (_secondsRemaining == 0) {
          _timer.cancel();
          _controller.stop();
          _isRunning = false;
          _isEnding = true;
        }
      });
    } else {
      _controller.stop();
      _timer.cancel();
    }
  }

  void _stopTimer() {
    _isRunning = false;
    _isEnding = false;
    _timer.cancel();
    _secondsRemaining = remainig;
    _controller.stop();
    _controller.reset();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 10,
          child: Text('番茄时钟',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
        ),
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: CircularProgressIndicator(
              value: _controller.value,
              strokeWidth: 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(_secondsRemaining),
                style: const TextStyle(fontSize: 48),
              ),
              if (!_isEnding)
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_isRunning ? '暂停' : '开始'),
                ),
            ],
          ),
        ),
        if (_isRunning || _isEnding)
          Padding(
            padding: const EdgeInsets.only(top: 148.0),
            child: Center(
              child: ElevatedButton(
                onPressed: _stopTimer,
                child: const Text('停止'),
              ),
            ),
          )
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}
