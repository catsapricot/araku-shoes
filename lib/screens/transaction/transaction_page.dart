import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class TransactionPage
    extends StatefulWidget {

  const TransactionPage({
    super.key,
  });

  @override
  State<TransactionPage>
      createState() =>

          _TransactionPageState();
}

class _TransactionPageState
    extends State<TransactionPage> {

  List orders = [];

  List filteredOrders = [];

  bool isLoading = true;

  String selectedStatus =
      "Semua";

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

  Future<void> fetchOrders()
  async {

    setState(() {

      isLoading = true;
    });



    try {

      // =====================================
      // GET DYNAMIC API URL
      // =====================================

      final apiUrl =
          await ApiService
              .getApiUrl();



      final response =
          await http.get(

        Uri.parse(
          "$apiUrl?all=true",
        ),
      );



      final data =
          jsonDecode(
        response.body,
      );



      if (!mounted) return;



      setState(() {

        orders =
            data.reversed
                .toList();

        filteredOrders =
            orders;

        isLoading =
            false;
      });

    } catch (e) {

      if (!mounted) return;



      setState(() {

        isLoading =
            false;
      });

      debugPrint(
        e.toString(),
      );

      ScaffoldMessenger.of(
              context)
          .showSnackBar(

        SnackBar(

          content: Text(

            "Gagal mengambil data: $e",
          ),
        ),
      );
    }
  }




  // =====================================
  // FILTER
  // =====================================

  void filterOrders() {

    String keyword =
        searchController.text
            .toLowerCase();

    setState(() {

      filteredOrders =
          orders.where((item) {

        bool matchSearch =

            item["nama"]
                .toString()
                .toLowerCase()
                .contains(keyword)

            ||

            item["id"]
                .toString()
                .contains(keyword);

        bool matchStatus =

            selectedStatus == "Semua"

            ||

            item["status"] ==
                selectedStatus;

        return
            matchSearch &&
            matchStatus;

      }).toList();
    });
  }



  // =====================================
  // UPDATE STATUS
  // =====================================

  Future<void> updateStatus(

    dynamic id,

    String status,

  ) async {

    try {

      // =====================================
      // GET DYNAMIC API URL
      // =====================================

      final apiUrl =
          await ApiService
              .getApiUrl();



      await http.post(

        Uri.parse(apiUrl),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "action":
              "update",

          "id":
              id,

          "status":
              status,
        }),
      );



      fetchOrders();

    } catch (e) {

      debugPrint(
        e.toString(),
      );

      ScaffoldMessenger.of(
              context)
          .showSnackBar(

        SnackBar(

          content: Text(

            "Gagal update status: $e",
          ),
        ),
      );
    }
  }



  // =====================================
  // STATUS COLOR
  // =====================================

  Color getStatusColor(String status) {

    switch (status) {

      case "Diproses":
        return const Color(0xFF8B5CF6);

      case "Menunggu":
        return const Color(0xFFEAB308);

      case "Diambil":
        return Colors.blue;

      case "Selesai":
        return const Color(0xFF6B7280);

      default:
        return Colors.grey;
    }
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

        leading: IconButton(

          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),

        title: const Text(

          "Sedang Dikerjakan",

          style: TextStyle(
            color: Color(0xFF5B2DA3),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(

        children: [

          Padding(

            padding:
                const EdgeInsets.all(16),

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

                  decoration: InputDecoration(

                    hintText:
                        "Cari pelanggan atau ID transaksi...",

                    prefixIcon:
                        const Icon(Icons.search),

                    filled: true,

                    fillColor: Colors.white,

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

                const SizedBox(height: 16),



                // =====================================
                // FILTER
                // =====================================

                Row(

                  children: [

                    filterChip("Semua"),

                    const SizedBox(width: 8),

                    filterChip("Menunggu"),

                    const SizedBox(width: 8),

                    filterChip("Diproses"),

                    const SizedBox(width: 8),

                    filterChip("Selesai"),
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

                isLoading

                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )

                    : RefreshIndicator(

                        onRefresh:
                            fetchOrders,

                        child: ListView.builder(

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

                            return Container(

                              margin:
                                  const EdgeInsets.only(
                                bottom: 16,
                              ),

                              padding:
                                  const EdgeInsets.all(
                                16,
                              ),

                              decoration: BoxDecoration(

                                color: Colors.white,

                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),

                                boxShadow: [

                                  BoxShadow(

                                    color:
                                        Colors.black
                                            .withOpacity(
                                      0.03,
                                    ),

                                    blurRadius: 10,
                                  )
                                ],
                              ),

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Row(

                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,

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
                                                  FontWeight
                                                      .bold,

                                              fontSize:
                                                  16,
                                            ),
                                          ),

                                          const SizedBox(
                                              height:
                                                  4),

                                          Text(

                                            "INV-${item["id"]}",

                                            style:
                                                const TextStyle(
                                              color:
                                                  Colors.grey,
                                            ),
                                          ),
                                        ],
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
                                              getStatusColor(
                                            item[
                                                "status"],
                                          ),

                                          borderRadius:
                                              BorderRadius.circular(
                                            20,
                                          ),
                                        ),

                                        child: Text(

                                          item[
                                              "status"],

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors
                                                    .white,

                                            fontSize:
                                                12,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(
                                      height: 18),

                                  Text(
                                    "Layanan",
                                    style:
                                        TextStyle(
                                      color: Colors
                                          .grey
                                          .shade700,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 4),

                                  Text(
                                    "${item["layanan"]} (${item["jumlah"]} pasang)",
                                  ),

                                  const SizedBox(
                                      height: 20),

                                  Align(

                                    alignment:
                                        Alignment
                                            .centerRight,

                                    child:
                                        ElevatedButton(

                                      onPressed: () {

                                        showModalBottomSheet(

                                          context: context,

                                          shape: const RoundedRectangleBorder(

                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                          ),

                                          builder: (context) {

                                            return Container(

                                              padding: const EdgeInsets.all(20),

                                              child: Column(

                                                mainAxisSize: MainAxisSize.min,

                                                children: [

                                                  const Text(

                                                    "Update Status",

                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 20),

                                                  statusButton(
                                                    item["id"],
                                                    "Menunggu",
                                                    Colors.orange,
                                                  ),

                                                  const SizedBox(height: 12),

                                                  statusButton(
                                                    item["id"],
                                                    "Diproses",
                                                    Colors.purple,
                                                  ),

                                                  const SizedBox(height: 12),

                                                  statusButton(
                                                    item["id"],
                                                    "Selesai",
                                                    Colors.green,
                                                  ),

                                                  const SizedBox(height: 12),

                                                  statusButton(
                                                    item["id"],
                                                    "Diambil",
                                                    Colors.blue,
                                                  ),

                                                  const SizedBox(height: 20),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },

                                      style:
                                          ElevatedButton.styleFrom(

                                        backgroundColor:
                                            item["status"] ==
                                                    "Selesai"

                                                ? Colors.red

                                                : const Color(
                                                    0xFF0F766E,
                                                  ),

                                        shape:
                                            RoundedRectangleBorder(

                                          borderRadius:
                                              BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      child: Text(

                                        item["status"] ==
                                                "Selesai"

                                            ? "Hapus Status"

                                            : "Update Status",

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors
                                                  .white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          )
        ],
      ),
    );
  }



  // =====================================
  // CHIP
  // =====================================

  Widget statusButton(
    dynamic id,
    String status,
    Color color,
  ) {

    return SizedBox(

      width: double.infinity,
      height: 52,

      child: ElevatedButton(

        onPressed: () async {

          Navigator.pop(context);

          await updateStatus(
            id,
            status,
          );
        },

        style:
            ElevatedButton.styleFrom(

          backgroundColor: color,

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(14),
          ),
        ),

        child: Text(

          status,

          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget filterChip(String status) {

    bool selected =
        selectedStatus == status;

    return GestureDetector(

      onTap: () {

        setState(() {
          selectedStatus = status;
        });

        filterOrders();
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

          border: Border.all(
            color:
                selected
                    ? const Color(
                        0xFF0F766E,
                      )
                    : Colors.grey.shade300,
          ),
        ),

        child: Text(

          status,

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
}