import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../bloc/detection_bloc.dart';
import 'result_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../bloc/detection_bloc.dart';
import '../models/detection_result.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkConnection();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      _showError('Nenhuma câmera encontrada');
      return;
    }

    // Solicita permissão
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showError('Permissão de câmera negada');
      return;
    }

    try {
      _controller = CameraController(
        widget.cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      debugPrint('Camera inicializada com sucesso');
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showError('Erro ao inicializar câmera: $e');
    }
  }

  void _checkConnection() {
    context.read<DetectionBloc>().add(CheckConnectionEvent());
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _controller == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile picture = await _controller!.takePicture();
      final File imageFile = File(picture.path);

      if (mounted) {
        context.read<DetectionBloc>().add(DetectCarsEvent(imageFile));
      }
    } catch (e) {
      _showError('Erro ao tirar foto: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detector de Carros'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<DetectionBloc, DetectionState>(
        listener: (context, state) {
          if (state is DetectionSuccess) {
            setState(() {
              _isLoading = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResultScreen(
                  response: state.response,
                  imageFile: state.imageFile,
                ),
              ),
            );
          } else if (state is DetectionError) {
            setState(() {
              _isLoading = false;
            });
            _showError(state.message);
          } else if (state is ConnectionChecked && !state.isConnected) {
            _showError('Servidor não está disponível');
          }
        },
        child: Stack(
          children: [
            if (_isCameraInitialized)
              Positioned.fill(
                child: CameraPreview(_controller!),
              )
            else
              const Center(
                child: CircularProgressIndicator(),
              ),

            // Overlay com instruções
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Posicione a câmera para capturar carros na imagem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Botão de captura
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isLoading ? Colors.grey : Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}