import 'package:cube_scanner/screens/cube_confirmation_screen.dart';
import 'package:cube_scanner/screens/cube_scan_screen.dart';
import 'package:cube_scanner/screens/home_screen.dart';
import 'package:cube_scanner/screens/testing_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
            path: 'cube_scanner',
            builder: (BuildContext context, GoRouterState state) {
              return const CameraScreen();
            },
            routes: <RouteBase>[
              GoRoute(
                  path: 'cube_confirmation/:id1',
                  name: '/cube_confirmation',
                  builder: (BuildContext context, GoRouterState state) =>
                      CubeConfirmationScreen(
                        cubeSidesImagePaths:
                            state.pathParameters['id1']!.split(','),
                      )),
            ]),
        GoRoute(
            path: 'testing',
            builder: (BuildContext context, GoRouterState state) {
              return BleDeviceScreen();
            },
                ),
      ],
    ),
  ],
);
