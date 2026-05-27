import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../services/api_service.dart';

class RekapPage extends StatefulWidget {

  const RekapPage({super.key});

  @override
  State<RekapPage> createState() =>
      _RekapPageState();
}

class _RekapPageState
    extends State<RekapPage> {

  List orders = [];

  bool isLoading = true;

  int totalIncome = 0;

  int selectedMonth =
      DateTime.now().month;

  int selectedYear =
      DateTime.now().year;



  @override
  void initState() {

    super.initState();

    fetchData();
  }



  // =====================================
  // FETCH DATA
  // =====================================

  Future<void> fetchData()
  async {

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



      int income = 0;



      for (var item in data) {

        try {

          DateTime date =
              DateTime.parse(
            item["tanggal"],
          );



          if (

              date.month ==
                  selectedMonth &&

              date.year ==
                  selectedYear

          ) {

            income +=

                int.tryParse(

                      item["total"]
                          .toString(),

                    ) ??

                    0;
          }

        } catch (e) {

          debugPrint(
            e.toString(),
          );
        }
      }



      if (!mounted) return;



      setState(() {

        orders = data;

        totalIncome =
            income;

        isLoading =
            false;
      });

    } catch (e) {

      debugPrint(
        e.toString(),
      );

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
  // WEEKLY CHART
  // =====================================

  List<FlSpot> getWeeklySpots() {

    Map<int, double> dailyIncome = {};

    for (int i = 0; i < 7; i++) {
      dailyIncome[i] = 0;
    }

    for (var item in orders) {

      try {

        DateTime date =
            DateTime.parse(
          item["tanggal"],
        );

        int diff =
            DateTime.now()
                .difference(date)
                .inDays;

        if (diff >= 0 && diff < 7) {

          dailyIncome[6 - diff] =
              dailyIncome[6 - diff]! +

              (double.tryParse(
                    item["total"]
                        .toString(),
                  ) ??
                  0);
        }

      } catch (e) {}
    }

    return List.generate(

      7,

      (index) {

        return FlSpot(

          index.toDouble(),

          dailyIncome[index]! / 10000,
        );
      },
    );
  }



  // =====================================
  // PAYMENT %
  // =====================================

  double getPaymentPercent(
    String method,
  ) {

    if (orders.isEmpty) return 0;

    int count =

        orders.where((item) {

      return item["metode"] ==
          method;

    }).length;

    return count / orders.length;
  }



  // =====================================
  // SERVICE %
  // =====================================

  double getServicePercent(
    String service,
  ) {

    if (orders.isEmpty) return 0;

    int count =

        orders.where((item) {

      return item["layanan"]
          .toString()
          .contains(service);

    }).length;

    return count / orders.length;
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

          "Araku Shoes Care",

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

              // RefreshIndicator: swipe down → fetchData()
              : RefreshIndicator(

                  onRefresh: fetchData,

                  child: SingleChildScrollView(

                    // AlwaysScrollable agar RefreshIndicator
                    // bisa dipicu meski konten pendek
                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(16),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                      const Text(

                        "Rekap Keuangan",

                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),



                      // =====================================
                      // FILTER
                      // =====================================

                      Row(

                        children: [

                          Container(

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(

                              color: Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),

                            child: DropdownButton<int>(

                              value: selectedMonth,

                              underline:
                                  const SizedBox(),

                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),

                              items: List.generate(

                                12,

                                (index) {

                                  return DropdownMenuItem(

                                    value:
                                        index + 1,

                                    child: Text(

                                      DateFormat.MMMM(
                                        "id_ID",
                                      ).format(
                                        DateTime(
                                          0,
                                          index + 1,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              onChanged: (value) {

                                setState(() {
                                  selectedMonth =
                                      value!;
                                });

                                fetchData();
                              },
                            ),
                          ),

                          const SizedBox(width: 14),

                          Container(

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),

                            decoration: BoxDecoration(

                              color: Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),

                            child: DropdownButton<int>(

                              value: selectedYear,

                              underline:
                                  const SizedBox(),

                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),

                              items: [

                                2024,
                                2025,
                                2026,
                                2027,

                              ].map((year) {

                                return DropdownMenuItem(

                                  value: year,

                                  child: Text(
                                    year.toString(),
                                  ),
                                );
                              }).toList(),

                              onChanged: (value) {

                                setState(() {
                                  selectedYear =
                                      value!;
                                });

                                fetchData();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),



                      // =====================================
                      // TOTAL INCOME
                      // =====================================

                      Container(

                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(22),

                        decoration: BoxDecoration(

                          gradient:
                              const LinearGradient(

                            colors: [

                              Color(0xFF8B5CF6),

                              Color(0xFF7C3AED),
                            ],
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            22,
                          ),
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const Text(

                              "Total Pemasukan",

                              style: TextStyle(
                                color:
                                    Colors.white70,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            Text(

                              "Rp ${NumberFormat('#,###').format(totalIncome)}",

                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            const Text(
                              "Realtime dari Google Sheets",
                              style: TextStyle(
                                color:
                                    Colors.white70,
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),



                      // =====================================
                      // CHART
                      // =====================================

                      buildCard(

                        title:
                            "Pemasukan 7 Hari Terakhir",

                        child: SizedBox(

                          height: 220,

                          child: LineChart(

                            LineChartData(

                              gridData:
                                  const FlGridData(
                                show: false,
                              ),

                              borderData:
                                  FlBorderData(
                                show: false,
                              ),

                              titlesData: FlTitlesData(

                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              leftTitles: AxisTitles(

                                sideTitles: SideTitles(

                                  showTitles: true,

                                  reservedSize: 40,

                                  interval: 10,

                                  getTitlesWidget: (value, meta) {

                                    return Text(

                                      value.toInt().toString(),

                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              bottomTitles: AxisTitles(

                                sideTitles: SideTitles(

                                  showTitles: true,

                                  getTitlesWidget: (value, meta) {

                                    List<String> days = [
                                      "Sen",
                                      "Sel",
                                      "Rab",
                                      "Kam",
                                      "Jum",
                                      "Sab",
                                      "Min",
                                    ];

                                    return Padding(

                                      padding: const EdgeInsets.only(
                                        top: 8,
                                      ),

                                      child: Text(

                                        days[value.toInt()],

                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                              lineBarsData: [

                                LineChartBarData(

                                  isCurved: true,

                                  color:
                                      const Color(
                                    0xFF7C3AED,
                                  ),

                                  barWidth: 4,

                                  dotData:
                                      const FlDotData(
                                    show: true,
                                  ),

                                  spots:
                                      getWeeklySpots(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),



                      // =====================================
                      // PAYMENT
                      // =====================================

                      buildCard(

                        title:
                            "Metode Pembayaran",

                        child: Column(

                          children: [

                            paymentBar(
                              "QRIS",
                              getPaymentPercent(
                                "QRIS",
                              ),
                              Colors.deepPurple,
                            ),

                            paymentBar(
                              "Tunai",
                              getPaymentPercent(
                                "Tunai",
                              ),
                              Colors.grey,
                            ),

                            paymentBar(
                              "Transfer",
                              getPaymentPercent(
                                "Transfer",
                              ),
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),



                      // =====================================
                      // SERVICE
                      // =====================================

                      buildCard(

                        title:
                            "Layanan Populer",

                        child: Column(

                          children: [

                            paymentBar(
                              "Deep Cleaning",
                              getServicePercent(
                                "Deep",
                              ),
                              Colors.deepPurple,
                            ),

                            paymentBar(
                              "Fast Cleaning",
                              getServicePercent(
                                "Express",
                              ),
                              Colors.deepPurple,
                            ),

                            paymentBar(
                              "Unyellowing",
                              getServicePercent(
                                "Unyellowing",
                              ),
                              Colors.deepPurple,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),



    );
  }



  // =====================================
  // CARD
  // =====================================

  Widget buildCard({
    required String title,
    required Widget child,
  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 20),

          child
        ],
      ),
    );
  }



  // =====================================
  // PAYMENT BAR
  // =====================================

  Widget paymentBar(
    String title,
    double value,
    Color color,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(bottom: 18),

      child: Column(

        children: [

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [

              Text(title),

              Text(
                "${(value * 100).toStringAsFixed(0)}%",
              ),
            ],
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(

            value: value,

            minHeight: 8,

            borderRadius:
                BorderRadius.circular(20),

            backgroundColor:
                Colors.grey.shade200,

            valueColor:
                AlwaysStoppedAnimation(
              color,
            ),
          )
        ],
      ),
    );
  }



}