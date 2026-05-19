import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_style.dart';
import '../../widgets/menu_card.dart';
import '../input_order/input_order_page.dart';
import '../data_order/data_order_page.dart';
import '../dashboard/dashboard_page.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/dashboard_stats.dart';
import '../../widgets/dashboard/dashboard_order_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../transaction/transaction_page.dart';
import '../history/history_page.dart';
import '../rekap/rekap_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbzE5GT3hHsNkTP7PVlxng79VBCwRiTqi0UolVR3-lSdUR_nah-l_7ZvAR9aKv-N-lBt/exec";

  List orders = [];

  bool isLoading = true;

  double totalIncome = 0;

  int totalOrders = 0;

  int totalFinished = 0;

  @override
  void initState() {
    super.initState();
    getDashboardData();
  }

  Future<void> getDashboardData() async {

    try {

      final response = await http.get(
        Uri.parse("$apiUrl?all=true"),
      );

      final data = jsonDecode(response.body);

      double income = 0;
      int finished = 0;

      for (var order in data) {

        income +=
            double.tryParse(order["total"].toString()) ?? 0;

        if (order["status"] == "Selesai") {
          finished++;
        }
      }

      setState(() {

        orders = data.where((order) {

          return order["status"] != "Selesai"

              &&

              order["status"] != "Diambil";

        }).toList();

        totalIncome = income;

        totalOrders = data.length;

        totalFinished = finished;

        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF6F7FB),

      body: SafeArea(

        child: isLoading

            ? const Center(
                child: CircularProgressIndicator(),
              )

            : RefreshIndicator(

                onRefresh: getDashboardData,

                child: SingleChildScrollView(

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding: const EdgeInsets.all(20),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // =====================================
                      // HEADER
                      // =====================================

                      const DashboardHeader(),

                      const SizedBox(height: 30),



                      // =====================================
                      // GREETING
                      // =====================================

                      const Text(
                        "Halo, Admin",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                          'id_ID',
                        ).format(DateTime.now()),

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),



                      // =====================================
                      // INCOME CARD
                      // =====================================

                      Container(

                        width: double.infinity,

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(

                          color: const Color(0xFFF7F8F8),

                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: Row(

                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,

                          children: [

                            Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Row(
                                  children: [

                                    const Icon(
                                      Icons.attach_money,
                                      size: 18,
                                      color: Colors.grey,
                                    ),

                                    const SizedBox(width: 4),

                                    Text(
                                      "Pemasukan",
                                      style: TextStyle(
                                        color:
                                            Colors.grey[700],
                                      ),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  "Rp ${NumberFormat('#,###').format(totalIncome)}",

                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Color(0xFF0F766E),
                                  ),
                                )
                              ],
                            ),

                            Container(
                              width: 70,
                              height: 70,

                              decoration: BoxDecoration(
                                color:
                                    Colors.grey.withOpacity(
                                  0.1,
                                ),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.payments_outlined,
                                size: 34,
                                color: Color(0xFF0F766E),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),



                      // =====================================
                      // MINI STATS
                      // =====================================

                      Row(

                        children: [

                          Expanded(

                            child: Container(

                              padding:
                                  const EdgeInsets.all(18),

                              decoration: BoxDecoration(

                                color:
                                    const Color(0xFFF7F8F8),

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Row(
                                    children: [

                                      const Icon(
                                        Icons.receipt_long,
                                        size: 18,
                                      ),

                                      const SizedBox(
                                          width: 4),

                                      Text(
                                        "Transaksi",
                                        style: TextStyle(
                                          color:
                                              Colors.grey[
                                                  700],
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  Row(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,

                                    children: [

                                      Text(
                                        totalOrders
                                            .toString(),

                                        style:
                                            const TextStyle(
                                          fontSize: 36,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 6),

                                      const Padding(
                                        padding:
                                            EdgeInsets.only(
                                          bottom: 8,
                                        ),

                                        child: Text(
                                          "order",
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Container(

                              padding:
                                  const EdgeInsets.all(18),

                              decoration: BoxDecoration(

                                color:
                                    const Color(0xFFEAF7F6),

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),

                              child: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  const Row(
                                    children: [

                                      Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color:
                                            Color(0xFF0F766E),
                                      ),

                                      SizedBox(width: 4),

                                      Text(
                                        "Selesai",
                                        style: TextStyle(
                                          color: Color(
                                              0xFF0F766E),
                                        ),
                                      )
                                    ],
                                  ),

                                  const SizedBox(height: 14),

                                  Row(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,

                                    children: [

                                      Text(
                                        totalFinished
                                            .toString(),

                                        style:
                                            const TextStyle(
                                          fontSize: 36,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color: Color(
                                              0xFF0F766E),
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 6),

                                      const Padding(
                                        padding:
                                            EdgeInsets.only(
                                          bottom: 8,
                                        ),

                                        child: Text(
                                          "selesai",
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),



                      // =====================================
                      // BUTTON
                      // =====================================

                      SizedBox(

                        width: double.infinity,
                        height: 58,

                        child: ElevatedButton(

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (context) =>
                                    const InputOrderPage(),
                              ),
                            );
                          },

                          style: ElevatedButton.styleFrom(

                            backgroundColor:
                                const Color(0xFF0F766E),

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),

                          child: const Row(

                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),

                              SizedBox(width: 8),

                              Text(
                                "Transaksi Baru",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),



                      // =====================================
                      // TITLE
                      // =====================================

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Sedang Dikerjakan",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          TextButton(

                            onPressed: () {
                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      const TransactionPage(),
                                ),
                              );
                            },

                            child: const Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 12),



                      // =====================================
                      // REALTIME ORDER LIST
                      // =====================================

                      ...orders.take(5).map((order) {

                        return DashboardOrderCard(

                        invoice:
                            "INV-${order["id"]}",

                        customer:
                            order["nama"],

                        layanan:
                            order["layanan"],

                        status:
                            order["status"],
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      ),



      // =====================================
      // BOTTOM NAVBAR
      // =====================================

      bottomNavigationBar: Container(

        height: 80,

        decoration: const BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [

            Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: const [

                Icon(
                  Icons.home_outlined,
                  color: Color(0xFF7C3AED),
                ),

                SizedBox(height: 4),

                Text(
                  "Home",
                  style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),

            GestureDetector(

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const HistoryPage(),
                  ),
                );
              },

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [

                  Icon(
                    Icons.history,
                    color: Colors.black54,
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Riwayat",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ),

            GestureDetector(

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const RekapPage(),
                  ),
                );
              },

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: const [

                  Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.black54,
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Rekap",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}