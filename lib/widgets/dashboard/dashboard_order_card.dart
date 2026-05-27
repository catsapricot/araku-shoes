import 'package:flutter/material.dart';

class DashboardOrderCard extends StatelessWidget {

  final String invoice;
  final String customer;
  final String layanan;
  final String status;

  const DashboardOrderCard({
    super.key,
    required this.invoice,
    required this.customer,
    required this.layanan,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {

    Color statusColor =
        status == "Diproses"
            ? const Color(0xFF7C3AED)
            : status == "Menunggu"
                ? const Color(0xFFEAB308)
                : const Color(0xFF71717A);

    Color statusBg =
        status == "Diproses"
            ? const Color(0xFFF3E8FF)
            : status == "Menunggu"
                ? const Color(0xFFFEF9C3)
                : const Color(0xFFF4F4F5);

    return Container(

      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          // =====================================
          // TOP
          // =====================================

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
                      invoice,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      customer,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: statusBg,

                  borderRadius:
                      BorderRadius.circular(30),
                ),

                child: Row(

                  children: [

                    CircleAvatar(
                      radius: 4,
                      backgroundColor: statusColor,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      status,

                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 18),




          // =====================================
          // LAYANAN
          // =====================================

          Row(

            children: [

              Container(

                width: 42,
                height: 42,

                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F5),

                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.local_laundry_service,
                  color: Color(0xFF0F766E),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Layanan",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      layanan,

                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}