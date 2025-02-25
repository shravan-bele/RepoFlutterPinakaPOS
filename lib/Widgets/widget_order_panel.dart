import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinaka_pos/Widgets/widget_custom_num_pad.dart';

class RightOrderPanel extends StatefulWidget {
  final String formattedDate;
  final String formattedTime;
  final List<int> quantities;

  const RightOrderPanel({
    required this.formattedDate,
    required this.formattedTime,
    required this.quantities,
    Key? key,
  }) : super(key: key);

  @override
  _RightOrderPanelState createState() => _RightOrderPanelState();
}

class _RightOrderPanelState extends State<RightOrderPanel> with TickerProviderStateMixin {
  List<Map<String, String>> tabs = [
    {"title": "#57751", "subtitle": "Tab 1"},
    {"title": "#57752", "subtitle": "Tab 2"}
  ];

  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  void _initializeTabController() {
    _tabController?.dispose(); // Dispose the old one safely
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController!.addListener(() {
      if (mounted) {
        setState(() {}); // Update the state when tab changes
      }
    });
  }

  void addNewTab() {
    setState(() {
      tabs.add({"title": "#${tabs.length + 57751}", "subtitle": "Tab ${tabs.length + 1}"});
      _initializeTabController();
      _tabController!.index = tabs.length - 1;
    });
    _scrollToSelectedTab();
  }

  void _scrollToSelectedTab() { //Build #1.0.4
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void removeTab(int index) {
    if (tabs.length > 1) {
      int newIndex = _tabController!.index;
      setState(() {
        tabs.removeAt(index);
        _initializeTabController();
        if (newIndex >= tabs.length) {
          newIndex = tabs.length - 1;
        }
        _tabController!.index = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.32,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(top: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Row(
                        children: List.generate(tabs.length, (index) { //Build #1.0.4 : removed re-order for tabs
                          final bool isSelected = _tabController!.index == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tabController!.index = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tabs[index]["title"]!,
                                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          tabs[index]["subtitle"]!,
                                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 40),
                                    if (tabs.length > 1)
                                      GestureDetector(
                                        onTap: () => removeTab(index),
                                        child: const Icon(Icons.close, size: 18, color: Colors.red),
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
                  ElevatedButton(
                    onPressed: addNewTab,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      minimumSize: const Size(50, 56),
                    ),
                    child: const Text("+", style: TextStyle(color: Colors.black87, fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(child: buildCurrentOrder()),
          ],
        ),
      ),
    );
  }
// Current Order UI
  Widget buildCurrentOrder() {
    if (kDebugMode) {
      print("Building Current Order Widget");
    } // Debug print
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.formattedDate,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(width: 8),
                  Text(widget.formattedTime, style: const TextStyle(fontSize: 14, color: Colors.black38)),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: DottedLine(
            dashLength: 4,
            dashGapLength: 4,
            lineThickness: 1,
            dashColor: Colors.black,
          ),
        ),
        Expanded(
          child: ReorderableListView.builder( //Build #1.0.4: re-order for list
            onReorder: (oldIndex, newIndex) {
              if (kDebugMode) {
                print("Reordering item from $oldIndex to $newIndex");
              } // Debug print
              if (oldIndex < newIndex) newIndex -= 1;

              setState(() {
                final movedQuantity = widget.quantities.removeAt(oldIndex);
                widget.quantities.insert(newIndex, movedQuantity);
              });
            },
            itemCount: widget.quantities.length,
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return Material(
                color: Colors.transparent, // Removes white background
                child: child,
              );
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                key: ValueKey(index),
                borderRadius: BorderRadius.circular(20),
                child: SizedBox( // Ensuring Slidable matches the item height
                  height: 90, // Adjust to match your item height
                  child: Slidable( //Build #1.0.2 : added code for delete the items in list
                    key: ValueKey(index),
                    closeOnScroll: true,
                    direction: Axis.horizontal,
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        CustomSlidableAction(
                          onPressed: (context) {
                            if (kDebugMode) {
                              print("Deleting item at index $index");
                            } // Debug print
                            setState(() {
                              widget.quantities.removeAt(index);
                            });
                          },
                          backgroundColor: Colors.transparent, // No background color
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, color: Colors.red), // Ensures red tint
                              const SizedBox(height: 4),
                              const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (kDebugMode) {
                          print("Item tapped: Bud Light Test");
                        } // Debug print
                        showNumPadDialog(context, "Bud Light Test", (selectedQuantity) {
                          if (kDebugMode) {
                            print("Selected Quantity: $selectedQuantity");
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SvgPicture.asset(
                                'assets/svg/password_placeholder.svg',
                                height: 30,
                                width: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bud Light Length was too long for test".length > 15
                                        ? '${"Bud Light Length was too long for test".substring(0, 15)}...'
                                        : "Bud Light",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const Text("6 * \$0.99", style: TextStyle(color: Colors.black54)),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "\$${(widget.quantities[index] * 0.99).toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          // decoration: BoxDecoration(
          //   color: Colors.grey.shade200,
          //   borderRadius: BorderRadius.circular(16),
          // ),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // EBT Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,

                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("EBT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                      Text("\$0.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Payouts Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Payouts", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                      Text("\$0.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Subtotal Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Subtotal", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                      Text("\$0.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Tax Container
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Tax", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("\$0.00", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                  child: const Text("Hold Order", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Pay : \$${(widget.quantities.fold(0.0, (double sum, qty) => sum + qty * 0.99)).toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// //Build #1.0.2 : Added showNumPadDialog if user tap on order layout list item
  void showNumPadDialog(BuildContext context, String itemName, Function(int) onQuantitySelected) {
    TextEditingController controller = TextEditingController();
    int quantity = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateQuantity(int newQuantity) {
              setState(() {
                quantity = newQuantity;
                controller.text = quantity == 0 ? "" : quantity.toString();
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text("Enter Quantity for", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    Text(itemName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),

                    // TextField with + and - buttons
                    Container(
                      width: 500,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400, width: 1.5),
                        color: Colors.grey.shade100,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20), // Match NumPad padding
                      child: Row(
                        children: [
                          // Decrement Button
                          IconButton(
                            icon: Icon(Icons.remove_circle, size: 32, color: Colors.redAccent),
                            onPressed: () {
                              if (quantity > 0) updateQuantity(quantity - 1);
                            },
                          ),

                          // Quantity TextField
                          Expanded(
                            child: TextField(
                              controller: controller,
                              textAlign: TextAlign.center,
                              readOnly: true,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: controller.text.isEmpty ? FontWeight.normal : FontWeight.bold,
                                color: controller.text.isEmpty ? Colors.grey : Colors.black87, // Fix: Color updates correctly
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "00", // Fix: Shows properly when empty
                                hintStyle: TextStyle(fontSize: 28, color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(vertical: 12), // Fix: Consistent padding
                              ),
                            ),
                          ),

                          // Increment Button
                          IconButton(
                            icon: Icon(Icons.add_circle, size: 32, color: Colors.green),
                            onPressed: () {
                              updateQuantity(quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // CustomNumPad with OK button
                    CustomNumPad(
                      onDigitPressed: (digit) {
                        setState(() {
                          int newQty = int.tryParse((controller.text.isEmpty ? "0" : controller.text) + digit) ?? quantity;
                          updateQuantity(newQty);
                        });
                      },
                      onClearPressed: () => updateQuantity(0),
                      onConfirmPressed: () {
                        onQuantitySelected(quantity);
                        Navigator.pop(context);
                      },
                      actionButtonType: ActionButtonType.ok, // OK instead of Delete
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



