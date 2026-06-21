import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceValidationScreen extends StatefulWidget {
  final bool useFrontCamera;
  const FaceValidationScreen({super.key, this.useFrontCamera = true});

  @override
  State<FaceValidationScreen> createState() => _FaceValidationScreenState();
}

class _FaceValidationScreenState extends State<FaceValidationScreen> {
  CameraController? _cameraController;
  final FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions(enableTracking: true));
  bool _isDetecting = false;
  bool _faceDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No hay cámaras disponibles");
      
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == (widget.useFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});

      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || _faceDetected) return;
        _isDetecting = true;
        _processImage(image);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de cámara: $e. Usa simulación.')));
      }
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty && !_faceDetected) {
        _faceDetected = true;
        _cameraController?.stopImageStream();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rostro validado exitosamente ✅'), backgroundColor: Colors.green));
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context, true); // Retorna éxito
        }
      }
    } catch (e) {
      // Ignorar errores del stream
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Validación Facial')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Simular Éxito (Emulador)'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Validación Facial')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          Center(
            child: Container(
              width: 250,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(color: _faceDetected ? Colors.green : Colors.white, width: 4),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          const Positioned(
            bottom: 50, left: 0, right: 0,
            child: Text(
              'Ubica el rostro en el óvalo',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 100, left: 0, right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Simular Éxito (Si la cámara falla)'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
