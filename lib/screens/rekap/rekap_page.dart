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

      } catch (e) {
        debugPrint("getWeeklySpots: $e");
      }
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
  // ORDERS PERIODE TERPILIH
  // Semua statistik (pembayaran & layanan)
  // mengikuti bulan + tahun yang dipilih
  // supaya konsisten dengan Total Pemasukan.
  // =====================================

  List get _periodOrders {

    return orders.where((item) {

      try {

        final date = DateTime.parse(
          item["tanggal"].toString(),
        );

        return date.month == selectedMonth &&
            date.year == selectedYear;

      } catch (_) {

        return false;
      }

    }).toList();
  }



  // =====================================
  // PAYMENT %
  // =====================================

  double getPaymentPercent(
    String method,
  ) {

    final list = _periodOrders;

    if (list.isEmpty) return 0;

    final int count = list
        .where((item) => item["metode"] == method)
        .length;

    return count / list.length;
  }



  // =====================================
  // TOP LAYANAN — dihitung dari data nyata
  // Format teks backend: "Nama (Nx), Nama (Nx)"
  // Akumulasi qty per layanan, urut terbanyak,
  // ambil maksimal 5 teratas.
  // =====================================

  List<MapEntry<String, int>> getTopServices() {

    final Map<String, int> counter = {};

    final regex = RegExp(r'^(.*?)\s*\((\d+)x\)$');

    for (var item in _periodOrders) {

      final raw =
          item["layanan"]?.toString() ?? "";

      if (raw.trim().isEmpty) continue;

      for (final part in raw.split(",")) {

        final text = part.trim();

        if (text.isEmpty) continue;

        final match = regex.firstMatch(text);

        if (match != null) {

          final name = match.group(1)!.trim();
          final qty =
              int.tryParse(match.group(2)!) ?? 1;

          counter[name] =
              (counter[name] ?? 0) + qty;

        } else {

          // Fallback untuk data lama tanpa "(Nx)"
          counter[text] =
              (counter[text] ?? 0) + 1;
        }
      }
    }

    final entries = counter.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(5).toList();
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

                        child: _buildPopularServices(),
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



  // =====================================
  // LAYANAN POPULER — daftar dinamis
  // Ranking + jumlah pasang + bar relatif
  // terhadap layanan terlaris.
  // =====================================

  Widget _buildPopularServices() {

    final top = getTopServices();

    if (top.isEmpty) {

      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                "Belum ada data layanan bulan ini",
                style: TextStyle(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int maxVal = top.first.value;

    return Column(
      children: [
        for (int i = 0; i < top.length; i++)
          _serviceBar(
            i + 1,
            top[i].key,
            top[i].value,
            maxVal == 0
                ? 0.0
                : top[i].value / maxVal,
          ),
      ],
    );
  }



  // =====================================
  // SERVICE BAR (1 baris ranking layanan)
  // =====================================

  Widget _serviceBar(
    int rank,
    String name,
    int count,
    double ratio,
  ) {

    final Color barColor = rank == 1
        ? const Color(0xFF7C3AED)
        : rank == 2
            ? const Color(0xFF9F67E4)
            : const Color(0xFFC4B5FD);

    return Padding(

      padding:
          const EdgeInsets.only(bottom: 18),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(

            children: [

              // Nomor ranking
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: barColor
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$rank",
                  style: TextStyle(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                "$count pasang",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor:
                  Colors.grey.shade200,
              valueColor:
                  AlwaysStoppedAnimation(
                barColor,
              ),
            ),
          ),
        ],
      ),
    );
  }



}