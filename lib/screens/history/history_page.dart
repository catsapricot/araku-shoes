import 'dart:convert';
import '../rekap/rekap_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../home/home_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() =>
      _HistoryPageState();
}

class _HistoryPageState
    extends State<HistoryPage> {

  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbzE5GT3hHsNkTP7PVlxng79VBCwRiTqi0UolVR3-lSdUR_nah-l_7ZvAR9aKv-N-lBt/exec";

  List orders = [];

  List filteredOrders = [];

  bool isLoading = true;

  String selectedFilter = "Hari Ini";

  final searchController =
      TextEditingController();



  // =====================================
  // INIT
  // =====================================

  @override
  void initState() {

    super.initState();

    fetchOrders();
  }



  // =====================================
  // FETCH
  // =====================================

  Future<void> fetchOrders() async {

    try {

      final response =
          await http.get(

        Uri.parse(
          "$apiUrl?all=true",
        ),
      );

      final data =
          jsonDecode(response.body);

      setState(() {

        orders = data.reversed.toList();

        filteredOrders = orders;

        isLoading = false;
      });

    } catch (e) {

      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }



  // =====================================
  // FILTER SEARCH
  // =====================================

  void filterOrders() {

    String keyword =
        searchController.text
            .toLowerCase();

    setState(() {

      filteredOrders =
          orders.where((item) {

        return item["nama"]
                .toString()
                .toLowerCase()
                .contains(keyword)

            ||

            item["id"]
                .toString()
                .contains(keyword);

      }).toList();
    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            const Color(0xFFF6F7FB),

        leading: const Icon(
          Icons.storefront_outlined,
          color: Color(0xFF5B2DA3),
        ),

        title: const Text(

          "Riwayat Transaksi",

          style: TextStyle(
            color: Color(0xFF5B2DA3),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: const [

          Padding(

            padding: EdgeInsets.only(
              right: 16,
            ),

            child: Icon(
              Icons.cloud_done_outlined,
              color: Color(0xFF5B2DA3),
            ),
          )
        ],
      ),

      body:

          isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : Column(

                  children: [

                    Padding(

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      child: Column(

                        children: [

                          // =====================================
                          // SEARCH
                          // =====================================

                          TextField(

                            controller:
                                searchController,

                            onChanged: (_) {
                              filterOrders();
                            },

                            decoration:
                                InputDecoration(

                              hintText:
                                  "Cari pelanggan atau ID transaksi...",

                              prefixIcon:
                                  const Icon(
                                Icons.search,
                              ),

                              filled: true,

                              fillColor:
                                  Colors.white,

                              border:
                                  OutlineInputBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 16),



                          // =====================================
                          // FILTER
                          // =====================================

                          Row(

                            children: [

                              filterChip(
                                "Hari Ini",
                              ),

                              const SizedBox(
                                  width: 10),

                              filterChip(
                                "Minggu Ini",
                              ),

                              const SizedBox(
                                  width: 10),

                              filterChip(
                                "Custom",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),



                    // =====================================
                    // LIST
                    // =====================================

                    Expanded(

                      child:
                          ListView.builder(

                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        itemCount:
                            filteredOrders.length,

                        itemBuilder:
                            (context, index) {

                          final item =
                              filteredOrders[index];

                          return Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              if (index == 0)

                                Padding(

                                  padding:
                                      const EdgeInsets.only(
                                    bottom: 14,
                                  ),

                                  child: Text(

                                    DateFormat(
                                      "dd MMMM yyyy",
                                      "id_ID",
                                    ).format(
                                      DateTime.now(),
                                    ),

                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,

                                      fontSize: 16,
                                    ),
                                  ),
                                ),



                              // =====================================
                              // CARD
                              // =====================================

                              Container(

                                margin:
                                    const EdgeInsets.only(
                                  bottom: 16,
                                ),

                                padding:
                                    const EdgeInsets.all(
                                  16,
                                ),

                                decoration:
                                    BoxDecoration(

                                  color: Colors.white,

                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                ),

                                child: Column(

                                  children: [

                                    Row(

                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,

                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [

                                        Column(

                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,

                                          children: [

                                            Text(

                                              item["nama"],

                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,

                                                fontSize:
                                                    16,
                                              ),
                                            ),

                                            const SizedBox(
                                                height:
                                                    4),

                                            Text(

                                              "10:45 WIB • ID: TRX-${item["id"]}",

                                              style:
                                                  const TextStyle(
                                                color:
                                                    Colors.grey,

                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ),

                                        Text(

                                          "Rp ${item["total"]}",

                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF0F766E,
                                            ),

                                            fontWeight:
                                                FontWeight.bold,

                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),

                                    const SizedBox(
                                        height: 18),

                                    const Divider(),

                                    const SizedBox(
                                        height: 14),

                                    Row(

                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,

                                      children: [

                                        Expanded(

                                          child: Column(

                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [

                                              const Text(
                                                "Layanan",
                                                style:
                                                    TextStyle(
                                                  color:
                                                      Colors.grey,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      6),

                                              Text(
                                                "${item["layanan"]} (${item["jumlah"]} pasang)",
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(

                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal:
                                                12,

                                            vertical:
                                                6,
                                          ),

                                          decoration:
                                              BoxDecoration(

                                            color:
                                                const Color(
                                              0xFFF3E8FF,
                                            ),

                                            borderRadius:
                                                BorderRadius.circular(
                                              12,
                                            ),
                                          ),

                                          child: Text(

                                            item["metode"],

                                            style:
                                                const TextStyle(
                                              color:
                                                  Color(
                                                0xFF5B2DA3,
                                              ),

                                              fontWeight:
                                                  FontWeight.bold,

                                              fontSize:
                                                  12,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),



                    // =====================================
                    // BOTTOM NAV
                    // =====================================

                    Container(

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 12,
                      ),

                      decoration: const BoxDecoration(

                        color: Colors.white,

                        border: Border(
                          top: BorderSide(
                            color:
                                Color(0xFFE5E7EB),
                          ),
                        ),
                      ),

                      child: Row(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,

                        children: [

                          navItem(
                            Icons.home_outlined,
                            "Home",
                            false,
                          ),

                          navItem(
                            Icons.history,
                            "Riwayat",
                            true,
                          ),

                          navItem(
                            Icons.receipt_long_outlined,
                            "Rekap",
                            false,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
    );
  }



  // =====================================
  // CHIP
  // =====================================

  Widget filterChip(String title) {

    bool selected =
        selectedFilter == title;

    return GestureDetector(

      onTap: () {

        setState(() {
          selectedFilter = title;
        });
      },

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color:
              selected
                  ? const Color(
                      0xFF0F766E,
                    )
                  : Colors.white,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Text(

          title,

          style: TextStyle(

            color:
                selected
                    ? Colors.white
                    : Colors.black,
          ),
        ),
      ),
    );
  }



  // =====================================
  // NAV ITEM
  // =====================================

    Widget navItem(
    IconData icon,
    String title,
    bool active,
  ) {

    return GestureDetector(

      onTap: () {

        // HOME
        if (title == "Home") {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const HomePage(),
            ),
          );
        }

        // REKAP
        else if (title == "Rekap") {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const RekapPage(),
            ),
          );
        }
      },

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            icon,

            color:
                active
                    ? const Color(
                        0xFF5B2DA3,
                      )
                    : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(

            title,

            style: TextStyle(

              color:
                  active
                      ? const Color(
                          0xFF5B2DA3,
                        )
                      : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}