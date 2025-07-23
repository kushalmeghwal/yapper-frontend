// import 'package:flutter/material.dart';

// class SwipePagesUi{
//    static Widget makeSwipePagesUI({
//     required String title,
//     required String hintText,
//     bool isPassword = false,
//     VoidCallback? onNext,
//     VoidCallback? onBack,
//     required int activeDotIndex,
//     required ValueChanged<String> onTextChanged,
//     required bool isLastPage,
//   }) {
//         TextEditingController textController = TextEditingController();
//      return Container(
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(
//         colors: [Colors.deepPurple, Colors.purpleAccent],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         /// Title
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             shadows: [
//               Shadow(
//                 blurRadius: 4,
//                 color: Colors.black38,
//                 offset: Offset(2, 2),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 30),

//         /// TextField inside a Glassmorphic Card
//         Container(
//           width: 320,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(15),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: textController,
//               onChanged: onTextChanged,
//               obscureText: isPassword,
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: hintText,
//                 hintStyle: const TextStyle(color: Colors.white70),
//                 border: InputBorder.none,
//                 icon: Icon(
//                   isPassword ? Icons.lock : Icons.person,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         const SizedBox(height: 20),

  
//           /// Buttons Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               if (onBack != null)
//                 ElevatedButton(
//                   onPressed: onBack,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white24,
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(15),
//                   ),
//                   child: const Icon(Icons.arrow_back, color: Colors.white),
//                 ),
//               ElevatedButton(
//                 onPressed: onNext,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.3),
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text(
//                   isLastPage ? "Finish" : "Next",
//                   style: const TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 40),

//           /// Animated Progress Indicator
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//               3,
//               (index) => AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 margin: const EdgeInsets.symmetric(horizontal: 5),
//                 height: 12,
//                 width: index == activeDotIndex ? 24 : 12,
//                 decoration: BoxDecoration(
//                   color: index == activeDotIndex ? Colors.white : Colors.white38,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




