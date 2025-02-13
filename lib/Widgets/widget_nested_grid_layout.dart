import 'package:flutter/material.dart';
import 'dart:async';

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
  int? deletingIndex; //Build #1.0.2
  bool isLoading = false;

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

  Future<void> _deleteItem(int index) async { //Build #1.0.2 : added delete and cancel floating buttons for long press of grid item
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final bool apiSuccess = true;
    setState(() {
      isLoading = false;
    });

    if (apiSuccess) {
      setState(() {
        nestedItems[currentLevel].removeAt(index);
        deletingIndex = null;
      });
    } else { // show alert if deletion failed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Failed to delete the item. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
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
                    child: const Text("Back", style: TextStyle(color: Colors.black)),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
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
                    onTap: () => _onItemSelected(index), // Tap
                    onLongPress: () { //Build #1.0.2 : Long press code added
                      setState(() {
                        deletingIndex = index;
                      });
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Card(
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (deletingIndex == index)
                          Positioned(
                            top: -20,
                            right: 0,
                            child: Row(
                              children: [
                                FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Colors.red,
                                  onPressed: () => _deleteItem(index),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                const SizedBox(width: 0),
                                FloatingActionButton(
                                  mini: true,
                                  backgroundColor: Colors.grey,
                                  onPressed: () {
                                    setState(() {
                                      deletingIndex = null;
                                    });
                                  },
                                  child: const Icon(Icons.close, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                      ],
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


