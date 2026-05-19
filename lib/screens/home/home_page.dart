import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../services/api_service.dart';

import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/dashboard_order_card.dart';

import '../history/history_page.dart';
import '../input_order/input_order_page.dart';
import '../rekap/rekap_page.dart';
import '../transaction/transaction_page.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  // =====================================
  // CONSTANTS
  // =====================================

  static const Color kPrimary =
      Color(0xFF5B2DA3);

  static const Color kTeal =
      Color(0xFF0F766E);

  static const Color kBackground =
      Color(0xFFF6F7FB);



  // =====================================
  // STATE
  // =====================================

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



  // =====================================
  // FETCH DASHBOARD
  // =====================================

  Future<void> getDashboardData()
  async {

    try {

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

      double income = 0;

      int finished = 0;

      for (var order in data) {

        income +=
            double.tryParse(
                  order["total"]
                      .toString(),
                ) ??
                0;

        if (
          order["status"] ==
          "Selesai"
        ) {

          finished++;
        }
      }

      if (!mounted) return;

      setState(() {

        orders =
            data.where((order) {

          return
              order["status"] !=
                      "Selesai" &&
                  order["status"] !=
                      "Diambil";
        }).toList();

        totalIncome =
            income;

        totalOrders =
            data.length;

        totalFinished =
            finished;

        isLoading =
            false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {

        isLoading =
            false;
      });

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
  // CLOUD CONFIG
  // =====================================

  Future<void>
      showApiConfigDialog()
  async {

    final controller =
        TextEditingController();

    await showDialog(

      context: context,

      builder: (ctx) {

        return AlertDialog(

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              22,
            ),
          ),

          title: Row(

            children: [

              Container(

                padding:
                    const EdgeInsets.all(
                  8,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      const Color(
                    0xFFF3E8FF,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),

                child:
                    const Icon(

                  Icons.cloud_outlined,

                  color:
                      kPrimary,

                  size: 20,
                ),
              ),

              const SizedBox(
                  width: 12),

              const Expanded(

                child: Text(

                  "Google Apps Script URL",

                  style: TextStyle(

                    fontSize: 16,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              const SizedBox(
                  height: 10),

              Text(

                "Paste deploy URL backend Google Apps Script.",

                style: TextStyle(

                  color:
                      Colors.grey
                          .shade600,

                  fontSize: 12,
                ),
              ),

              const SizedBox(
                  height: 16),

              TextField(

                controller:
                    controller,

                decoration:
                    InputDecoration(

                  hintText:
                      "Paste deploy URL...",

                  filled: true,

                  fillColor:
                      const Color(
                    0xFFF7F4FA,
                  ),

                  prefixIcon:
                      const Icon(

                    Icons.link,

                    color:
                        kPrimary,
                  ),

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
              )
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  ctx,
                );
              },

              child:
                  const Text(
                "Batal",
              ),
            ),

            ElevatedButton(

              onPressed: () async {

                final url =
                    controller.text
                        .trim();

                if (url.isEmpty)
                  return;

                await ApiService
                    .saveApiUrl(
                  url,
                );

                if (!mounted)
                  return;

                Navigator.pop(
                  ctx,
                );

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(

                  SnackBar(

                    backgroundColor:
                        kPrimary,

                    behavior:
                        SnackBarBehavior
                            .floating,

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    content:
                        const Row(

                      children: [

                        Icon(

                          Icons
                              .check_circle,

                          color:
                              Colors.white,

                          size: 18,
                        ),

                        SizedBox(
                            width:
                                10),

                        Text(
                          "URL berhasil disimpan",
                        )
                      ],
                    ),
                  ),
                );
              },

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    kPrimary,

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              child:
                  const Text(

                "Simpan",

                style: TextStyle(
                  color:
                      Colors.white,
                ),
              ),
            )
          ],
        );
      },
    );
  }



  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          kBackground,



      // =====================================
      // APPBAR
      // =====================================

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            Colors.white,

        title: const Text(

          "Araku Shoes Care",

          style: TextStyle(

            color: Colors.black,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(

            onPressed:
                showApiConfigDialog,

            tooltip:
                "Konfigurasi Backend",

            icon: const Icon(

              Icons.cloud_outlined,

              color:
                  kPrimary,
            ),
          ),

          const SizedBox(
              width: 6),
        ],
      ),



      // =====================================
      // BODY
      // =====================================

      body: SafeArea(

        child: isLoading

            ? const Center(

                child:
                    CircularProgressIndicator(),
              )

            : RefreshIndicator(

                onRefresh:
                    getDashboardData,

                child:
                    SingleChildScrollView(

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      const DashboardHeader(),

                      const SizedBox(
                          height: 28),



                      // =====================================
                      // GREETING
                      // =====================================

                      const Text(

                        "Halo, Admin 👋",

                        style: TextStyle(

                          fontSize: 30,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                          height: 6),

                      Text(

                        DateFormat(

                          'EEEE, d MMMM yyyy',

                          'id_ID',
                        ).format(
                          DateTime.now(),
                        ),

                        style:
                            const TextStyle(

                          color:
                              Colors.grey,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(
                          height: 24),



                      // =====================================
                      // PEMASUKAN
                      // =====================================

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          20,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),
                        ),

                        child: Row(

                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,

                          children: [

                            Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                const Text(

                                  "Total Pemasukan",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.grey,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        10),

                                Text(

                                  NumberFormat.currency(

                                    locale:
                                        'id_ID',

                                    symbol:
                                        'Rp ',

                                    decimalDigits:
                                        0,
                                  ).format(
                                    totalIncome,
                                  ),

                                  style:
                                      const TextStyle(

                                    fontSize:
                                        30,

                                    fontWeight:
                                        FontWeight.bold,

                                    color:
                                        kTeal,
                                  ),
                                )
                              ],
                            ),

                            Container(

                              width: 72,

                              height: 72,

                              decoration:
                                  BoxDecoration(

                                color:
                                    kTeal
                                        .withOpacity(
                                  0.1,
                                ),

                                shape:
                                    BoxShape.circle,
                              ),

                              child:
                                  const Icon(

                                Icons
                                    .payments_outlined,

                                size:
                                    34,

                                color:
                                    kTeal,
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: 16),



                      // =====================================
                      // STATS
                      // =====================================

                      Row(

                        children: [

                          Expanded(

                            child:
                                buildStatCard(

                              icon:
                                  Icons.receipt_long,

                              title:
                                  "Transaksi",

                              value:
                                  totalOrders
                                      .toString(),

                              color:
                                  Colors.black87,
                            ),
                          ),

                          const SizedBox(
                              width:
                                  12),

                          Expanded(

                            child:
                                buildStatCard(

                              icon:
                                  Icons.check_circle,

                              title:
                                  "Selesai",

                              value:
                                  totalFinished
                                      .toString(),

                              color:
                                  kTeal,
                            ),
                          )
                        ],
                      ),

                      const SizedBox(
                          height: 24),



                      // =====================================
                      // NEW TRANSACTION
                      // =====================================

                      SizedBox(

                        width:
                            double.infinity,

                        height:
                            58,

                        child:
                            ElevatedButton(

                          onPressed:
                              () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:
                                    (_) =>
                                        const InputOrderPage(),
                              ),
                            );
                          },

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                kTeal,

                            elevation:
                                0,

                            shape:
                                RoundedRectangleBorder(

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),

                          child:
                              const Row(

                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [

                              Icon(

                                Icons
                                    .add_circle_outline,

                                color:
                                    Colors.white,
                              ),

                              SizedBox(
                                  width:
                                      8),

                              Text(

                                "Transaksi Baru",

                                style:
                                    TextStyle(

                                  fontSize:
                                      18,

                                  fontWeight:
                                      FontWeight.bold,

                                  color:
                                      Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 30),



                      // =====================================
                      // HEADER ORDER
                      // =====================================

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          const Text(

                            "Sedang Dikerjakan",

                            style:
                                TextStyle(

                              fontSize:
                                  24,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          TextButton(

                            onPressed:
                                () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder:
                                      (_) =>
                                          const TransactionPage(),
                                ),
                              );
                            },

                            child:
                                const Text(

                              "Lihat Semua",

                              style:
                                  TextStyle(

                                color:
                                    kTeal,

                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(
                          height: 14),



                      // =====================================
                      // ORDER LIST
                      // =====================================

                      ...orders
                          .take(5)
                          .map((order) {

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

                      const SizedBox(
                          height:
                              100),
                    ],
                  ),
                ),
              ),
      ),



      // =====================================
      // BOTTOM NAVIGATION
      // =====================================

      bottomNavigationBar:
          Container(

        height: 80,

        decoration:
            const BoxDecoration(

          color:
              Colors.white,

          borderRadius:
              BorderRadius.only(

            topLeft:
                Radius.circular(
              24,
            ),

            topRight:
                Radius.circular(
              24,
            ),
          ),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black12,

              blurRadius:
                  10,
            )
          ],
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment
                  .spaceAround,

          children: [

            buildNavItem(

              icon:
                  Icons.home_outlined,

              label:
                  "Home",

              active:
                  true,
            ),

            buildNavItem(

              icon:
                  Icons.history,

              label:
                  "Riwayat",

              onTap:
                  () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:
                        (_) =>
                            const HistoryPage(),
                  ),
                );
              },
            ),

            buildNavItem(

              icon:
                  Icons.receipt_long_outlined,

              label:
                  "Rekap",

              onTap:
                  () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:
                        (_) =>
                            const RekapPage(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }



  // =====================================
  // STAT CARD
  // =====================================

  Widget buildStatCard({

    required IconData icon,

    required String title,

    required String value,

    required Color color,
  }) {

    return Container(

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
              height: 14),

          Text(

            value,

            style:
                TextStyle(

              fontSize: 32,

              fontWeight:
                  FontWeight.bold,

              color: color,
            ),
          ),

          const SizedBox(
              height: 4),

          Text(
            title,
          )
        ],
      ),
    );
  }



  // =====================================
  // NAVIGATION ITEM
  // =====================================

  Widget buildNavItem({

    required IconData icon,

    required String label,

    bool active = false,

    VoidCallback? onTap,
  }) {

    final color =

        active

            ? const Color(
                0xFF7C3AED,
              )

            : Colors.black54;

    return GestureDetector(

      onTap: onTap,

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
              height: 4),

          Text(

            label,

            style: TextStyle(

              color: color,

              fontWeight:

                  active

                      ? FontWeight.bold

                      : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}
