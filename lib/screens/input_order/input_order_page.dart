import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../receipt/receipt_page.dart';

class InputOrderPage extends StatefulWidget {
  const InputOrderPage({super.key});

  @override
  State<InputOrderPage> createState() =>
      _InputOrderPageState();
}

class _InputOrderPageState
    extends State<InputOrderPage> {

  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbzE5GT3hHsNkTP7PVlxng79VBCwRiTqi0UolVR3-lSdUR_nah-l_7ZvAR9aKv-N-lBt/exec";



  // =====================================
  // CONTROLLER
  // =====================================

  final namaController =
      TextEditingController();

  final nohpController =
      TextEditingController();

  final hargaController =
      TextEditingController();

  final catatanController =
      TextEditingController();



  // =====================================
  // STATE
  // =====================================

  int jumlah = 1;

  String layanan =
      "Cuci Sepatu Gelap";

  String metode = "Tunai";

  bool isLoading = false;



  // =====================================
  // LAYANAN LIST
  // =====================================

  final List<String> layananList = [

    "Cuci Sepatu Gelap",

    "Cuci Sepatu Terang",

    "Cuci Sepatu Flat Shoes / Heels",

    "Cuci Sepatu Boots",

    "Cuci Sepatu Gelap Express",

    "Cuci Sepatu Terang Express",

    "Cuci + Lem",

    "Cuci + Jahit",

    "Cuci + Repaint",

    "Unyellowing",

    "Anti Jamur",
  ];



  // =====================================
  // TOTAL
  // =====================================

  int get total {

    int harga =
        int.tryParse(
          hargaController.text,
        ) ??
        0;

    return harga * jumlah;
  }



  // =====================================
  // SUBMIT
  // =====================================

  Future<void> simpanData() async {

    if (
      namaController.text.isEmpty ||
      nohpController.text.isEmpty ||
      hargaController.text.isEmpty
    ) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Lengkapi data terlebih dahulu",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(apiUrl),

        headers: {
          "Content-Type":
              "application/json"
        },

        body: jsonEncode({

          "nama":
              namaController.text,

          "nohp":
              nohpController.text,

          "layanan":
              layanan,

          "jumlah":
              jumlah,

          "harga":
              hargaController.text,

          "metode":
              metode,

          "catatan":
              catatanController.text,
        }),
      );

      Map<String, dynamic> result = {
        "status": "success",
        "id": DateTime.now().millisecondsSinceEpoch
      };

      if (result["status"] == "success") {

        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "Transaksi berhasil disimpan",
            ),
          ),
        );

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (context) => ReceiptPage(

              invoice:
                  "TRX-${result["id"]}",

              layanan:
                  layanan,

              jumlah:
                  jumlah,

              harga:
                  int.parse(
                    hargaController.text,
                  ),

              metode:
                  metode,

              total:
                  total,
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );

    } finally {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(

        elevation: 0,

        backgroundColor: Colors.white,

        title: const Text(
          "Input Transaksi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // =====================================
            // INFO PELANGGAN
            // =====================================

            buildSection(

              title: "Info Pelanggan",

              child: Column(

                children: [

                  buildInput(
                    label: "Nama Pelanggan",
                    hint: "Masukkan nama...",
                    controller:
                        namaController,
                  ),

                  const SizedBox(height: 14),

                  buildInput(
                    label: "Nomor HP Pelanggan",
                    hint: "+62 81234567890",
                    controller:
                        nohpController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),



            // =====================================
            // DETAIL LAYANAN
            // =====================================

            buildSection(

              title: "Detail Layanan",

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Jenis Layanan",
                  ),

                  const SizedBox(height: 12),

                  Wrap(

                    spacing: 8,
                    runSpacing: 8,

                    children:

                        layananList.map((item) {

                      bool selected =
                          layanan == item;

                      return GestureDetector(

                        onTap: () {

                          setState(() {
                            layanan = item;
                          });
                        },

                        child: Container(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(

                            color: selected
                                ? const Color(
                                    0xFF5B2DA3)
                                : Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),

                            border: Border.all(
                              color: selected
                                  ? const Color(
                                      0xFF5B2DA3)
                                  : Colors.grey
                                      .shade300,
                            ),
                          ),

                          child: Text(

                            item,

                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Jumlah Sepatu",
                  ),

                  const SizedBox(height: 12),

                  Container(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: Row(

                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        IconButton(

                          onPressed: () {

                            if (jumlah > 1) {

                              setState(() {
                                jumlah--;
                              });
                            }
                          },

                          icon:
                              const Icon(Icons.remove),
                        ),

                        Text(
                          jumlah.toString(),
                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        IconButton(

                          onPressed: () {

                            setState(() {
                              jumlah++;
                            });
                          },

                          icon:
                              const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  buildInput(
                    label: "Harga per item",
                    hint: "35000",
                    controller:
                        hargaController,
                    number: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),



            // =====================================
            // PEMBAYARAN
            // =====================================

            buildSection(

              title: "Pembayaran",

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Metode Pembayaran",
                  ),

                  const SizedBox(height: 14),

                  Row(

                    children: [

                      paymentItem(
                        "Tunai",
                        Icons.payments_outlined,
                      ),

                      const SizedBox(width: 10),

                      paymentItem(
                        "QRIS",
                        Icons.qr_code_2,
                      ),

                      const SizedBox(width: 10),

                      paymentItem(
                        "Transfer",
                        Icons.account_balance,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  buildInput(
                    label:
                        "Catatan (Opsional)",
                    hint:
                        "Tambahkan catatan khusus...",
                    controller:
                        catatanController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),



            // =====================================
            // TOTAL
            // =====================================

            Container(

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Row(

                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "Total Harga",
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Rp $total",

                        style:
                            const TextStyle(
                          fontSize: 32,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF5B2DA3),
                        ),
                      ),
                    ],
                  ),

                  const Text(
                    "⚠ Akan tersimpan\nke Google Sheets",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),



            // =====================================
            // BUTTON
            // =====================================

            SizedBox(

              width: double.infinity,
              height: 56,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : simpanData,

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                    0xFF5B2DA3,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                child:
                    isLoading

                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )

                        : const Text(

                            "Simpan Transaksi",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
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
  // WIDGET
  // =====================================

  Widget buildSection({
    required String title,
    required Widget child,
  }) {

    return Container(

      width: double.infinity,

      padding: const EdgeInsets.all(16),

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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          child
        ],
      ),
    );
  }



  Widget buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool number = false,
    int maxLines = 1,
  }) {

    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 8),

        TextField(

          controller: controller,

          keyboardType:
              number
                  ? TextInputType.number
                  : TextInputType.text,

          maxLines: maxLines,

          onChanged: (_) {
            setState(() {});
          },

          decoration: InputDecoration(

            hintText: hint,

            filled: true,

            fillColor:
                const Color(0xFFF7F4FA),

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
    );
  }



  Widget paymentItem(
    String value,
    IconData icon,
  ) {

    bool selected =
        metode == value;

    return Expanded(

      child: GestureDetector(

        onTap: () {

          setState(() {
            metode = value;
          });
        },

        child: Container(

          padding:
              const EdgeInsets.symmetric(
            vertical: 16,
          ),

          decoration: BoxDecoration(

            color: selected
                ? const Color(0xFFF3E8FF)
                : Colors.white,

            borderRadius:
                BorderRadius.circular(
              14,
            ),

            border: Border.all(
              color: selected
                  ? const Color(
                      0xFF5B2DA3,
                    )
                  : Colors.grey.shade300,
            ),
          ),

          child: Column(

            children: [

              Icon(
                icon,
                color: selected
                    ? const Color(
                        0xFF5B2DA3,
                      )
                    : Colors.black54,
              ),

              const SizedBox(height: 8),

              Text(
                value,

                style: TextStyle(
                  color: selected
                      ? const Color(
                          0xFF5B2DA3,
                        )
                      : Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}