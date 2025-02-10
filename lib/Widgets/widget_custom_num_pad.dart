import 'package:flutter/material.dart';

// Custom NumPad Widget
class CustomNumPad extends StatelessWidget {
  final Function(String) onDigitPressed; // Callback for digit press
  final VoidCallback onClearPressed; // Callback for "Clear" button
  final VoidCallback onDeletePressed; // Callback for "Delete" button

  const CustomNumPad({
    super.key,
    required this.onDigitPressed,
    required this.onClearPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get device orientation
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
        // Numeric Buttons
        ...List.generate(9, (index) {
          return _buildKey((index + 1).toString());
        }),

        // Clear Button
        _buildActionKey(
          text: "Clear",
          onPressed: onClearPressed,
          color: Colors.white,
          textColor: Colors.black,
        ),

        // Zero Button
        _buildKey("0"),

        // Delete Button
        _buildActionKey(
          text: "Delete",
          onPressed: onDeletePressed, // Fix to call delete method
          color: Colors.white,
          textColor: Colors.black,
        ),
      ],
    );
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

  // Build Action Key (Clear, Delete)
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
