import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../Utilities/constants.dart';

class TopBar extends StatelessWidget {
  final Function() onModeChanged;

  const TopBar({required this.onModeChanged, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/app_logo.svg',
            height: 40,
            width: 40,
          ),
          const SizedBox(width: 140),
           Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: AppConstants.searchHint,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 140),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.calculate),
              ),
              const Text(
                'Calculator',
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.pause),
              ),
              const Text(
                'Hold',
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onModeChanged,
                icon: const Icon(Icons.switch_right),
              ),
              const Text(
                'Mode',
                style: TextStyle(fontSize: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}