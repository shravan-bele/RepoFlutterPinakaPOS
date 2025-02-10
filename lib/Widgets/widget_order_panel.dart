import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


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
  List<String> tabs = ["Tab #1", "Tab #2"];
  TabController? _tabController; // Make it nullable to handle reassignments
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
      tabs.add("Tab #${tabs.length + 1}");
      _initializeTabController();
      _tabController!.index = tabs.length - 1; // Set newly added tab as selected
    });
    _scrollToSelectedTab();
  }

  void removeTab(int index) {
    if (tabs.length > 1) {
      setState(() {
        tabs.removeAt(index);
        _initializeTabController();
      });
    }
  }

  void _scrollToSelectedTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void scrollTabs(double offset) {
    _scrollController.animateTo(
      _scrollController.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => scrollTabs(-100),
                    child: const Icon(Icons.arrow_left, size: 42, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  Text("${tabs.length}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => scrollTabs(100),
                    child: const Icon(Icons.arrow_right, size: 42, color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: addNewTab,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(40, 40),
                    ),
                    child: const Text("+", style: TextStyle(color: Colors.black87, fontSize: 16)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: ButtonsTabBar(
                      controller: _tabController, // Attach the TabController
                      labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(color: Colors.black),
                      backgroundColor: Colors.white,
                      unselectedBackgroundColor: Colors.grey.shade400,
                      borderWidth: 0,
                      radius: 10,
                      height: 60,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      onTap: (index) {
                        setState(() {
                          _tabController!.index = index;
                          if (kDebugMode) {
                            print("#### Selected Tab : $index");
                          }
                        });
                      },
                      tabs: List.generate(tabs.length, (index) {
                        return Tab(
                          child: SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tabs[index],
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                if (tabs.length > 1)
                                  GestureDetector(
                                    onTap: () => removeTab(index),
                                    child: const Icon(Icons.close, size: 16, color: Colors.red),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(child: buildCurrentOrder()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Current Order UI
  Widget buildCurrentOrder() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Current Order ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        TextSpan(
                          text: "12(2)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "#57752",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.formattedDate,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Text(widget.formattedTime, style: const TextStyle(fontSize: 12, color: Colors.black38)),
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
          child: ListView.builder(
            itemCount: widget.quantities.length,
            itemBuilder: (context, index) {
              return Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,  // Align children at the top
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bud Light", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text("\$0.99", style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,  // Align text to the top
                          children: [
                            Text(
                              "\$${(widget.quantities[index] * 0.99).toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align left and right
                      children: [
                        // Delete Button (Left Side)
                        Container(
                          width: 30, // Ensuring uniform size
                          height: 30, // Same height as other buttons
                          // decoration: BoxDecoration(
                          //   border: Border.all(color: Colors.red),
                          //   borderRadius: BorderRadius.circular(8),
                          // ),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            iconSize: 20,
                            padding: EdgeInsets.zero, // Remove extra padding
                            onPressed: () {
                              print("Delete button tapped at index $index");
                            },
                          ),
                        ),
                        // Row for (-), count, (+)
                        Row(
                          children: [
                            // Remove (-) Button
                            Container(
                              width: 30, // Ensuring uniform size
                              height: 30, // Same height as count box
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.remove, color: Colors.black),
                                iconSize: 20,
                                padding: EdgeInsets.zero, // Remove extra padding
                                onPressed: () {
                                  setState(() {
                                    if (widget.quantities[index] > 1) {
                                      widget.quantities[index]--;
                                    }
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Count Box
                            Container(
                              width: 30, // Ensuring uniform size
                              height: 30, // Same height as buttons
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${widget.quantities[index]}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add (+) Button
                            Container(
                              width: 30, // Ensuring uniform size
                              height: 30, // Same height as count box
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.black),
                                iconSize: 20,
                                padding: EdgeInsets.zero, // Remove extra padding
                                onPressed: () {
                                  setState(() {
                                    widget.quantities[index]++;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
}



