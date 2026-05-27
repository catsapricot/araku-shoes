import 'package:flutter/material.dart';

import 'home/home_page.dart';
import 'history/history_page.dart';
import 'rekap/rekap_page.dart';

// =============================================
// MAIN SHELL
// Satu-satunya tempat bottom navigation bar.
// IndexedStack mempertahankan state tiap tab
// sehingga tidak ada duplicate page di stack.
// =============================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState
    extends State<MainShell> {

  // ==========================================
  // INDEX TAB AKTIF
  // ==========================================

  int _currentIndex = 0;



  // ==========================================
  // PAGES — const agar tidak di-rebuild
  // ==========================================

  static const List<Widget> _pages = [
    HomePage(),
    HistoryPage(),
    RekapPage(),
  ];



  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // IndexedStack menjaga state semua tab.
      // Tidak ada Navigator.push antar tab,
      // cukup setState currentIndex.

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),



      // ==========================================
      // BOTTOM NAVIGATION BAR — hanya di sini
      // ==========================================

      bottomNavigationBar: Container(

        height: 72,

        decoration: const BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceAround,

          children: [

            _navItem(
              index: 0,
              icon: Icons.home_outlined,
              label: "Home",
            ),

            _navItem(
              index: 1,
              icon: Icons.history,
              label: "Riwayat",
            ),

            _navItem(
              index: 2,
              icon: Icons.receipt_long_outlined,
              label: "Rekap",
            ),
          ],
        ),
      ),
    );
  }



  // ==========================================
  // NAV ITEM WIDGET
  // ==========================================

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {

    final bool active = _currentIndex == index;

    const Color kActive   = Color(0xFF5B2DA3);
    const Color kInactive = Colors.black54;

    return GestureDetector(

      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: active ? kActive : kInactive,
          ),

          const SizedBox(height: 4),

          Text(

            label,

            style: TextStyle(

              color: active ? kActive : kInactive,

              fontWeight: active
                  ? FontWeight.bold
                  : FontWeight.normal,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
