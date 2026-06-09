import 'package:flutter/material.dart';

import '../input_order/input_order_page.dart';

class ReceiptPage extends StatelessWidget {

  final String invoice;

  final List cart;

  final String metode;

  final String statusBayar;

  final int total;

  const ReceiptPage({

    super.key,

    required this.invoice,

    required this.cart,

    required this.metode,

    this.statusBayar = "Lunas",

    required this.total,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            children: [

              const SizedBox(height: 10),



              // =====================================
              // HEADER
              // =====================================

              const Row(

                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [

                  Icon(Icons.storefront_outlined),

                  Text(

                    "Araku Shoes Care",

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  Icon(Icons.cloud_done_outlined),
                ],
              ),

              const SizedBox(height: 40),



              // =====================================
              // SUCCESS ICON
              // =====================================

              Container(

                width: 100,
                height: 100,

                decoration: const BoxDecoration(

                  color: Color(0xFFEDE9FE),

                  shape: BoxShape.circle,
                ),

                child: const Icon(

                  Icons.check,

                  size: 55,

                  color: Color(0xFF5B2DA3),
                ),
              ),

              const SizedBox(height: 24),



              // =====================================
              // TITLE
              // =====================================

              const Text(

                "Pembayaran Berhasil",

                style: TextStyle(

                  fontSize: 34,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),



              // =====================================
              // RECEIPT CARD
              // =====================================

              Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.all(22),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                ),

                child: Column(

                  children: [

                    const Text(
                      "Nomor Transaksi",
                    ),

                    const SizedBox(height: 8),

                    Text(

                      invoice,

                      style: const TextStyle(

                        fontSize: 30,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(

                      DateTime.now()
                          .toString(),

                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Divider(),

                    const SizedBox(height: 20),



                    // =====================================
                    // MULTI ITEM
                    // =====================================

                    Column(

                      children: [

                        ...cart.map((item) {

                          return Padding(

                            padding:
                                const EdgeInsets.only(
                              bottom: 18,
                            ),

                            child: Row(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Expanded(

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(

                                        item["layanan"],

                                        style:
                                            const TextStyle(

                                          fontSize: 16,

                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(
                                          height: 6),

                                      Text(

                                        "${item["qty"]}x",

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Text(

                                  "Rp ${item["subtotal"]}",

                                  style:
                                      const TextStyle(

                                    fontSize: 18,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Divider(),

                    const SizedBox(height: 24),



                    // =====================================
                    // PAYMENT
                    // =====================================

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(
                          "Metode Pembayaran",
                        ),

                        Text(

                          metode,

                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        const Text(
                          "Status Pembayaran",
                        ),

                        Container(

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(

                            color: statusBayar == "Lunas"
                                ? const Color(0xFFE6F4F1)
                                : const Color(0xFFFDF3E7),

                            borderRadius:
                                BorderRadius.circular(12),
                          ),

                          child: Text(

                            statusBayar,

                            style: TextStyle(

                              color: statusBayar == "Lunas"
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFFB45309),

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 13,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 30),



                    // =====================================
                    // TOTAL BOX
                    // =====================================

                    Container(

                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(22),

                      decoration: BoxDecoration(

                        color:
                            const Color(0xFFF7F4FA),

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Column(

                        children: [

                          const Text(
                            "Total Pembayaran",
                          ),

                          const SizedBox(height: 10),

                          Text(

                            "Rp $total",

                            style: const TextStyle(

                              fontSize: 38,

                              fontWeight:
                                  FontWeight.bold,

                              color:
                                  Color(0xFF5B2DA3),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),



                    // =====================================
                    // SAVED
                    // =====================================

                    Container(

                      width: double.infinity,

                      padding:
                          const EdgeInsets.all(14),

                      decoration: BoxDecoration(

                        color:
                            const Color(0xFFEDE9FE),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: const Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Icon(

                            Icons.check_circle,

                            size: 18,

                            color:
                                Color(0xFF5B2DA3),
                          ),

                          SizedBox(width: 8),

                          Text(
                            "Tersimpan ke Google Sheets",
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),



              // =====================================
              // BACK BUTTON
              // =====================================

              SizedBox(

                width: double.infinity,

                height: 58,

                child: OutlinedButton(

                  onPressed: () {

                    Navigator.popUntil(

                      context,

                      (route) => route.isFirst,
                    );
                  },

                  style:
                      OutlinedButton.styleFrom(

                    side: const BorderSide(
                      color: Color(0xFF5B2DA3),
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: const Text(

                    "Kembali ke Dashboard",

                    style: TextStyle(

                      color:
                          Color(0xFF5B2DA3),

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),



              // =====================================
              // NEW TRANSACTION
              // =====================================

              SizedBox(

                width: double.infinity,

                height: 58,

                child: ElevatedButton(

                  onPressed: () {

                    // Buka halaman tambah transaksi baru,
                    // mengganti struk ini di stack supaya
                    // tidak menumpuk halaman.
                    Navigator.pushReplacement(

                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            const InputOrderPage(),
                      ),
                    );
                  },

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(0xFF5B2DA3),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: const Text(

                    "Transaksi Baru",

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
      ),
    );
  }
}
