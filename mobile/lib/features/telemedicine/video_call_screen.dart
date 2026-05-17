import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorId;
  const VideoCallScreen({super.key, required this.doctorId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _muted = false;
  bool _cameraOff = false;
  bool _speakerOn = true;
  final _duration = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      _duration.value++;
      return true;
    });
  }

  String get _timeStr {
    final m = _duration.value ~/ 60;
    final s = _duration.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Remote video (doctor)
          Container(
            color: const Color(0xFF0A0A0A),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(backgroundColor: kBorder, radius: 48,
                  child: Text(widget.doctorId[4].toUpperCase(), style: const TextStyle(color: kPrimaryText, fontSize: 40, fontWeight: FontWeight.w700))),
              const SizedBox(height: 16),
              Text(widget.doctorId, style: const TextStyle(color: kPrimaryText, fontSize: 20, fontWeight: FontWeight.w600)),
              ValueListenableBuilder(
                valueListenable: _duration,
                builder: (_, val, __) => Text(_timeStr, style: const TextStyle(color: kSecondaryText, fontSize: 14)),
              ),
            ]),
          ),
          // Self video (small)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16, right: 16,
            child: Container(
              width: 100, height: 140,
              decoration: BoxDecoration(color: kElevated, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
              child: _cameraOff
                  ? const Icon(Icons.videocam_off_rounded, color: kSecondaryText)
                  : const Icon(Icons.person_rounded, color: kSecondaryText, size: 40),
            ),
          ),
          // Controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallButton(icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _muted ? 'Unmute' : 'Mute', color: _muted ? kErrorRed : kElevated,
                    onTap: () => setState(() => _muted = !_muted)),
                _CallButton(icon: Icons.call_end_rounded, label: 'End', color: kErrorRed,
                    onTap: () => Navigator.pop(context), size: 64),
                _CallButton(icon: _cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    label: _cameraOff ? 'Start Cam' : 'Stop Cam', color: _cameraOff ? kErrorRed : kElevated,
                    onTap: () => setState(() => _cameraOff = !_cameraOff)),
                _CallButton(icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    label: _speakerOn ? 'Speaker' : 'Earpiece', color: kElevated,
                    onTap: () => setState(() => _speakerOn = !_speakerOn)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _CallButton({required this.icon, required this.label, required this.color, required this.onTap, this.size = 56});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: kPrimaryText, size: size * 0.4)),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: kSecondaryText, fontSize: 11)),
    ]),
  );
}
