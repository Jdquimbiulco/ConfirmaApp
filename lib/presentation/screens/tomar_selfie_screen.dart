import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/login_viewmodel.dart';

class TomarSelfieScreen extends StatefulWidget {
  const TomarSelfieScreen({super.key});

  @override
  State<TomarSelfieScreen> createState() => _TomarSelfieScreenState();
}

class _TomarSelfieScreenState extends State<TomarSelfieScreen> {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isInit = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(frontCamera, ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInit = true;
      });
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _tomarFoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    setState(() => _isSaving = true);

    try {
      final XFile foto = await _controller!.takePicture();
      
      // --- VALIDACIÓN DE IA (ML KIT) ---
      final inputImage = InputImage.fromFilePath(foto.path);
      final faceDetector = FaceDetector(options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast));
      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      if (faces.isEmpty) {
        setState(() => _isSaving = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No se detectó ningún rostro humano.'), backgroundColor: Colors.red));
        return;
      }

      if (faces.length > 1) {
        setState(() => _isSaving = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Múltiples rostros detectados. Tómate la foto a solas.'), backgroundColor: Colors.red));
        return;
      }
      // ----------------------------------

      final viewModel = context.read<LoginViewModel>();
      final user = viewModel.currentUser;
      if (user != null) {
        await context.read<AuthRepository>().registrarBiometriaConFoto(user.id, File(foto.path));
        await viewModel.checkSession();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Biometría registrada correctamente en Storage!')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInit || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registro Biométrico')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Transform.scale(
                scale: 1.0,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / _controller!.value.aspectRatio,
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Enmarca tu rostro dentro del círculo y pulsa capturar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: _isSaving
                ? const CircularProgressIndicator()
                : FloatingActionButton.large(
                    onPressed: _tomarFoto,
                    child: const Icon(Icons.camera_alt),
                  ),
          )
        ],
      ),
    );
  }
}
