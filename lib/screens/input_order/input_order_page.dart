import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../receipt/receipt_page.dart';
import '../../services/api_service.dart';

class InputOrderPage extends StatefulWidget {
  const InputOrderPage({super.key});

  @override
  State<InputOrderPage> createState() => _InputOrderPageState();
}

class _InputOrderPageState extends State<InputOrderPage> {
  // =====================================
  // CONSTANTS
  // =====================================

  static const Color kPrimary = Color(0xFF5B2DA3);
  static const Color kPrimaryLight = Color(0xFFF3E8FF);
  static const Color kBackground = Color(0xFFF6F7FB);
  static const Color kCardBg = Color(0xFFF7F4FA);

  // =====================================
  // CONTROLLERS
  // =====================================

  final namaController = TextEditingController();
  final nohpController = TextEditingController();
  final catatanController = TextEditingController();
  final qtyController = TextEditingController(text: "1");

  // =====================================
  // STATE
  // =====================================

  List<Map<String, dynamic>> cart = [];
  Map<String, dynamic> selectedLayanan = {
    "nama": "Cuci Sepatu Gelap",
    "harga": 35000,
  };
  String metode = "Tunai";
  bool isLoading = false;

  // =====================================
  // PRICELIST
  // =====================================

  final List<Map<String, dynamic>> layananList = [
    {"nama": "Cuci Sepatu Gelap", "harga": 35000},
    {"nama": "Cuci Sepatu Terang", "harga": 40000},
    {"nama": "Cuci Sepatu Flat Shoes / Heels", "harga": 35000},
    {"nama": "Cuci Sepatu Boots", "harga": 50000},
    {"nama": "Cuci Sepatu Gelap Express", "harga": 50000},
    {"nama": "Cuci Sepatu Terang Express", "harga": 55000},
    {"nama": "Cuci + Lem", "harga": 65000},
    {"nama": "Cuci + Jahit", "harga": 85000},
    {"nama": "Cuci + Repaint", "harga": 105000},
    {"nama": "Unyellowing", "harga": 65000},
    {"nama": "Anti Jamur", "harga": 65000},
  ];

  // =====================================
  // FORMAT RUPIAH
  // =====================================

  String rupiah(int number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // =====================================
  // CART LOGIC
  // =====================================

  void addToCart() {
    int qty = int.tryParse(qtyController.text) ?? 1;
    if (qty < 1) qty = 1;

    final String nama = selectedLayanan["nama"];
    final int harga = selectedLayanan["harga"];
    final int existingIndex = cart.indexWhere((item) => item["layanan"] == nama);

    setState(() {
      if (existingIndex != -1) {
        cart[existingIndex]["qty"] += qty;
        cart[existingIndex]["subtotal"] =
            cart[existingIndex]["qty"] * cart[existingIndex]["harga"];
      } else {
        cart.add({
          "layanan": nama,
          "qty": qty,
          "harga": harga,
          "subtotal": harga * qty,
        });
      }
    });

    qtyController.text = "1";
  }

  void updateQty(int index, int delta) {
    setState(() {
      final newQty = (cart[index]["qty"] as int) + delta;
      if (newQty < 1) {
        cart.removeAt(index);
      } else {
        cart[index]["qty"] = newQty;
        cart[index]["subtotal"] = newQty * (cart[index]["harga"] as int);
      }
    });
  }

  void removeItem(int index) {
    setState(() => cart.removeAt(index));
  }

  int get total => cart.fold(0, (sum, item) => sum + (item["subtotal"] as int));

  // =====================================
  // SUBMIT
  // =====================================

  Future<void> simpanData() async {

    if (
        namaController.text.isEmpty ||

        nohpController.text.isEmpty ||

        cart.isEmpty
    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(

            "Lengkapi data dan tambahkan layanan terlebih dahulu",
          ),
        ),
      );

      return;
    }



    setState(() {

      isLoading = true;
    });



    try {

      // =====================================
      // GET DYNAMIC API URL
      // =====================================

      final apiUrl =
          await ApiService.getApiUrl();



      final response =
          await http.post(

        Uri.parse(apiUrl),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "nama":
              namaController.text,

          "nohp":
              nohpController.text,

          "layanan":
              jsonEncode(cart),

          "jumlah":
              cart.length,

          "harga":
              total,

          "metode":
              metode,

          "catatan":
              catatanController.text,
        }),
      );



      final result =
          jsonDecode(response.body);



      final String invoiceId =
          "TRX-${result["id"]}";



      if (!mounted) return;



      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>

              ReceiptPage(

            invoice:
                invoiceId,

            cart:
                cart,

            metode:
                metode,

            total:
                total,
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(

            "Gagal menyimpan: ${e.toString()}",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {

          isLoading = false;
        });
      }
    }
  }


  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Input Transaksi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── INFO PELANGGAN ──────────────────────────
            _buildSection(
              title: "Info Pelanggan",
              child: Column(
                children: [
                  _buildInput(
                    label: "Nama Pelanggan",
                    hint: "Masukkan nama...",
                    controller: namaController,
                  ),
                  const SizedBox(height: 14),
                  _buildInput(
                    label: "Nomor HP Pelanggan",
                    hint: "+62 81234567890",
                    controller: nohpController,
                    inputType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── KATALOG LAYANAN ─────────────────────────
            _buildSection(
              title: "Pilih Layanan",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: layananList.map((item) {
                      final bool selected = selectedLayanan["nama"] == item["nama"];
                      return GestureDetector(
                        onTap: () => setState(() => selectedLayanan = item),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 148,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? kPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? kPrimary : Colors.grey.shade300,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: kPrimary.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["nama"],
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                rupiah(item["harga"]),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white70
                                      : Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── QTY + ADD BUTTON ──────────────────
                  Row(
                    children: [
                      // QTY stepper
                      Container(
                        decoration: BoxDecoration(
                          color: kCardBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _qtyStepButton(
                              icon: Icons.remove,
                              onTap: () {
                                final v = int.tryParse(qtyController.text) ?? 1;
                                if (v > 1) qtyController.text = "${v - 1}";
                              },
                            ),
                            SizedBox(
                              width: 44,
                              child: TextField(
                                controller: qtyController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            _qtyStepButton(
                              icon: Icons.add,
                              onTap: () {
                                final v = int.tryParse(qtyController.text) ?? 1;
                                qtyController.text = "${v + 1}";
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Add to cart button
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: addToCart,
                            icon: const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 18),
                            label: const Text(
                              "Tambah ke Cart",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── CART ────────────────────────────────────
            if (cart.isNotEmpty)
              _buildSection(
                title: "Daftar Layanan (${cart.length} item)",
                child: Column(
                  children: List.generate(cart.length, (index) {
                    final item = cart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kCardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["layanan"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${item["qty"]} x ${rupiah(item["harga"])}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rupiah(item["subtotal"]),
                                  style: const TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Qty controls
                          Row(
                            children: [
                              _cartQtyButton(
                                icon: Icons.remove,
                                onTap: () => updateQty(index, -1),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "${item["qty"]}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              _cartQtyButton(
                                icon: Icons.add,
                                onTap: () => updateQty(index, 1),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => removeItem(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.delete_outline,
                                      color: Colors.red.shade400, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

            if (cart.isNotEmpty) const SizedBox(height: 16),

            // ── PEMBAYARAN ──────────────────────────────
            _buildSection(
              title: "Pembayaran",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Metode Pembayaran",
                      style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _paymentItem("Tunai", Icons.payments_outlined),
                      const SizedBox(width: 10),
                      _paymentItem("QRIS", Icons.qr_code_2),
                      const SizedBox(width: 10),
                      _paymentItem("Transfer", Icons.account_balance),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    label: "Catatan (Opsional)",
                    hint: "Tambahkan catatan khusus...",
                    controller: catatanController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── TOTAL ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Pembayaran",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        rupiah(total),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.cloud_upload_outlined,
                          color: Colors.grey, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        "Simpan ke\nGoogle Sheets",
                        textAlign: TextAlign.right,
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── SUBMIT BUTTON ───────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  disabledBackgroundColor: kPrimary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Simpan Transaksi",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =====================================
  // HELPER WIDGETS
  // =====================================

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF7F4FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _qtyStepButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 18, color: kPrimary),
      ),
    );
  }

  Widget _cartQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: kPrimaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: kPrimary),
      ),
    );
  }

  Widget _paymentItem(String value, IconData icon) {
    final bool selected = metode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => metode = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? kPrimaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? kPrimary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? kPrimary : Colors.black54),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: selected ? kPrimary : Colors.black,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}