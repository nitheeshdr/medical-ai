import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/prescriptions_provider.dart';
import '../../routes/route_names.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _camCtrl;
  bool _isScanning = false;
  bool _flashOn = false;
  late AnimationController _scanAnim;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _camCtrl = CameraController(cameras.first, ResolutionPreset.high);
    await _camCtrl!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _processImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final base64 = base64Encode(bytes);
    if (!mounted) return;
    // Pre-trigger the scan (async) and navigate to result screen
    ref.read(prescriptionScanProvider.notifier).scan(base64);
    context.push(RouteNames.scannerResult, extra: {'imagePath': path});
  }

  Future<void> _scanFromCamera() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized || _isScanning) return;
    setState(() => _isScanning = true);
    try {
      final image = await _camCtrl!.takePicture();
      if (mounted) {
        setState(() => _isScanning = false);
        await _processImage(image.path);
      }
    } catch (_) {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null || !mounted) return;
    await _processImage(image.path);
  }

  Future<void> _toggleFlash() async {
    _flashOn = !_flashOn;
    await _camCtrl?.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    _scanAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_camCtrl?.value.isInitialized == true)
            CameraPreview(_camCtrl!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Dimmed overlay with transparent frame
          _ScannerFrameOverlay(scanAnim: _scanAnim, isScanning: _isScanning),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _OverlayButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  const Text('Scan Prescription',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  _OverlayButton(
                    icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(32, 24, 32, MediaQuery.paddingOf(context).bottom + 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Align the prescription within the frame',
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(icon: Icons.photo_library_rounded, label: 'Gallery', onTap: _pickFromGallery),
                      // Shutter
                      GestureDetector(
                        onTap: _isScanning ? null : _scanFromCamera,
                        child: Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 4),
                          ),
                          child: _isScanning
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
                                )
                              : Icon(Icons.camera_alt_rounded, color: Colors.black, size: 30),
                        ),
                      ),
                      _ControlButton(icon: Icons.document_scanner_outlined, label: 'Docs', onTap: _pickFromGallery),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scanner frame overlay ──────────────────────────────────────────────────────

class _ScannerFrameOverlay extends StatelessWidget {
  final AnimationController scanAnim;
  final bool isScanning;
  const _ScannerFrameOverlay({required this.scanAnim, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Frame border
          Container(
            width: 280, height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kAccent, width: 2),
            ),
          ),
          // Corner accents
          ..._corners(),
          // Scan beam
          if (!isScanning)
            AnimatedBuilder(
              animation: scanAnim,
              builder: (_, __) => Positioned(
                top: 4 + scanAnim.value * 192,
                child: Container(
                  width: 276, height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      kAccent,
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
          if (isScanning)
            Container(
              width: 280, height: 200,
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: CircularProgressIndicator(color: kAccent)),
            ),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const size = 20.0;
    const width = 3.0;
    return [
      Positioned(top: 0, left: 0, child: _Corner(size: size, width: width, top: true, left: true)),
      Positioned(top: 0, right: 0, child: _Corner(size: size, width: width, top: true, left: false)),
      Positioned(bottom: 0, left: 0, child: _Corner(size: size, width: width, top: false, left: true)),
      Positioned(bottom: 0, right: 0, child: _Corner(size: size, width: width, top: false, left: false)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double size, width;
  final bool top, left;
  const _Corner({required this.size, required this.width, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _CornerPainter(width: width, top: top, left: left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double width;
  final bool top, left;
  const _CornerPainter({required this.width, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kAccent
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

// ── Controls ───────────────────────────────────────────────────────────────────

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ControlButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11)),
        ],
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OverlayButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
