import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DataOrderPage extends StatefulWidget {
  const DataOrderPage({super.key});

  @override
  State<DataOrderPage> createState() => _DataOrderPageState();
}

class _DataOrderPageState extends State<DataOrderPage> {

  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbzE5GT3hHsNkTP7PVlxng79VBCwRiTqi0UolVR3-lSdUR_nah-l_7ZvAR9aKv-N-lBt/exec";

  List orders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOrders();
  }

    Future<void> updateStatus(int id) async {

    try {

      await http.post(

        Uri.parse(apiUrl),

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "action": "update",
          "id": id,
          "status": "Selesai"

        }),
      );

      getOrders();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

    Future<void> getOrders() async {

      try {

        final response = await http.get(
          Uri.parse("$apiUrl?all=true"),
        );

        print(response.body);

        final data = jsonDecode(response.body);

        setState(() {
          orders = data;
          isLoading = false;
        });

      } catch (e) {

        setState(() {
          isLoading = false;
        });
      }
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Data Order"),
      ),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : ListView.builder(

              padding: const EdgeInsets.all(16),

              itemCount: orders.length,

              itemBuilder: (context, index) {

                final order = orders[index];

                return Container(

                  margin: const EdgeInsets.only(bottom: 16),

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(20),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          Text(
                            order["nama"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: order["status"] == "Selesai"
                                  ? Colors.green
                                  : Colors.orange,

                              borderRadius:
                                  BorderRadius.circular(12),
                            ),

                            child: Text(
                              order["status"],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        order["layanan"],
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Rp ${NumberFormat('#,###').format(order["total"])}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            updateStatus(order["id"]);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),

                          child: const Text(
                            "Selesaikan Order",
                          ),
                        ),
                      )

                    ],
                  ),
                );
              },
            ),
    );
  }
}