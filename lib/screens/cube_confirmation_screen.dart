import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cuber/cuber.dart' as cuber;

String colorToChange = 'U';

class CubeConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String cubeFormat =
        "BRULUDFDUBFFBRLFBBDLRFFUBUDULRUDDULRLDLLLLLFLRFDDBBDBF";
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Rubik\'s Cube'),
        ),
        body: RubiksCube(
          cubeFormat: cubeFormat,
        ),
        bottomNavigationBar: colorSelectionBar(),
      ),
    );
  }
}

class RubiksCube extends StatefulWidget {
  String cubeFormat;

  RubiksCube({required this.cubeFormat});

  @override
  State<RubiksCube> createState() => _RubiksCubeState();
}

class _RubiksCubeState extends State<RubiksCube> {
  @override
  Widget build(BuildContext context) {
    print(widget.cubeFormat);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCubeFace(0, 9, false),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCubeFace(36, 45, false),
            buildCubeFace(18, 27, false),
            buildCubeFace(9, 18, false),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCubeFace(27, 36, false),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCubeFace(45, 54, true),
          ],
        ),
        Text(
            '\n\n${cubeSolution()}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
        )
      ],
    );
  }

  String cubeSolution() {
    final cube0 = cuber.Cube.from(widget.cubeFormat);
    final cubeSolve = cube0.solve();
    return cubeSolve.toString();
  }

  Widget buildCubeFace(int start, int end, bool reversed) {
    return CubeFace(
      faceFormat: reversed
          ? widget.cubeFormat.substring(start, end).split('').reversed.join()
          : widget.cubeFormat.substring(start, end),
      onFaceFormatChanged: (modifiedFaceFormat) {
        setState(() {
          widget.cubeFormat = reversed
              ? widget.cubeFormat.replaceRange(
                  start, end, modifiedFaceFormat.split('').reversed.join())
              : widget.cubeFormat.replaceRange(start, end, modifiedFaceFormat);
        });
      },
    );
  }
}

class CubeFace extends StatefulWidget {
  String faceFormat;
  final ValueChanged<String> onFaceFormatChanged;

  CubeFace({required this.faceFormat, required this.onFaceFormatChanged});

  @override
  State<CubeFace> createState() => _CubeFaceState();
}

class _CubeFaceState extends State<CubeFace> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Row(
            children: [
              for (int j = 0; j < 3; j++)
                Container(
                  width: screenWidth / 9 - 5,
                  height: screenWidth / 9 - 5,
                  color: getColor(widget.faceFormat[i * 3 + j]),
                  margin: EdgeInsets.all(2),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.faceFormat = widget.faceFormat.replaceRange(
                            i * 3 + j, i * 3 + j + 1, colorToChange);
                      });
                      widget.onFaceFormatChanged(widget.faceFormat);
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Color getColor(String facelet) {
    switch (facelet) {
      case 'U':
        return Colors.white;
      case 'R':
        return Colors.red;
      case 'F':
        return Colors.green;
      case 'D':
        return Colors.yellow;
      case 'L':
        return Colors.orange;
      case 'B':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}

class colorSelectionBar extends StatefulWidget {
  const colorSelectionBar({super.key});

  @override
  State<colorSelectionBar> createState() => _colorSelectionBarState();
}

class _colorSelectionBarState extends State<colorSelectionBar> {
  Map<String, Color> stringToColor = {
    'U': Colors.white,
    'R': Colors.red,
    'F': Colors.green,
    'D': Colors.yellow,
    'L': Colors.orange,
    'B': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (String key in stringToColor.keys)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stringToColor[key],
                border: Border.all(
                  color: Colors.black,
                  width: colorToChange == key ? 2 : 0,
                  // width: 1,
                ),
              ),
              margin: EdgeInsets.all(2),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    colorToChange = key;
                  });
                  print(key);
                },
              ),
            ),
        ],
      ),
    );
  }
}
