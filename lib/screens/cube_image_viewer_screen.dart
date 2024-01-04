import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image/image.dart' as img;

enum ColorName { white, yellow, green, blue, red, orange }

class TwoPicturesScreen extends StatelessWidget {
  final List<String> imagePathList;

  TwoPicturesScreen({Key? key, required this.imagePathList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorPalette = getColorPalette(imagePathList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cube view screen'),
      ),
      body: Column(
        children: [
          for (final imagePath in imagePathList)
            Expanded(
              child: convertImageToImage(
                imageRefiner(getImageFromPath(imagePath), colorPalette),
              ),
            ),
        ],
      ),
    );
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
    return img.decodeImage(imageFile.readAsBytesSync())!;
  }

  img.Image imageSquarer(img.Image image) {
    return img.copyResizeCropSquare(image, size: 300);
  }

  img.Image imageRefiner(img.Image image, List<Color> colorPalette) {
    image = imageSquarer(image);

    final pixelColorList = [
      convertRgbToColor(image.getPixel(50, 50)),
      convertRgbToColor(image.getPixel(150, 50)),
      convertRgbToColor(image.getPixel(250, 50)),
      convertRgbToColor(image.getPixel(50, 150)),
      convertRgbToColor(image.getPixel(150, 150)),
      convertRgbToColor(image.getPixel(250, 150)),
      convertRgbToColor(image.getPixel(50, 250)),
      convertRgbToColor(image.getPixel(150, 250)),
      convertRgbToColor(image.getPixel(250, 250)),
    ];

    final clearColorList = List.generate(
      9,
          (index) => mapToClosestColor(pixelColorList[index], colorPalette),
    );

    return generateColorZones(clearColorList);
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
        final targetColor = const Color(0xffffffff);

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

  Color mapToClosestColor(Color inputColor, List<Color> colorPalette) {
    final colorList = const <Color>[
      Color(0x00ffffff), // White
      Color(0x00ffff00), // Yellow
      Color(0x0000ff00), // Green
      Color(0x000000ff), // Blue
      Color(0x00ff0000), // Red
      Color(0x00ffa500), // Orange
    ];

    double minDistance = double.infinity;
    Color closestColor = const Color(0x00ffffff); // Default to white

    for (final color in colorPalette) {
      final distance = distanceBetweenTwoColors(inputColor, color);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = color;
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
