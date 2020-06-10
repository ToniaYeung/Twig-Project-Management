import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/clickable_card.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_future_builder.dart';
import 'package:twig/firebase/storage.dart';

class CameraScreenLoader extends StatelessWidget {
  final String taskId;

  const CameraScreenLoader(this.taskId);
  @override
  Widget build(BuildContext context) {
    return LoadingFutureBuilder<List<CameraDescription>>(
        // Get all the available cameras that the phone has
        future: availableCameras(),
        builder: (context, allCameras) {
          //Making an assumption that the rear camera will be the first in the list
          CameraDescription rearCamera = allCameras.first;
          return CameraScreen(rearCamera, taskId);
        });
  }
}

class CameraScreen extends StatefulWidget {
  final String taskId;
  final CameraDescription rearCamera;

  const CameraScreen(this.rearCamera, this.taskId);
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  bool loading;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.rearCamera, ResolutionPreset.medium);
    loading = true;
    controller.initialize().then((_) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColour,
      body: loading
          ? CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cameraPreviewWidget(),
                Image.asset('images/twig.png',
                    width: 80, height: 40, fit: BoxFit.fill),
                _takePictureButton(),
              ],
            ),
    );
  }

  Widget _cameraPreviewWidget() {
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  Widget _takePictureButton() {
    return ClickableCard(
      child: Image.asset('images/camera.png',
          width: 50, height: 50, fit: BoxFit.fill),
      padding: 10,
      onTap: () {
        setState(() {
          loading = true;
        });

        takePicture().then((String filePath) {
          setState(() {
            loading = false;
          });
          Navigator.pop(context);
        });
      },
    );
  }

  Future<String> takePicture() async {
    //part of path provider
    Directory directory = await getApplicationDocumentsDirectory();
    String directoryPath = "${directory.path}/pictures";
    //recursive creates all of the folders in the directory file
    await Directory(directoryPath).create(recursive: true);
    //Example filepath is applications/twig/documents/pictures/34289483294382.jpg
    String filePath =
        "$directoryPath/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";

    //only the first picture will be saved
    if (controller.value.isTakingPicture) {
      return null;
    }

    //when you await a future you turn it back to synchronous
    await controller.takePicture(filePath);
    Storage storage = Provider.of<Storage>(context);
    await storage.uploadTaskPhoto(filePath, widget.taskId);
    return filePath;
  }
}
