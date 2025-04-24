import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Database/order_panel_db_helper.dart';
import '../../Widgets/widget_category_list.dart';
import '../../Widgets/widget_nested_grid_layout.dart';
import '../../Widgets/widget_order_panel.dart';
import '../../Widgets/widget_topbar.dart';
import '../../Widgets/widget_navigation_bar.dart' as custom_widgets;

// Enum for sidebar position
enum SidebarPosition { left, right, bottom }
// Enum for order panel position
enum OrderPanelPosition { left, right }

class FastKeyScreen extends StatefulWidget {
  final int? lastSelectedIndex; //Build #1.0.7: Make it nullable

  const FastKeyScreen({super.key, this.lastSelectedIndex}); // Optional, no default value

  @override
  State<FastKeyScreen> createState() => _FastKeyScreenState();
}

class _FastKeyScreenState extends State<FastKeyScreen> {
  final List<String> items = List.generate(18, (index) => 'Bud Light');
  int _selectedSidebarIndex = 0; //Build #1.0.2 : By default fast key should be selected after login
  DateTime now = DateTime.now();
  List<int> quantities = [1, 1, 1, 1];
  SidebarPosition sidebarPosition = SidebarPosition.left; // Default to bottom sidebar
  OrderPanelPosition orderPanelPosition = OrderPanelPosition.right; // Default to right
  bool isLoading = true; // Add a loading state
  final ValueNotifier<int?> fastKeyTabIdNotifier = ValueNotifier<int?>(null); // Add this
  final OrderHelper orderHelper = OrderHelper();

  @override
  void initState() {
    super.initState();
    _selectedSidebarIndex = widget.lastSelectedIndex ?? 0; // Build #1.0.7: Restore previous selection

    // Simulate a loading delay
    Future.delayed(const Duration(seconds: 3), () {
      if(mounted) {
        setState(() {
          isLoading = false; // Set loading to false after 3 seconds
        });
      }
    });
  }

  void _refreshOrderList() { // Build #1.0.10 - Naveen: This will trigger a rebuild of the RightOrderPanel (Callback)
    setState(() {
      if (kDebugMode) {
        print("###### FastKeyScreen _refreshOrderList");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String formattedDate = DateFormat("EEE, MMM d' ${now.year}'").format(now);
    String formattedTime = DateFormat('hh:mm a').format(now);

    return Scaffold(
      body: Column(
        children: [
          // Top Bar
          TopBar(
            onModeChanged: () {
              setState(() {
                if (sidebarPosition == SidebarPosition.left) {
                  sidebarPosition = SidebarPosition.right;
                } else if (sidebarPosition == SidebarPosition.right) {
                  sidebarPosition = SidebarPosition.bottom;
                } else {
                  sidebarPosition = SidebarPosition.left;
                }
              });
            },
            onProductSelected: (product) { // Build #1.0.13 : Added product search
              // Convert price from String to double safely
              double price;
              try {
                price = double.tryParse(product.price ?? '0.00') ?? 0.00;
              } catch (e) {
                price = 0.00;
              }

              orderHelper.addItemToOrder(
                product.name ?? 'Unknown',
                product.images?.isNotEmpty == true ? product.images!.first : '',
                price, // Now properly converted to double
                1, // quantity
                'SKU${product.name}', // SKU
              );
            },
          ),
          Divider( // Build #1.0.6
            color: Colors.grey,
            thickness: 0.4,
            height: 1,
          ),
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Sidebar (Conditional)
                if (sidebarPosition == SidebarPosition.left)
                  custom_widgets.NavigationBar( //Build #1.0.4 : Updated class name LeftSidebar to NavigationBar
                    selectedSidebarIndex: _selectedSidebarIndex,
                    onSidebarItemSelected: (index) {
                      setState(() {
                        _selectedSidebarIndex = index;
                      });
                    },
                    isVertical: true, // Vertical layout for left sidebar
                  ),

                // Order Panel on the Left (Conditional: Only when sidebar is right or bottom with left order panel)
                if (sidebarPosition == SidebarPosition.right ||
                    (sidebarPosition == SidebarPosition.bottom && orderPanelPosition == OrderPanelPosition.left))
                  RightOrderPanel(
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                    quantities: quantities,
                    refreshOrderList: _refreshOrderList, // Pass the callback
                  ),

                // Main Content (Horizontal Scroll and Grid View)
                Expanded(
                  child: Column(
                    children: [
                      // Add the CategoryScroll widget here
                      CategoryList(isHorizontal: true, isLoading: isLoading, fastKeyTabIdNotifier: fastKeyTabIdNotifier),// Build #1.0.7

                      // Grid Layout
                      ValueListenableBuilder<int?>( // Build #1.0.11 : Added Notifier for update list and counts
                        valueListenable: fastKeyTabIdNotifier,
                        builder: (context, fastKeyTabId, child) {
                          return NestedGridWidget(
                            isHorizontal: true,
                            isLoading: isLoading,
                            onItemAdded: _refreshOrderList,
                            fastKeyTabIdNotifier: fastKeyTabIdNotifier,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Order Panel on the Right (Conditional: Only when sidebar is left or bottom with right order panel)
                if (sidebarPosition != SidebarPosition.right &&
                    !(sidebarPosition == SidebarPosition.bottom && orderPanelPosition == OrderPanelPosition.left))
                  RightOrderPanel(
                    formattedDate: formattedDate,
                    formattedTime: formattedTime,
                    quantities: quantities,
                    refreshOrderList: _refreshOrderList, // Pass the callback
                  ),

                // Right Sidebar (Conditional)
                if (sidebarPosition == SidebarPosition.right)
                  custom_widgets.NavigationBar( //Build #1.0.4 : Updated class name LeftSidebar to NavigationBar
                    selectedSidebarIndex: _selectedSidebarIndex,
                    onSidebarItemSelected: (index) {
                      setState(() {
                        _selectedSidebarIndex = index;
                      });
                    },
                    isVertical: true, // Vertical layout for right sidebar
                  ),
              ],
            ),
          ),

          // Bottom Sidebar (Conditional)
          if (sidebarPosition == SidebarPosition.bottom)
            custom_widgets.NavigationBar( //Build #1.0.4 : Updated class name LeftSidebar to NavigationBar
              selectedSidebarIndex: _selectedSidebarIndex,
              onSidebarItemSelected: (index) {
                setState(() {
                  _selectedSidebarIndex = index;
                });
              },
              isVertical: false, // Horizontal layout for bottom sidebar
            ),
        ],
      ),
    );
  }
}

