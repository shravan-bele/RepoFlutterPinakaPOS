// import 'package:flutter/material.dart';
//
// // Custom NumPad Widget
// class CustomNumPad extends StatelessWidget {
//   final Function(String) onDigitPressed; // Callback for digit press
//   final VoidCallback onClearPressed; // Callback for "Clear" button
//   final VoidCallback onDeletePressed; // Callback for "Delete" button
//
//   const CustomNumPad({
//     super.key,
//     required this.onDigitPressed,
//     required this.onClearPressed,
//     required this.onDeletePressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Get device orientation
//     bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
//     double paddingValue = isPortrait ? 16 : 30;
//     return GridView.count(
//       shrinkWrap: true,
//       crossAxisCount: 3,
//       mainAxisSpacing: 12,
//       crossAxisSpacing: 12,
//       childAspectRatio: 2,
//       padding: EdgeInsets.symmetric(horizontal: paddingValue),
//       children: [
//         // Numeric Buttons
//         ...List.generate(9, (index) {
//           return _buildKey((index + 1).toString());
//         }),
//
//         // Clear Button
//         _buildActionKey(
//           text: "Clear",
//           onPressed: onClearPressed,
//           color: Colors.white,
//           textColor: Colors.black,
//         ),
//
//         // Zero Button
//         _buildKey("0"),
//
//         // Delete Button
//         _buildActionKey(
//           text: "Delete",
//           onPressed: onDeletePressed, // Fix to call delete method
//           color: Colors.white,
//           textColor: Colors.black,
//         ),
//       ],
//     );
//   }
//
//   // Build Numeric Key
//   Widget _buildKey(String value) {
//     return ElevatedButton(
//       onPressed: () {
//         onDigitPressed(value);
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Text(
//         value,
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
//       ),
//     );
//   }
//
//   // Build Action Key (Clear, Delete)
//   Widget _buildActionKey({
//     required String text,
//     required VoidCallback onPressed,
//     required Color color,
//     required Color textColor,
//   }) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: textColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
//       ),
//     );
//   }
// }

/// UPDATED CODE - NAVEEN

import 'package:flutter/material.dart';

import '../Constants/text.dart';

enum ActionButtonType { delete, ok, add } //Build #1.0.2 : Updated code - Action button types

class CustomNumPad extends StatelessWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onClearPressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onConfirmPressed;
  final VoidCallback? onAddPressed; // NEW: Add button callback
  final ActionButtonType actionButtonType; // NEW: Determines Delete, OK, or Add

  const CustomNumPad({
    super.key,
    required this.onDigitPressed,
    required this.onClearPressed,
    this.onDeletePressed,
    this.onConfirmPressed,
    this.onAddPressed,
    this.actionButtonType = ActionButtonType.delete, // Default: Delete
  });

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double paddingValue = isPortrait ? 16 : 30;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      padding: EdgeInsets.symmetric(horizontal: paddingValue),
      children: [
        // Numeric Buttons (1-9)
        ...List.generate(9, (index) {
          return _buildKey((index + 1).toString());
        }),

        // Clear Button (Always Present)
        _buildActionKey(
          text: TextConstants.clearText,
          onPressed: onClearPressed,
          color: Colors.white,
          textColor: Colors.black,
        ),

        // Zero Button
        _buildKey("0"),

        // Dynamic Action Button (Delete, OK, or Add)
        _buildActionKey(
          text: _getActionButtonText(),
          onPressed: _getActionButtonCallback(),
          color: _getActionButtonColor(),
          textColor: _getActionButtonTextColor(),
        ),
      ],
    );
  }

  // Get Action Button Text
  String _getActionButtonText() {
    switch (actionButtonType) {
      case ActionButtonType.ok:
        return TextConstants.okText;
      case ActionButtonType.add:
        return TextConstants.addText;
      default:
        return TextConstants.deleteText;
    }
  }

  // Get Action Button Callback
  VoidCallback _getActionButtonCallback() {
    switch (actionButtonType) {
      case ActionButtonType.ok:
        return onConfirmPressed ?? () {};
      case ActionButtonType.add:
        return onAddPressed ?? () {};
      default:
        return onDeletePressed ?? () {};
    }
  }

  // Get Action Button Color
  Color _getActionButtonColor() {
    return (actionButtonType == ActionButtonType.ok || actionButtonType == ActionButtonType.add)
        ? const Color(0xFF1E2745) // OK & Add use same color
        : Colors.white;
  }

  // Get Action Button Text Color
  Color _getActionButtonTextColor() {
    return (actionButtonType == ActionButtonType.ok || actionButtonType == ActionButtonType.add)
        ? Colors.white
        : Colors.black;
  }

  // Build Numeric Key
  Widget _buildKey(String value) {
    return ElevatedButton(
      onPressed: () {
        onDigitPressed(value);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
      ),
    );
  }

  // Build Action Key (Clear, Delete/OK/Add)
  Widget _buildActionKey({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
    );
  }
}