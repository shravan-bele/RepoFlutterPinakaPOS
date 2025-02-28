import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../Constants/text.dart';
import '../Utilities/shimmer_effect.dart';

class NestedGridWidget extends StatefulWidget {
  final bool isHorizontal;
  final bool isLoading; // Add a loading state
  const NestedGridWidget({super.key, required this.isHorizontal, this.isLoading = false});

  @override
  _NestedGridWidgetState createState() => _NestedGridWidgetState();
}

class _NestedGridWidgetState extends State<NestedGridWidget> {
  // Nested items with different icons and titles
  List<List<Map<String, dynamic>>> nestedItems = [
    [
      {"title": "Apple", "icon": Icons.apple, "price": "\$0.99", "image": "https://via.placeholder.com/50"},
      {"title": "Banana", "icon": Icons.local_grocery_store, "price": "\$1.99", "image": "https://via.placeholder.com/50"},
      {"title": "Carrot", "icon": Icons.eco, "price": "\$2.99", "image": "https://via.placeholder.com/50"},
    ],
    [
      {"title": "Milk", "icon": Icons.local_drink, "price": "\$3.99", "image": "https://via.placeholder.com/50"},
      {"title": "Bread", "icon": Icons.bakery_dining, "price": "\$4.99", "image": "https://via.placeholder.com/50"},
      {"title": "Cheese", "icon": Icons.lunch_dining, "price": "\$5.99", "image": "https://via.placeholder.com/50"},
    ],
  ];

  int currentLevel = 0;
  List<String> navigationPath = ["Home"];
  bool isLoading = false;
  List<int?> reorderedIndices = []; // Track reordered indices for each nested list
  int? selectedItemIndex;

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize reorderedIndices for each nested list
    reorderedIndices = List.filled(nestedItems.length, null);
  }

  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _pickedImage = File(imageFile.path);
      });
    }
  }

  void _onItemSelected(int index) {
    if (currentLevel + 1 < nestedItems.length) {
      setState(() {
        currentLevel++;
        navigationPath.add(nestedItems[currentLevel - 1][index]["title"]);
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

  Future<void> _deleteItem(int listIndex, int itemIndex) async {
    setState(() {
      nestedItems[listIndex].removeAt(itemIndex);
      reorderedIndices[listIndex] = null; // Reset reordered index after deletion
    });
  }

  Future<void> _showAddItemDialog(int listIndex) async { //Build #1.0.4
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    Map<String, dynamic>? selectedProduct;

    Future<void> searchProducts(String query) async {
      if (query.isEmpty) {
        setState(() {
          searchResults.clear();
        });
        return;
      }

      final response = await http.get(Uri.parse('https://your-api-endpoint.com/search?q=$query'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = List<Map<String, dynamic>>.from(data['products']);
        });
      } else {
        throw Exception('Failed to load products');
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text(TextConstants.searchAddItemText),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: TextConstants.searchItemText,
                      hintText: TextConstants.typeSearchText,
                    ),
                    onChanged: (value) {
                      searchProducts(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (searchResults.isNotEmpty)
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final product = searchResults[index];
                          return ListTile(
                            title: Text(product['title']),
                            subtitle: Text(product['price']),
                            onTap: () {
                              setStateDialog(() {
                                selectedProduct = product;
                              });
                            },
                            selected: selectedProduct == product,
                            selectedTileColor: Colors.grey[300],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(TextConstants.cancelText),
              ),
              TextButton(
                onPressed: selectedProduct != null
                    ? () {
                  setState(() {
                    nestedItems[listIndex].add({
                      "title": selectedProduct!['title'],
                      "price": selectedProduct!['price'],
                      "image": selectedProduct!['image'] ?? "https://via.placeholder.com/50",
                      "icon": Icons.add,
                    });
                  });
                  Navigator.of(context).pop();
                }
                    : null,
                child: const Text(TextConstants.addText),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith("http")) {
      return Image.network(
        imagePath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.file(
        File(imagePath),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 50,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = nestedItems[currentLevel];
    final totalCount = currentList.length + 1;
    final theme = Theme.of(context); // Build #1.0.6 - Added theme for grid

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
                      side: BorderSide(color: theme.secondaryHeaderColor,),
                    ),
                    child: Text(TextConstants.backText, style: TextStyle(color: theme.secondaryHeaderColor)),
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Icon(Icons.arrow_forward, size: 16, color: theme.secondaryHeaderColor),
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
              color: Colors.transparent,
              child: widget.isLoading
                  ? ShimmerEffect.rectangular(height: 200) // Shimmer effect for the grid
                  :  Material(
                color: Colors.transparent,
                child: ReorderableGridView.builder( // Build #1.0.6 - Added Re order for grid
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                    childAspectRatio: widget.isHorizontal ? 2.2 : 1.8,
                  ),
                  itemCount: totalCount,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex == 0 || newIndex == 0) return;
                    final adjustedOldIndex = oldIndex - 1;
                    final adjustedNewIndex = newIndex - 1;
                    setState(() {
                      final item = currentList.removeAt(adjustedOldIndex);
                      currentList.insert(adjustedNewIndex, item);
                      reorderedIndices[currentLevel] = adjustedNewIndex;
                      selectedItemIndex = adjustedNewIndex; // Set selected item after reorder
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        key: const ValueKey('add_button'),
                        child: GestureDetector(
                          onTap: () => _showAddItemDialog(currentLevel),
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, size: 50, color: Colors.green),
                                SizedBox(height: 8),
                                Text(TextConstants.addItemText, style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      final itemIndex = index - 1;
                      final isReordered = reorderedIndices[currentLevel] == itemIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          border: isReordered ? Border.all(color: Colors.blue, width: 3) : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        key: ValueKey('grid_item_${currentLevel}_${itemIndex}_${currentList[itemIndex]["title"]}'),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedItemIndex == itemIndex) {
                                    selectedItemIndex = null; // Deselect if tapping the same item
                                  } else {
                                    selectedItemIndex = itemIndex;
                                    reorderedIndices[currentLevel] = null; // Hide delete/cancel on selection change
                                  }
                                  _onItemSelected(itemIndex);
                                });
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(currentList[itemIndex]["icon"], size: 50, color: Colors.blue),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              currentList[itemIndex]["title"],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              currentList[itemIndex]["price"],
                                              style: TextStyle(
                                                fontSize: 12,
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
                            ),
                            if (isReordered)
                              Positioned(
                                top: widget.isHorizontal ? -5 : -9,
                                right: widget.isHorizontal ? -2 : -4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () {
                                        _deleteItem(currentLevel, itemIndex);
                                      },
                                    ),
                                    const SizedBox(width: 0),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          reorderedIndices[currentLevel] = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


