import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:signify/components/round_button.dart';
import 'package:signify/helpers/get_asset_as_file.dart';

class SightifyASLPage extends StatefulWidget {
  const SightifyASLPage({super.key});

  @override
  State<SightifyASLPage> createState() => _SightifyASLPageState();
}

class _SightifyASLPageState extends State<SightifyASLPage>
    with WidgetsBindingObserver {
  File? _imageFile;
  late File fs1;
  late File fs2;
  CameraController? _controller;
  bool _isTakingPicture = false;
  final Gemini gemini = Gemini.instance;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    initSamples();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> initSamples() async {
    fs1 = await getAssetAsFile('assets/help.png');
    fs2 = await getAssetAsFile('assets/sorry.png');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takeInstantPicture() async {
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      final XFile photo = await _controller!.takePicture();

      setState(() {
        _imageFile = File(photo.path);
        askGemini();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    } finally {
      await _controller?.dispose();
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  final List<String> reference = [
    "Help",
    "Sorry",
  ];

  void askGemini() {
    log("USING GEMINI");
    gemini.textAndImage(
      text: "Identify and interpret any sign language gestures in this image. If you see ASL (American Sign Language) gestures, tell me what they mean. Keep the response concise. VERY CONCISE, AROUND 5 WORDS. USE THE SUPPLIED IMAGES as REFERENCE. If the 1st image matches, the references, tell its name. the index of the image and the sign name are -> ${jsonEncode(reference)}",
      images: [_imageFile!.readAsBytesSync(), fs1.readAsBytesSync(), fs2.readAsBytesSync()],
    ).then(
      (value) {
        // log("RESPONSE FROM GEMINI");
        final dataContent = jsonDecode(jsonEncode(value!.content!.parts![0]))
            as Map<String, dynamic>;
        _showResponseDialog(dataContent['text'] ?? "Error encountered!");
      },
    ).catchError((e) {
      // log(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("We cannot reach our service right now")),
        );
      }
    });
  }

  void _showResponseDialog(String response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation'),
        content: Text(response),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Language Interpreter"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_imageFile == null)
            // Banner1(
            //   bannerIcon: Icons.sign_language,
            //   tilt: 3.14 / 2,
            // ),
            const Text("click a picture to identify the sign"),
          if (_imageFile != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: GestureDetector(
                  key: _key,
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(27),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundButton(
                  iconColor: Theme.of(context).colorScheme.inversePrimary,
                  icon: Icons.camera_alt,
                  onPressed: (_isTakingPicture) ? () {} : _takeInstantPicture,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 