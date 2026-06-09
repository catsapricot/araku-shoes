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
  String selectedStatus = "Semua";

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

    setState(() {
      isLoading = true;
    });

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
        filteredOrders = orders;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());

      ScaffoldMessenger.of(context)
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

    final keyword =
        searchController.text.toLowerCase();

    setState(() {

      filteredOrders = orders.where((item) {

        // Cari berdasarkan: nama | angka ID | "TRX-{id}"
        final matchSearch =
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

        final matchStatus =
            selectedStatus == "Semua" ||
            item["status"] == selectedStatus;

        return matchSearch && matchStatus;

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

      final apiUrl =
          await ApiService.getApiUrl();

      await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "text/plain",
        },
        body: jsonEncode({
          "action": "update",
          "id": id,
          "status": status,
        }),
      );

      fetchOrders();

    } catch (e) {

      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context)
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
  // UPDATE STATUS PEMBAYARAN
  // Kirim action "update" dengan field
  // statusBayar (kolom 12 di sheet).
  // =====================================

  Future<void> updateStatusBayar(
    dynamic id,
    String statusBayar,
  ) async {

    try {

      final apiUrl =
          await ApiService.getApiUrl();

      await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "action": "update",
          "id": id,
          "statusBayar": statusBayar,
        }),
      );

      fetchOrders();

    } catch (e) {

      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Gagal update pembayaran: $e",
          ),
        ),
      );
    }
  }



  // =====================================
  // DOUBLE CONFIRMATION — SUDAH DIAMBIL
  // 2 popup sebelum status final ditetapkan
  // =====================================

  Future<void> confirmSudahDiambil(
    dynamic id,
  ) async {

    // ── POPUP 1 ──────────────────────────

    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Konfirmasi Pengambilan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: const Text(
          "Apakah customer sudah mengambil laundry?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF0F766E),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Ya",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm1 != true) return;

    if (!mounted) return;

    // ── POPUP 2 ──────────────────────────

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Konfirmasi Akhir",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: const Text(
          "Status akan dianggap selesai permanen dan tidak bisa diubah lagi.",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Ya, Tandai Selesai",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm2 != true) return;

    await updateStatus(id, "Sudah Diambil");
  }



  // =====================================
  // STATUS COLOR
  // Urutan: Diproses → Selesai →
  //         Belum Diambil → Sudah Diambil
  // =====================================

  Color getStatusColor(String status) {
    switch (status) {
      case "Diproses":
        return const Color(0xFF8B5CF6);   // Ungu
      case "Selesai":
        return const Color(0xFF0F766E);   // Teal
      case "Belum Diambil":
        return const Color(0xFFB45309);   // Amber
      case "Sudah Diambil":
        return const Color(0xFF6B7280);   // Abu
      default:
        return Colors.grey;
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
        leading: IconButton(
          onPressed: () =>
              Navigator.pop(context),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                // =============================
                // SEARCH
                // =============================

                TextField(
                  controller: searchController,
                  onChanged: (_) => filterOrders(),
                  decoration: InputDecoration(
                    hintText:
                        "Cari pelanggan atau ID transaksi...",
                    prefixIcon:
                        const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =============================
                // FILTER CHIPS
                // Urutan: Semua | Diproses |
                //   Selesai | Belum Diambil |
                //   Sudah Diambil
                // =============================

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      filterChip("Semua"),
                      const SizedBox(width: 8),
                      filterChip("Diproses"),
                      const SizedBox(width: 8),
                      filterChip("Selesai"),
                      const SizedBox(width: 8),
                      filterChip("Belum Diambil"),
                      const SizedBox(width: 8),
                      filterChip("Sudah Diambil"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===================================
          // ORDER LIST
          // ===================================

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: fetchOrders,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount:
                          filteredOrders.length,
                      itemBuilder:
                          (context, index) {
                        final item =
                            filteredOrders[index];
                        return _buildOrderCard(
                          item,
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
  // ORDER CARD
  // "Sudah Diambil" → card greyed, no button
  // Lainnya → tombol Update Status
  // =====================================

  Widget _buildOrderCard(
    dynamic item,
  ) {

    final bool isDone =
        item["status"] == "Sudah Diambil";

    return Opacity(

      opacity: isDone ? 0.65 : 1.0,

      child: Container(

        margin: const EdgeInsets.only(bottom: 16),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: isDone
              ? const Color(0xFFF3F3F3)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: isDone
              ? []
              : [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.03),
                    blurRadius: 10,
                  ),
                ],
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ── TOP ROW: nama + badge ──────

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Flexible(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["nama"],
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "TRX-${item["id"]}",
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(
                      item["status"],
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    item["status"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── LAYANAN ───────────────────

            Text(
              "Layanan",
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "${item["layanan"]} (${item["jumlah"]} pasang)",
            ),

            const SizedBox(height: 16),

            // ── STATUS PEMBAYARAN + UBAH ──

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4FA),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 18,
                    color: Color(0xFF5B2DA3),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Pembayaran",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  _paymentStatusBadge(
                    item["statusBayar"],
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        _showUpdateStatusBayarSheet(
                      item,
                    ),
                    child: Container(
                      padding:
                          const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF3E8FF,
                        ),
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF5B2DA3),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── ACTION ────────────────────
            // "Sudah Diambil" → label selesai
            // Lainnya         → tombol update

            if (isDone)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF6B7280),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Sudah Diambil",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            else
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () =>
                      _showUpdateStatusSheet(
                    item,
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Update Status",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }



  // =====================================
  // MODAL UPDATE STATUS
  // Urutan: Diproses → Selesai →
  //         Belum Diambil → Sudah Diambil
  // =====================================

  void _showUpdateStatusSheet(dynamic item) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
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
                "Diproses",
                const Color(0xFF8B5CF6),
              ),

              const SizedBox(height: 12),

              statusButton(
                item["id"],
                "Selesai",
                const Color(0xFF0F766E),
              ),

              const SizedBox(height: 12),

              statusButton(
                item["id"],
                "Belum Diambil",
                const Color(0xFFB45309),
              ),

              const SizedBox(height: 12),

              // "Sudah Diambil" — double confirm

              statusButton(
                item["id"],
                "Sudah Diambil",
                const Color(0xFF6B7280),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }



  // =====================================
  // BADGE STATUS PEMBAYARAN
  // Lunas → hijau, lainnya → oranye
  // Data lama tanpa field → "Belum Lunas"
  // =====================================

  Widget _paymentStatusBadge(dynamic raw) {

    final String status =
        (raw == null ||
                raw.toString().trim().isEmpty)
            ? "Belum Lunas"
            : raw.toString();

    final bool lunas = status == "Lunas";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: lunas
            ? const Color(0xFFE6F4F1)
            : const Color(0xFFFDF3E7),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: lunas
              ? const Color(0xFF0F766E)
              : const Color(0xFFB45309),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }



  // =====================================
  // MODAL UBAH STATUS PEMBAYARAN
  // =====================================

  void _showUpdateStatusBayarSheet(
    dynamic item,
  ) {

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Text(
                "Status Pembayaran",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              statusBayarButton(
                item["id"],
                "Lunas",
                const Color(0xFF0F766E),
              ),

              const SizedBox(height: 12),

              statusBayarButton(
                item["id"],
                "Belum Lunas",
                const Color(0xFFB45309),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }



  // =====================================
  // STATUS BAYAR BUTTON
  // =====================================

  Widget statusBayarButton(
    dynamic id,
    String value,
    Color color,
  ) {

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          await updateStatusBayar(id, value);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



  // =====================================
  // STATUS BUTTON
  // "Sudah Diambil" → double confirmation
  // Lainnya → langsung update
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

          // Tutup modal dulu
          Navigator.pop(context);

          if (status == "Sudah Diambil") {

            // Double confirmation khusus status final
            await confirmSudahDiambil(id);

          } else {

            await updateStatus(id, status);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
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



  // =====================================
  // FILTER CHIP
  // =====================================

  Widget filterChip(String status) {

    final bool selected =
        selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStatus = status;
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
          status,
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
