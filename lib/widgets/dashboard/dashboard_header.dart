import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        Flexible(

          child: Row(
            children: [

              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.local_laundry_service,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              const Flexible(

                child: Text(
                  "Araku Shoes Care",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}