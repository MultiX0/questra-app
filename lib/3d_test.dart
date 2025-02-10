// import 'package:flutter/material.dart';
// import 'package:o3d/o3d.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // to control the animation
//   O3DController controller = O3DController();

// ignore_for_file: file_names

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text("test"),
//         actions: [
//           IconButton(
//               onPressed: () => controller.cameraOrbit(20, 20, 5),
//               icon: const Icon(Icons.change_circle)),
//           IconButton(
//               onPressed: () => controller.cameraTarget(1.2, 1, 4),
//               icon: const Icon(Icons.change_circle_outlined)),
//         ],
//       ),
//       body: O3D.asset(
//         src: 'assets/glb/hall.glb',
//         controller: controller,
//         // Set initial camera position to be at the entrance
//         cameraTarget: CameraTarget(0, 1, -5), // Adjust these values based on your model
//         cameraOrbit: CameraOrbit(
//             0, // Horizontal rotation
//             90, // Vertical angle
//             2 // Distance from target
//             ),
//         // Enable camera controls
//         cameraControls: true,
//         // Adjust min/max values to allow closer inspection
//         minCameraOrbit: "auto 0deg auto",
//         maxCameraOrbit: "auto infinity auto",
//         // Allow zooming in closer
//         minFieldOfView: "10deg",
//         maxFieldOfView: "90deg",
//         // Disable boundaries that might prevent "entering"
//         interpolationDecay: 100,
//         disablePan: false,
//         disableZoom: false,
//       ),
//     );
//   }
// }
