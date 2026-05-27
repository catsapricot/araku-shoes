import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() =>
      _HistoryPageState();
}

class _HistoryPageState
    extends State<HistoryPage> {

  List orders = [];
  List filteredOrders = [];
  bool isLoading = true;

  // Default "Semua" agar semua transaksi tampil
  String selectedFilter = "Semua";

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
  // Setelah data masuk, langsung apply
  // filter yang sedang aktif.
  // =====================================

  Future<void> fetchOrders() async {

    try {

      final apiUrl =
          await ApiService.getApiUrl();

      final response = await http.get(
        Uri.parse("$apiUrl?all=true"),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        orders = data.reversed.toList();
        isLoading = false;
      });

      // Apply filter aktif ke data terbaru
      filterOrders();

    } catch (e) {

      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("Gagal mengambil data: $e"),
        ),
      );
    }
  }



  // =====================================
  // FILTER — menggabungkan:
  // 1. Date filter (Semua / Hari Ini)
  // 2. Search filter (nama / ID / TRX-)
  // =====================================

  void filterOrders() {

    final keyword =
        searchController.text.toLowerCase();

    setState(() {

      filteredOrders = orders.where((item) {

        // ── DATE FILTER ──────────────────────

        bool matchDate = true;

        if (selectedFilter == "Hari Ini") {
          try {
            final date = DateTime.parse(
              item["tanggal"].toString(),
            );
            final now = DateTime.now();
            matchDate =
                date.year  == now.year  &&
                date.month == now.month &&
                date.day   == now.day;
          } catch (_) {
            matchDate = false;
          }
        }

        // ── SEARCH FILTER ─────────────────────
        // Cari: nama | angka ID | "TRX-{id}"

        final matchSearch = keyword.isEmpty ||
            item["nama"]
                .toString()
                .toLowerCase()
                .contains(keyword) ||
            item["id"]
                .toString()
                .contains(keyword) ||
            "TRX-${item["id"]}"
                .toLowerCase()
                .contains(keyword);

        return matchDate && matchSearch;

      }).toList();
    });
  }



  // =====================================
  // FORMAT JAM dari field tanggal backend
  // item["tanggal"] → "HH:mm WIB"
  // Parsing aman: jika gagal, return "—"
  // =====================================

  String _formatJam(dynamic tanggal) {
    try {
      final date = DateTime.parse(
        tanggal.toString(),
      );
      return "${DateFormat("HH:mm").format(date)} WIB";
    } catch (_) {
      return "—";
    }
  }



  // =====================================
  // FORMAT DATE HEADER
  // Ambil dari item["tanggal"] backend.
  // Fallback ke hari ini jika parsing gagal.
  // =====================================

  String _formatHeaderDate(dynamic tanggal) {
    try {
      final date = DateTime.parse(
        tanggal.toString(),
      );
      return DateFormat(
        "dd MMMM yyyy",
        "id_ID",
      ).format(date);
    } catch (_) {
      return DateFormat(
        "dd MMMM yyyy",
        "id_ID",
      ).format(DateTime.now());
    }
  }



  // =====================================
  // BUILD
  // =====================================

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
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.cloud_done_outlined,
              color: Color(0xFF5B2DA3),
            ),
          ),
        ],
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : Column(

              children: [

                // ==============================
                // SEARCH + FILTER
                // ==============================

                Padding(

                  padding:
                      const EdgeInsets.all(16),

                  child: Column(

                    children: [

                      // ── SEARCH ──────────────

                      TextField(

                        controller:
                            searchController,

                        onChanged: (_) =>
                            filterOrders(),

                        decoration:
                            InputDecoration(

                          hintText:
                              "Cari pelanggan atau ID transaksi...",

                          prefixIcon:
                              const Icon(Icons.search),

                          filled: true,

                          fillColor: Colors.white,

                          border: OutlineInputBorder(

                            borderRadius:
                                BorderRadius.circular(14),

                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── FILTER CHIPS ────────
                      // Semua | Hari Ini

                      Row(

                        children: [

                          filterChip("Semua"),

                          const SizedBox(width: 10),

                          filterChip("Hari Ini"),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==============================
                // LIST — dengan RefreshIndicator
                // Swipe down → fetchOrders()
                // ==============================

                Expanded(

                  child: RefreshIndicator(

                    onRefresh: fetchOrders,

                    child: filteredOrders.isEmpty

                        // ── EMPTY STATE ───────
                        ? ListView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons
                                          .receipt_long_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Tidak ada transaksi",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )

                        // ── LIST ──────────────
                        : ListView.builder(

                            physics:
                                const AlwaysScrollableScrollPhysics(),

                            padding:
                                const EdgeInsets.all(16),

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

                                  // Date header
                                  // hanya di item pertama

                                  if (index == 0)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        bottom: 14,
                                      ),
                                      child: Text(
                                        _formatHeaderDate(
                                          item["tanggal"],
                                        ),
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),

                                  // ── CARD ────────────────

                                  Container(

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

                                            Flexible(

                                              child: Column(

                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,

                                                children: [

                                                  Text(

                                                    item["nama"],

                                                    overflow:
                                                        TextOverflow
                                                            .ellipsis,

                                                    style:
                                                        const TextStyle(
                                                      fontWeight:
                                                          FontWeight
                                                              .bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 4),

                                                  // JAM dari backend
                                                  // + TRX-ID

                                                  Text(

                                                    "${_formatJam(item["tanggal"])} • TRX-${item["id"]}",

                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(
                                                width: 8),

                                            Text(

                                              "Rp ${item["total"]}",

                                              style:
                                                  const TextStyle(
                                                color: Color(
                                                  0xFF0F766E,
                                                ),
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 18),

                                        const Divider(),

                                        const SizedBox(height: 14),

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
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      height: 6),

                                                  Text(
                                                    "${item["layanan"]} (${item["jumlah"]} pasang)",
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(

                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),

                                              decoration: BoxDecoration(

                                                color: const Color(
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
                                                  color: Color(
                                                    0xFF5B2DA3,
                                                  ),
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }



  // =====================================
  // FILTER CHIP WIDGET
  // Tap → update selectedFilter → filterOrders()
  // =====================================

  Widget filterChip(String title) {

    final bool selected = selectedFilter == title;

    return GestureDetector(

      onTap: () {
        setState(() {
          selectedFilter = title;
        });
        filterOrders();
      },

      child: Container(

        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: selected
              ? const Color(0xFF0F766E)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: selected
                ? const Color(0xFF0F766E)
                : Colors.grey.shade300,
          ),
        ),

        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
