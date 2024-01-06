import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image/image.dart' as img;

class CubeProcessor {

  static String process(List<String> imagePathList) {
    final colorPalette = _getColorPalette(imagePathList);
    List<String> cubeSides = List.empty(growable: true);
    String cubeSidesString = "";

    for (final imagePath in imagePathList) {
      cubeSides.add(_cubeSideColorExtractor(
        _getImageFromPath(imagePath),
        colorPalette,
      ));
    }

    List<String> tempCubeSides = List.empty(growable: true);
    tempCubeSides.add(cubeSides[0]);
    tempCubeSides.add(cubeSides[5]);
    tempCubeSides.add(cubeSides[2]);
    tempCubeSides.add(cubeSides[1]);
    tempCubeSides.add(cubeSides[3]);
    tempCubeSides.add(cubeSides[4]);
    cubeSidesString = tempCubeSides.join();

    return cubeSidesString;
  }

  static String _cubeSideColorExtractor(img.Image image, List<Color> colorPalette) {
    image = _imageSquarer(image);

    final pixelColorList = List.generate(
      9,
      (index) => _convertRgbToColor(
          image.getPixel(50 + (index % 3) * 100, 50 + (index ~/ 3) * 100)),
    );

    final clearColorList = List.generate(
      9,
          (index) => _mapToClosestColor(pixelColorList[index], colorPalette),
    );

    return clearColorList.join();
  }

  static List<Color> _getColorPalette(List<String> imagePaths) {
    final colorPalette = <Color>[];

    for (final imagePath in imagePaths) {
      final image = _imageSquarer(_getImageFromPath(imagePath));
      colorPalette.add(_convertRgbToColor(image.getPixel(150, 150)));

      // For the first color, white, take the color that is closest to white in a 20x20 pixel area in the center of the image
      if (imagePaths.indexOf(imagePath) == 0) {
        double minDistance = double.infinity;
        const targetColor = Colors.white;

        for (int row = 140; row < 160; row++) {
          for (int col = 140; col < 160; col++) {
            final distance = _distanceBetweenTwoColors(
              targetColor,
              _convertRgbToColor(image.getPixel(row, col)),
            );
            if (distance < minDistance) {
              minDistance = distance;
              colorPalette[0] = _convertRgbToColor(image.getPixel(row, col));
            }
          }
        }
      }
    }

    return colorPalette;
  }

  static img.Image _imageSquarer(img.Image image) {
    return img.copyResizeCropSquare(image, size: 300);
  }

  static img.Image _getImageFromPath(String imagePath) {
    final imageFile = File(imagePath);
    return img.decodeImage(imageFile.readAsBytesSync())!;
  }

  static Color _convertRgbToColor(img.Color color) {
    return Color.fromRGBO(
      color.getChannel(img.Channel.red).floor(),
      color.getChannel(img.Channel.green).floor(),
      color.getChannel(img.Channel.blue).floor(),
      1,
    );
  }

  static double _distanceBetweenTwoColors(Color color1, Color color2) {
    return sqrt(
      pow(color1.red - color2.red, 2) +
          pow(color1.green - color2.green, 2) +
          pow(color1.blue - color2.blue, 2),
    );
  }


  static String _mapToClosestColor(Color color, List<Color> colorPalette) {
    const colorList = <String>["U", "D", "F", "L", "B", "R"];

    double minDistance = double.infinity;
    String closestColor = "U";

    // for (final paletteColor in colorPalette) {
    for(int i = 0; i < colorPalette.length; i++) {
      final distance = _distanceBetweenTwoColors(color, colorPalette[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = colorList[i];
      }
    }

    return closestColor;
  }
}
