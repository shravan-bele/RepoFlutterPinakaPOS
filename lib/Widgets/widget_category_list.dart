import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Constants/text.dart';
import '../Database/db_helper.dart';
import '../Database/fast_key_db_helper.dart';
import '../Helper/file_helper.dart';
import '../Models/Auth/login_model.dart';
import '../Models/FastKey/category_model.dart';
import '../Utilities/shimmer_effect.dart';

class CategoryList extends StatefulWidget {
  final bool isHorizontal; // Build #1.0.6
  final bool isLoading; // Add a loading state
  final ValueNotifier<int?> fastKeyTabIdNotifier; // Add this

  const CategoryList({super.key, required this.isHorizontal, this.isLoading = false, required this.fastKeyTabIdNotifier});

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  // Scroll controller to manage horizontal scrolling
  final ScrollController _scrollController = ScrollController();
  // Flags to show left and right scroll arrows
  bool _showLeftArrow = false;
  bool _showRightArrow = true;
  int? _selectedIndex; // Changed to nullable for better handling
  int? _editingIndex; // Track the item being reordered or edited
  int? userId;

  // FastKey helper instance
  final FastKeyHelper fastKeyHelper = FastKeyHelper();
  // List of FastKey products fetched from the database
  List<CategoryModel> fastKeyProducts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showLeftArrow = _scrollController.offset > 0;
        _showRightArrow = _scrollController.offset < _scrollController.position.maxScrollExtent;
      });
    });

    getUserId();
    widget.fastKeyTabIdNotifier.addListener(_onTabChanged); // Listen to tab changes
  }

  void _onTabChanged() { // Build #1.0.12: fixed fast key tab related issue
    if (kDebugMode) {
      print("### _onTabChanged: New Tab ID: ${widget.fastKeyTabIdNotifier.value}");
    }
    // Perform asynchronous work first
    _loadFastKeysTabs().then((_) {
      // Update state synchronously
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadLastSelectedTab() async { // Build #1.0.11
    final lastSelectedTabId = await fastKeyHelper.getActiveFastKeyTab();
    if (kDebugMode) {
      print("#### fastKeyHelper.getFastKeyTabFromPref: $lastSelectedTabId");
    }
    if (lastSelectedTabId != null) {
      setState(() {
        _selectedIndex = fastKeyProducts.indexWhere((tab) => tab.id == lastSelectedTabId);
      });
    }

    if (kDebugMode) {
      print("#### _selectedIndex: $_selectedIndex");
    }
  }

  Future<void> getUserId() async { // Build #1.0.11
    try {
      final LoginResponse? response = await FileHelper.readLoginResponse();

      if (response != null) {
        userId = response.id; // Assuming `id` is a property in `LoginResponse`

        if (kDebugMode) {
          print("#### userId: $userId");
        }

        // Load FastKey tabs from the database
        await _loadFastKeysTabs(); // Wait for tabs to load
        await _loadLastSelectedTab(); // Now load the last selected tab
      } else {
        if (kDebugMode) {
          print("No user ID found in login response.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception in getUserId: $e");
      }
    }
  }

  // Add a method to check if content overflows
  bool _doesContentOverflow() { // Build #1.0.11
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = fastKeyProducts.length * 120; // Adjust based on item width
    return contentWidth > screenWidth;
  }

  Future<void> _loadFastKeysTabs() async { // Build #1.0.11
    final fastKeyTabs = await fastKeyHelper.getFastKeyTabsByUserId(userId ?? 1);
    if (kDebugMode) {
      print("#### fastKeyTabs : $fastKeyTabs");
    }
    // Convert the list of maps to a list of CategoryModel
    setState(() {
      fastKeyProducts = fastKeyTabs.map((product) {
        return CategoryModel(
          name: product[AppDBConst.fastKeyTabTitle],
          itemCount: product[AppDBConst.fastKeyTabCount].toString(),
          imageAsset: product[AppDBConst.fastKeyTabImage],
          id: product[AppDBConst.fastKeyId],
        );
      }).toList();
    });
  }

  Future<void> _addFastKeyTab(String title, String image) async {
    final newTabId = await fastKeyHelper.addFastKeyTab(userId ?? 1, title, image, 0, 0);

    // Add the new tab to the local list
    setState(() {
      fastKeyProducts.add(CategoryModel(
        name: title,
        itemCount: "0",
        imageAsset: image,
        id: newTabId,
      ));
      _selectedIndex = fastKeyProducts.length - 1; // Set the selected index to the new tab
    });

    // Save the selected tab ID
    await fastKeyHelper.saveActiveFastKeyTab(newTabId);
    if (kDebugMode) {
      print("### _addFastKeyTab: Setting ValueNotifier to $newTabId");
    }
    widget.fastKeyTabIdNotifier.value = newTabId; // Notify NestedGridWidget
  }

  Future<void> _deleteFastKeyTab(int fastKeyProductId) async {
    await fastKeyHelper.deleteFastKeyTab(fastKeyProductId);

    // Remove the tab from the local list
    setState(() {
      fastKeyProducts.removeWhere((tab) => tab.id == fastKeyProductId);
    });

    // Update the item count in the FastKey tab
    await fastKeyHelper.updateFastKeyTabCount(fastKeyProductId, fastKeyProducts.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: widget.isLoading
          ? ShimmerEffect.rectangular(
        height: widget.isHorizontal ? 100 : 800, // Adjust height dynamically
      )
          : widget.isHorizontal
          ? _buildHorizontalList()
          : _buildVerticalList(),
    );
  }

  Widget _buildImage(String imagePath) { // Build #1.0.11 :  load image
    if (imagePath.startsWith('assets/')) {
      return SvgPicture.asset(
        imagePath,
        height: 40,
        width: 40,
        placeholderBuilder: (context) => Icon(Icons.image, size: 40),
      );
    } else {
      return Image.file(
        File(imagePath),
        height: 40,
        width: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image, size: 40);
        },
      );
    }
  }

  Widget _buildHorizontalList() {
    var size = MediaQuery.of(context).size; // Get screen size
    return GestureDetector(
      onTap: () {
        setState(() {
          _editingIndex = null; // Build #1.0.7: Dismiss edit mode on tap outside
        });
      },
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 1000),
            transitionBuilder: (widget, animation) {
              return FadeTransition(opacity: animation, child: widget);
            },
            child: _showLeftArrow && _doesContentOverflow()
                ? _buildScrollButton(Icons.arrow_back_ios, () {
              _scrollController.animateTo(
                _scrollController.offset - size.width,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }) : SizedBox.shrink(),
          ),
          Expanded(
            child: SizedBox(
              height: 110,
              child: ReorderableListView(
                scrollController: _scrollController,
                scrollDirection: Axis.horizontal,
                onReorderStart: (index) {
                  if (kDebugMode) {
                    print("##### onReorderStart $index");
                  }
                },
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;

                  setState(() {
                    final item = fastKeyProducts.removeAt(oldIndex);
                    fastKeyProducts.insert(newIndex, item);

                    // Keep edit mode after reordering
                    _editingIndex = newIndex;

                    if (_selectedIndex != null) {
                      if (_selectedIndex == oldIndex) {
                        _selectedIndex = newIndex;
                      } else if (oldIndex < _selectedIndex! && newIndex >= _selectedIndex!) {
                        _selectedIndex = _selectedIndex! - 1;
                      } else if (oldIndex > _selectedIndex! && newIndex <= _selectedIndex!) {
                        _selectedIndex = _selectedIndex! + 1;
                      }
                    }
                  });
                },
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return Material(
                    elevation: 0,
                    color: Colors.transparent,
                    child: child,
                  );
                },
                children: List.generate(fastKeyProducts.length, (index) {
                  final product = fastKeyProducts[index];
                  bool isSelected = _selectedIndex == index;
                  bool showEditButton = _editingIndex == index;

                  return GestureDetector(
                    key: ValueKey(product.name),
                    onTap: () async {
                      setState(() {
                        if (_editingIndex == index) {
                          _editingIndex = null;
                        } else if (_selectedIndex == index) {
                          return;
                        } else {
                          _selectedIndex = index;
                          _editingIndex = null;
                        }
                      });
                      // Save the selected tab ID
                      await fastKeyHelper.saveActiveFastKeyTab(product.id);
                      widget.fastKeyTabIdNotifier.value = product.id; // Build #1.0.12: fixed fast key tab changes grid items will re load
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: AnimatedContainer(
                        width: 90, // Fixed width for each item
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: showEditButton ? Colors.blueAccent : Colors.black12,
                            width: showEditButton ? 2 : 1,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 0,
                              right: -6,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: showEditButton ? 1.0 : 0.0,
                                child: GestureDetector(
                                  onTap: () => _showCategoryDialog(index: index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, size: 14, color: Colors.blueAccent),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildImage(product.imageAsset),
                                const SizedBox(height: 8),
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                Text(
                                  product.itemCount,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 1000),
            transitionBuilder: (widget, animation) {
              return FadeTransition(opacity: animation, child: widget);
            },
            child: _showLeftArrow && _doesContentOverflow()
                ? _buildScrollButton(Icons.arrow_forward_ios, () {
              _scrollController.animateTo(
                _scrollController.offset + size.width,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }) : SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
          _buildScrollButton(Icons.add, () {
            _showCategoryDialog();
          }),
        ],
      ),
    );
  }

  Widget _buildVerticalList() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _editingIndex = null; // Dismiss edit mode on tap outside
        });
      },
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.35,
            child: ReorderableListView(
              scrollDirection: Axis.vertical,
              onReorderStart: (index) {
                if (kDebugMode) {
                  print("##### onReorderStart $index");
                }
              },
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;

                setState(() {
                  final item = fastKeyProducts.removeAt(oldIndex);
                  fastKeyProducts.insert(newIndex, item);

                  // Keep edit mode after reordering
                  _editingIndex = newIndex;

                  if (_selectedIndex != null) {
                    if (_selectedIndex == oldIndex) {
                      _selectedIndex = newIndex;
                    } else if (oldIndex < _selectedIndex! && newIndex >= _selectedIndex!) {
                      _selectedIndex = _selectedIndex! - 1;
                    } else if (oldIndex > _selectedIndex! && newIndex <= _selectedIndex!) {
                      _selectedIndex = _selectedIndex! + 1;
                    }
                  }
                });
              },
              proxyDecorator: (Widget child, int index, Animation<double> animation) {
                return Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: child,
                );
              },
              children: List.generate(fastKeyProducts.length, (index) {
                final product = fastKeyProducts[index];
                bool isSelected = _selectedIndex == index;
                bool showEditButton = _editingIndex == index;

                return GestureDetector(
                  key: ValueKey(product.name),
                  onTap: () async {
                    setState(() {
                      if (_editingIndex == index) {
                        // If item is in edit mode, just dismiss edit mode
                        _editingIndex = null;
                      } else if (_selectedIndex == index) {
                        // If item is already selected, do nothing (keep selection)
                        return;
                      } else {
                        // If item is not selected, select it
                        _selectedIndex = index;
                        _editingIndex = null;
                      }
                    });
                    // Save the selected tab ID
                    await fastKeyHelper.saveActiveFastKeyTab(product.id);
                    widget.fastKeyTabIdNotifier.value = product.id; // Notify NestedGridWidget // Build #1.0.12: fixed fast key tab changes grid items will re load
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                    child: AnimatedContainer(
                      width: 120, // Fixed width for each item
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showEditButton ? Colors.blueAccent : Colors.black12,
                          width: showEditButton ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: widget.isHorizontal ? 0 : 0,
                            right: widget.isHorizontal ? -6 : 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: showEditButton ? 1.0 : 0.0,
                              child: GestureDetector(
                                onTap: () => _showCategoryDialog(index: index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 14, color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _buildImage(product.imageAsset),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    product.itemCount,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.redAccent),
              onPressed: () {
                _showCategoryDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build scroll buttons (left and right)
  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return Container(
      height: 110, // Set height of scroll button
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.redAccent),
        onPressed: onPressed, // Trigger scroll action when pressed
      ),
    );
  }

  void _showCategoryDialog({int? index}) {
    bool isEditing = index != null;
    TextEditingController nameController =
    TextEditingController(text: isEditing ? fastKeyProducts[index].name : '');
    String imagePath = isEditing ? fastKeyProducts[index].imageAsset : 'assets/svg/password_placeholder.svg'; // Default image path
    bool showError = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? TextConstants.editCateText : TextConstants.addCateText),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            imagePath.isNotEmpty
                                ? (imagePath.startsWith('assets/')
                                ? SvgPicture.asset(
                              imagePath,
                              height: 80,
                              width: 80,
                              placeholderBuilder: (context) => Icon(Icons.image, size: 40),
                            )
                                : Image.file(
                              File(imagePath),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return SvgPicture.asset(
                                  'assets/password_placeholder.svg', // Fallback to default SVG
                                  height: 80,
                                  width: 80,
                                );
                              },
                            ))
                                : SvgPicture.asset(
                              'assets/password_placeholder.svg', // Default image
                              height: 80,
                              width: 80,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  final pickedFile = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedFile != null) {
                                    setStateDialog(() {
                                      imagePath = pickedFile.path;
                                    });
                                  }
                                },
                                child: const Icon(Icons.edit,
                                    size: 18, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isEditing && showError && imagePath.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            TextConstants.imgRequiredText,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: TextConstants.nameText,
                          errorText: (!isEditing && showError && nameController.text.isEmpty)
                              ? TextConstants.nameReqText
                              : null,
                          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                          suffixIcon: isEditing
                              ? const Icon(Icons.edit, size: 18, color: Colors.red)
                              : null,
                        ),
                      ),
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${TextConstants.itemCountText} ${fastKeyProducts[index].itemCount}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(TextConstants.cancelText),
                ),
                TextButton(
                  onPressed: () async {
                    if (!isEditing && nameController.text.isEmpty) {
                      setStateDialog(() {
                        showError = true;
                      });
                      return;
                    }

                    if (isEditing) {
                      // Update existing FastKey tab in the database
                      final updatedTab = {
                        AppDBConst.fastKeyTabTitle: nameController.text,
                        AppDBConst.fastKeyTabImage: imagePath,
                      };
                      await fastKeyHelper.updateFastKeyTab(fastKeyProducts[index].id, updatedTab);

                      // Update the local list
                      setState(() {
                        _editingIndex = null;
                        fastKeyProducts[index].name = nameController.text;
                        fastKeyProducts[index].imageAsset = imagePath;
                      });
                    } else {
                      // Add new FastKey tab to the database
                      await _addFastKeyTab(nameController.text, imagePath);
                    }

                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: const Text(TextConstants.saveText),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () => _showDeleteConfirmationDialog(index!),
                    child: const Text(TextConstants.deleteText, style: TextStyle(color: Colors.red)),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  //Build #1.0.4 🔹 New Function: Show Confirmation Before Deleting
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(TextConstants.deleteTabText),
          content: const Text(TextConstants.deleteConfirmText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text(TextConstants.noText),
            ),
            TextButton(
              onPressed: () async { // Build #1.0.11
                // Store the ID of the currently selected tab
                final selectedTabId = _selectedIndex != null ? fastKeyProducts[_selectedIndex!].id : null;

                // Delete the tab from the database
                await _deleteFastKeyTab(fastKeyProducts[index].id);

                // Reset the editing index
                setState(() {
                  _editingIndex = null;
                });

                // Update the selected index based on the visual order
                if (_selectedIndex != null) {
                  if (_selectedIndex == index) {
                    // If the deleted tab was the selected one, select the next tab
                    if (fastKeyProducts.isNotEmpty) {
                      if (index < fastKeyProducts.length) {
                        _selectedIndex = index; // Select the next tab
                      } else {
                        _selectedIndex = fastKeyProducts.length - 1; // Select the last tab if the deleted tab was the last one
                      }
                    } else {
                      _selectedIndex = null; // No tabs left
                    }
                  } else if (_selectedIndex! > index) {
                    // If the deleted tab was before the selected one, adjust the selected index
                    _selectedIndex = _selectedIndex! - 1;
                  }
                }

                // Save the new selected tab ID
                if (_selectedIndex != null) {
                  await fastKeyHelper.saveActiveFastKeyTab(fastKeyProducts[_selectedIndex!].id);
                  widget.fastKeyTabIdNotifier.value = fastKeyProducts[_selectedIndex!].id; // Notify NestedGridWidget // Build #1.0.12: fixed fast key tab changes grid items will re load
                } else {
                  await fastKeyHelper.saveActiveFastKeyTab(-1); // No tab selected
                  widget.fastKeyTabIdNotifier.value = -1; // Notify NestedGridWidget
                }

                // Close the dialogs
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close edit dialog
              },
              child: const Text(TextConstants.yesText, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
