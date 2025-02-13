import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:object_detection/result_screen.dart';

void main() {
  runApp(const OCRScreen());
}

class OCRScreen extends StatelessWidget {
  const OCRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image to text',
      theme: ThemeData(
        //primarySwatch: Color(0xff005aee), // Set primarySwatch to transparent to remove the purple color
        primaryColor: Color(0xff005aee), // Set the primary color to 0xff005aee
        // Other theme configurations...
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;

  late final Future<void> _future;
  CameraController? _cameraController;

  final textRecognizer = TextRecognizer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        return Stack(
          children: [
            if (_isPermissionGranted)
              FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _initCameraController(snapshot.data!);

                    return Center(child: CameraPreview(_cameraController!));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            Scaffold(
              appBar: AppBar(
                title: const Text('Image to Text',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Sora',
                    fontWeight: FontWeight.w600,
                    height: 1.26,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Color(0xff005aee), // Set the background color of the AppBar
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              backgroundColor: _isPermissionGranted ? Colors.transparent : null,
              body: _isPermissionGranted
                  ? Column(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _scanImage,
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff005aee),
                          onPrimary: Colors.white,
                          padding: EdgeInsets.all(20),
                          shape: CircleBorder(),
                          elevation: 5,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Center(
                child: Container(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                  child: const Text(
                    'Camera permission denied',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Scaffold(
            //   appBar: AppBar(
            //     title: const Text('Image to Text'),
            //   ),
            //   backgroundColor: _isPermissionGranted ? Colors.transparent : null,
            //   body: _isPermissionGranted
            //       ? Column(
            //           children: [
            //             Expanded(
            //               child: Container(),
            //             ),
            //             Container(
            //               padding: const EdgeInsets.only(bottom: 30.0),
            //               child: Center(
            //                 child: ElevatedButton(
            //                   onPressed: _scanImage,
            //                   style: ElevatedButton.styleFrom(
            //                     primary: Color(0xff005aee), // Set the background color to a dark color
            //                     onPrimary: Colors.white, // Set the text color to white
            //                     padding: EdgeInsets.all(20), // Adjust padding as needed
            //                     shape: CircleBorder(), // Set the shape to a circle
            //                     elevation: 5, // Set the elevation (shadow) as needed
            //                   ),
            //                   child: Icon(
            //                     Icons.camera_alt,
            //                     size: 40, // Adjust icon size as needed
            //                   ),
            //                 ),
            //               ),
            //             ),
            //
            //             // Container(
            //             //   padding: const EdgeInsets.only(bottom: 30.0),
            //             //   child: Center(
            //             //     child: ElevatedButton(
            //             //       onPressed: _scanImage,
            //             //       child: const Text('Scan text'),
            //             //     ),
            //             //   ),
            //             // ),
            //           ],
            //         )
            //       : Center(
            //           child: Container(
            //             padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            //             child: const Text(
            //               'Camera permission denied',
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         ),
            // ),
          ],
        );
      },
    );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(FlashMode.off);

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _scanImage() async {
    if (_cameraController == null) return;

    final navigator = Navigator.of(context);

    try {
      final pictureFile = await _cameraController!.takePicture();

      final file = File(pictureFile.path);

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }
}
