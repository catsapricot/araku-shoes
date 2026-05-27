import 'package:flutter/material.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          "Halo, Admin",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          "Minggu, 10 Mei 2026",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 24),




        // =================================
        // PEMASUKAN HARI INI
        // =================================

        Container(

          width: double.infinity,

          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(

            color: const Color(0xFFF7F8F8),

            borderRadius: BorderRadius.circular(20),
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
                        "Pemasukan Hari Ini",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Rp 450.000",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F766E),
                    ),
                  )
                ],
              ),

              Container(
                width: 70,
                height: 70,

                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 16),




        // =================================
        // MINI CARDS
        // =================================

        Row(

          children: [

            Expanded(

              child: Container(

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(

                  color: const Color(0xFFF7F8F8),

                  borderRadius: BorderRadius.circular(18),
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

                        const SizedBox(width: 4),

                        Text(
                          "Transaksi",
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Row(

                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [

                        Text(
                          "12",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 6),

                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 8),

                          child: Text(
                            "sepatu",
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

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(

                  color: const Color(0xFFEAF7F6),

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),

                        const SizedBox(width: 4),

                        const Text(
                          "Selesai",
                          style: TextStyle(
                            color: Color(0xFF0F766E),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Row(

                      crossAxisAlignment:
                          CrossAxisAlignment.end,

                      children: [

                        Text(
                          "5",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F766E),
                          ),
                        ),

                        SizedBox(width: 6),

                        Padding(
                          padding:
                              EdgeInsets.only(bottom: 8),

                          child: Text(
                            "diambil",
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}