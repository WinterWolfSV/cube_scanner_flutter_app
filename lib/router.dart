import 'package:cube_scanner/screens/cube_confirmation_screen.dart';
import 'package:cube_scanner/screens/cube_image_viewer_screen.dart';
import 'package:cube_scanner/screens/cube_scan_screen.dart';
import 'package:cube_scanner/screens/home_screen.dart';
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
                  path: 'camera_view/:id1',
                  name: '/camera_view',
                  builder: (BuildContext context, GoRouterState state) =>
                      TwoPicturesScreen(
                        imagePathList: state.pathParameters['id1']!.split(','),
                      )),
            ]),
        GoRoute(
            path: 'cube_confirmation/:id1',
            name: '/cube_confirmation',
            builder: (BuildContext context, GoRouterState state) =>
                CubeConfirmationScreen(
                  cubeSidesString: state.pathParameters['id1']!,
                )),
      ],
    ),
  ],
);
