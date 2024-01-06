import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int imageToTake = 0;
  int amountOfImages = 6;
  List<String> imagePaths = List.generate(6, (index) => '');

  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      controller.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {});
      }
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("Camera access denied");
            // Handle access errors here.
            break;
          default:
            print("Camera error");
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          cameraWidget(context, controller),
          Align(
            alignment: Alignment.topCenter,
            child: squareHalfTransparentBox(context),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: squareHalfTransparentBox(context),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: cubeSideInfo(imageToTake),
          ),
          aboveAndUnderSideInfo(imageToTake),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0x00000000),
        // Set height of bottom navigation bar
        onTap: (int index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            if (imageToTake < amountOfImages - 1) {
              takePicture(context, controller).then((value) => setState(() {
                    imagePaths[imageToTake] = value;
                    imageToTake++;
                  }));
            } else if (imageToTake >= amountOfImages - 1) {
              takePicture(context, controller).then((value) => setState(() {
                    imagePaths[imageToTake] = value;
                    imageToTake = 0;
                    context.goNamed('/cube_confirmation',
                        pathParameters: {'id1': imagePaths.join(',')});
                  }));
            }
          }
        },
        unselectedItemColor: const Color(0xff674fa5),
        selectedItemColor: const Color(0xff674fa5),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Back',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Take Picture',
          ),
        ],
      ),
    );
  }
}

Widget cameraWidget(BuildContext context, CameraController controller) {
  // How do I add a rounded corner to the camera preview?
  // Use a ClipRRect widget with a BorderRadius.
  return Transform.scale(
    scale: 1,
    child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CameraPreview(controller),
        ),
      // child: CameraPreview(controller),
    ),
  );
}

Future<String> takePicture(
    BuildContext context, CameraController controller) async {
  try {
    while (controller.value.isTakingPicture) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await controller.setFocusMode(FocusMode.locked);
    await controller.setExposureMode(ExposureMode.locked);
    final image = await controller.takePicture();
    await controller.setFocusMode(FocusMode.auto);
    await controller.setExposureMode(ExposureMode.auto);

    return image.path;
  } catch (e) {
    print("There was an error taking a picture: $e");
    return Future.error(e);
  }
}

Widget squareHalfTransparentBox(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;
  return Container(
    height: (screenHeight - screenWidth) / 2,
    decoration: const BoxDecoration(
      color: Color(0x50000000),
    ),
  );
}

Map<String, Color> colorEnum(int color) {
  switch (color) {
    case 0:
      return {'White': const Color(0xc0e0e0e0)};
    case 1:
      return {'Yellow': const Color(0xc0ffff00)};
    case 2:
      return {'Green': const Color(0xc000ff00)};
    case 3:
      return {'Orange': const Color(0xc0ff8000)};
    case 4:
      return {'Blue': const Color(0xc00000ff)};
    case 5:
      return {'Red': const Color(0xc0ff0000)};
    default:
      return {'No such color exists': const Color(0xff000000)};
  }
}

Widget cubeSideInfo(int sideName) {
  return Text(
    "\nSide to take image of: ${colorEnum(sideName).keys.first.toString()}",
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: Color(0xff674fa5),
      fontSize: 25,
    ),
  );
}

Widget aboveAndUnderSideInfo(int side) {
  // Ranges top: 0 => 4, 1 => 2, 2-5 => 0
  // Ranges bottom: 0 => 2, 1 => 4, 2-5 => 1
  final topSide = side == 0
      ? 4
      : side == 1
          ? 2
          : 0;
  final bottomSide = side == 0
      ? 2
      : side == 1
          ? 4
          : 1;

  return Column(
    children: [
      Expanded(
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: colorEnum(topSide).values.first,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: colorEnum(side).values.first,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      Expanded(
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: colorEnum(bottomSide).values.first,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ],
  );
}
