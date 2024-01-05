import 'dart:math';

import 'package:cuber/cuber.dart' as cuber;
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image/image.dart' as img;

enum ColorName { white, yellow, green, blue, red, orange }
late List<String> cubeSides;
const Color constWhite = Color(0xffffffff);
const Color constYellow = Color(0xffffff00);
const Color constGreen = Color(0xff00ff00);
const Color constOrange = Color(0xffffa500);
const Color constBlue = Color(0xff0000ff);
const Color constRed = Color(0xffff0000);



class TwoPicturesScreen extends StatelessWidget {
  final List<String> imagePathList;

  TwoPicturesScreen({Key? key, required this.imagePathList}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final colorPalette = getColorPalette(imagePathList);
    cubeSides = List.empty(growable: true);


    Scaffold returnScaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Cube view screen'),
      ),
      body: Column(
        children: [
          for (final imagePath in imagePathList)
            Expanded(
              child: convertImageToImage(
                imageRefiner(getImageFromPath(imagePath), colorPalette).$1,
              ),
            ),
        ],
      ),
    );

    // Current order of cube sides: U, D, F, L, B, R
    // Desired order of cube sides: U, R, F, D, L, B

    List<String> tempCubeSides = List.empty(growable: true);
    tempCubeSides.add(cubeSides[0]);
    tempCubeSides.add(cubeSides[5]);
    tempCubeSides.add(cubeSides[2]);
    tempCubeSides.add(cubeSides[1]);
    tempCubeSides.add(cubeSides[3]);
    tempCubeSides.add(cubeSides[4]);
    String cubeSidesString = tempCubeSides.join();
    print(cubeSidesString);

    final cube0 = cuber.Cube.from(cubeSidesString);
    final cubeSolve = cube0.solve();
    print(cubeSolve);

    return returnScaffold;
  }

  Image convertImageToImage(img.Image image) {
    return Image.memory(img.encodeJpg(image));
  }

  Color convertRgbToColor(img.Color color) {
    return Color.fromRGBO(
      color.getChannel(img.Channel.red).floor(),
      color.getChannel(img.Channel.green).floor(),
      color.getChannel(img.Channel.blue).floor(),
      1,
    );
  }

  img.Image getImageFromPath(String imagePath) {
    final imageFile = File(imagePath);
    print(imagePath);
    return img.decodeImage(imageFile.readAsBytesSync())!;
  }

  img.Image imageSquarer(img.Image image) {
    return img.copyResizeCropSquare(image, size: 300);
  }

  (img.Image, String) imageRefiner(img.Image image, List<Color> colorPalette) {
    image = imageSquarer(image);

    final pixelColorList = List.generate(
      9,
      (index) => convertRgbToColor(
          image.getPixel(50 + (index % 3) * 100, 50 + (index ~/ 3) * 100)),
    );

    final clearColorList = List.generate(
      9,
      (index) => mapToClosestColor(pixelColorList[index], colorPalette),
    );

    String sideView = clearColorList.map((e) => fromColorToColorSide(e)).join();
    cubeSides.add(sideView);
    if(cubeSides.length == 1) {
      cubeSides[0] = cubeSides[0].replaceRange(4, 5, 'U');
      clearColorList[4] = constWhite;
    }

    return (generateColorZones(clearColorList), "#");
  }

  double distanceBetweenTwoColors(Color color1, Color color2) {
    return sqrt(
      pow(color1.red - color2.red, 2) +
          pow(color1.green - color2.green, 2) +
          pow(color1.blue - color2.blue, 2),
    );
  }

  List<Color> getColorPalette(List<String> imagePaths) {
    final colorPalette = <Color>[];

    for (final imagePath in imagePaths) {
      final image = imageSquarer(getImageFromPath(imagePath));
      colorPalette.add(convertRgbToColor(image.getPixel(150, 150)));

      // For the first color, white, take the color that is closest to white in a 20x20 pixel area in the center of the image
      if (imagePaths.indexOf(imagePath) == 0) {
        double minDistance = double.infinity;
        const targetColor = constWhite;

        for (int row = 140; row < 160; row++) {
          for (int col = 140; col < 160; col++) {
            final distance = distanceBetweenTwoColors(
              targetColor,
              convertRgbToColor(image.getPixel(row, col)),
            );
            if (distance < minDistance) {
              minDistance = distance;
              colorPalette[0] = convertRgbToColor(image.getPixel(row, col));
            }
          }
        }
      }
    }

    return colorPalette;
  }

  String fromColorToColorSide(Color color) {
    switch (color) {
      case constWhite:
        return 'U';
      case constYellow:
        return 'D';
      case constGreen:
        return 'F';
      case constOrange:
        return 'L';
      case constBlue:
        return 'B';
      case constRed:
        return 'R';
      default:
        return 'No such color exists';
    }
  }

  Color mapToClosestColor(Color inputColor, List<Color> colorPalette) {
    const colorList = <Color>[
      constWhite,
      constYellow,
      constGreen,
      constOrange,
      constBlue,
      constRed,
    ];

    double minDistance = double.infinity;
    Color closestColor = constWhite; // Default to white

    // for (final color in colorPalette) {
    for (int i = 0; i < colorPalette.length; i++) {
      final distance = distanceBetweenTwoColors(inputColor, colorPalette[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = colorList[i];
        // closestColor = colorPalette[i];
      }
    }

    return closestColor;
  }

  img.Image generateColorZones(List<Color> zoneColors) {
    if (zoneColors.length != 9) {
      throw ArgumentError('The list must contain exactly 9 colors.');
    }

    // Create a 300x300 pixel image
    final image = img.Image(width: 100, height: 100);

    // Fill each zone with the corresponding color
    final zoneWidth = image.width ~/ 3;
    final zoneHeight = image.height ~/ 3;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        // Fill the zone with the corresponding color
        final color = image.getPixel(0, 0);
        color.setRgb(
          zoneColors[row * 3 + col].red,
          zoneColors[row * 3 + col].green,
          zoneColors[row * 3 + col].blue,
        );
        img.fillRect(
          image,
          x1: col * zoneWidth,
          y1: row * zoneHeight,
          x2: (col + 1) * zoneWidth,
          y2: (row + 1) * zoneHeight,
          color: color,
        );
      }
    }

    return image;
  }
}
