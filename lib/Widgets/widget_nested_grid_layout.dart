import 'package:flutter/material.dart';

class NestedGridWidget extends StatefulWidget {
  const NestedGridWidget({super.key});

  @override
  _NestedGridWidgetState createState() => _NestedGridWidgetState();
}

class _NestedGridWidgetState extends State<NestedGridWidget> {
  List<List<String>> nestedItems = [
    ["Item 1", "Item 2", "Item 3"],
    ["SubItem 1", "SubItem 2"],
    ["SubSubItem 1"]
  ];

  int currentLevel = 0;
  List<String> navigationPath = ["Home"];

  void _onItemSelected(int index) {
    if (currentLevel + 1 < nestedItems.length) {
      setState(() {
        currentLevel++;
        navigationPath.add(nestedItems[currentLevel - 1][index]);
      });
    }
  }

  void _onBackPressed() {
    if (currentLevel > 0) {
      setState(() {
        currentLevel--;
        navigationPath.removeLast();
      });
    }
  }

  void _onNavigationPathTapped(int index) {
    if (index < currentLevel) {
      setState(() {
        currentLevel = index;
        navigationPath = navigationPath.sublist(0, index + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          if (currentLevel > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _onBackPressed,
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(navigationPath.length, (index) {
                          return GestureDetector(
                            onTap: () => _onNavigationPathTapped(index),
                            child: Row(
                              children: [
                                Text(
                                  navigationPath[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                if (index < navigationPath.length - 1)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemCount: nestedItems[currentLevel].length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onItemSelected(index),
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.image, size: 80, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    nestedItems[currentLevel][index],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '\$0.99',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


