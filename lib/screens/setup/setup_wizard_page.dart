import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../main_shell.dart';

class SetupWizardPage extends StatefulWidget {
  const SetupWizardPage({super.key});

  @override
  State<SetupWizardPage> createState() =>
      _SetupWizardPageState();
}

class _SetupWizardPageState
    extends State<SetupWizardPage> {

  // =====================================
  // CONSTANTS
  // =====================================

  static const Color kPrimary = Color(0xFF5B2DA3);
  static const Color kTeal    = Color(0xFF0F766E);
  static const Color kBg      = Color(0xFFF6F7FB);

  static const String _templateUrl =
      "https://docs.google.com/spreadsheets/d/10qS02lCHgbLnMrh71aVIIDpNPibxA1BWi1ZooourEdw/copy";



  // =====================================
  // STATE
  // =====================================

  final PageController        _pageCtrl  = PageController();
  final TextEditingController _urlCtrl   = TextEditingController();

  bool _isValidating = false;



  @override
  void dispose() {
    _pageCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }



  // =====================================
  // NAVIGATION
  // =====================================

  void _nextPage() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }



  // =====================================
  // OPEN TEMPLATE URL
  // =====================================

  Future<void> _openTemplate() async {
    final uri = Uri.parse(_templateUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Tidak dapat membuka browser. "
            "Pastikan browser sudah terinstall.",
          ),
        ),
      );
    }
  }



  // =====================================
  // VALIDATE + SAVE BACKEND URL
  // =====================================

  Future<void> _validateAndSave() async {

    final url = _urlCtrl.text.trim();

    // ── Basic format check ──────────────
    if (url.isEmpty) {
      _showError(
        "URL tidak boleh kosong.",
        "URL cannot be empty.",
      );
      return;
    }

    if (!url.contains("script.google.com") ||
        !url.endsWith("/exec")) {
      _showError(
        "URL tidak valid.\n"
        "Pastikan URL berakhir dengan /exec",
        "Invalid URL. Make sure it ends with /exec.",
      );
      return;
    }

    setState(() => _isValidating = true);

    try {

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 12));

      final body = jsonDecode(response.body);

      if (body is Map && body["message"] == "API Active") {

        await ApiService.saveApiUrl(url);

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MainShell(),
          ),
        );

        return;
      }

      // Backend responded but payload wrong
      if (!mounted) return;
      _showError(
        "Backend tidak merespons dengan benar.\n"
        "Pastikan Apps Script sudah di-deploy ulang.",
        "Backend responded incorrectly. "
        "Make sure your Apps Script is properly deployed.",
      );

    } catch (_) {

      if (!mounted) return;
      _showError(
        "Tidak dapat terhubung ke backend.\n"
        "Periksa URL dan koneksi internet Anda.",
        "Cannot connect to backend. "
        "Check your URL and internet connection.",
      );
    }

    if (mounted) setState(() => _isValidating = false);
  }



  // =====================================
  // ERROR DIALOG
  // =====================================

  void _showError(String id, String en) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "URL Tidak Valid",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 8),
            Text(
              en,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),

        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }



  // =====================================
  // BUILD
  // =====================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: kBg,

      body: SafeArea(

        child: PageView(

          controller: _pageCtrl,

          // Disable swipe — user must tap buttons
          physics: const NeverScrollableScrollPhysics(),

          children: [
            _buildWelcome(),
            _buildStep1(),
            _buildStep2(),
            _buildStep3(),
            _buildStep4(),
          ],
        ),
      ),
    );
  }



  // =====================================
  // PAGE 0 — WELCOME
  // =====================================

  Widget _buildWelcome() {

    return SingleChildScrollView(

      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 40,
      ),

      child: Column(

        children: [

          const SizedBox(height: 40),

          // App icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 50,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            "Araku Shoes Care 👋",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Setup Google Spreadsheet Anda untuk mulai menggunakan aplikasi.",
                  style: TextStyle(fontSize: 15, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Setup your Google Spreadsheet to start using the app.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoPill(Icons.timer_outlined, "~5 menit"),
              const SizedBox(width: 10),
              _infoPill(Icons.cloud_outlined, "Google Spreadsheet"),
            ],
          ),

          const SizedBox(height: 48),

          // CTA button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Mulai Setup",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Start Setup",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: kPrimary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }



  // =====================================
  // STEP SHELL (pages 1–4)
  // =====================================

  Widget _buildStepShell({
    required int step,
    required IconData icon,
    required String titleId,
    required String titleEn,
    required Widget content,
    required Widget action,
  }) {

    return Column(

      children: [

        // ── Gradient header ──────────────
        Container(

          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft:  Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),

          child: Column(

            children: [

              // Step dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (i) => _stepDot(i + 1, step),
                ),
              ),

              const SizedBox(height: 22),

              // Icon circle
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, color: Colors.white, size: 38),
              ),

              const SizedBox(height: 16),

              Text(
                "Langkah $step dari 4",
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                titleId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                titleEn,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // ── Scrollable content ───────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 24),
                action,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepDot(int dot, int current) {
    final bool active = dot == current;
    final bool done   = dot < current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width:  active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: (active || done) ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }



  // =====================================
  // STEP 1 — Copy Spreadsheet
  // =====================================

  Widget _buildStep1() {

    return _buildStepShell(
      step: 1,
      icon: Icons.file_copy_outlined,
      titleId: "Copy Spreadsheet Template",
      titleEn: "Copy the Spreadsheet Template",

      content: Column(
        children: [

          _descCard(
            id: "Klik tombol di bawah untuk menyalin template ke Google Drive Anda.",
            en: "Click the button below to copy the template to your Google Drive.",
          ),

          const SizedBox(height: 14),

          _infoBox(
            icon: Icons.info_outline,
            color: kPrimary,
            id: "Google akan menampilkan dialog \"Buat Salinan\". Klik tombol tersebut untuk menyalin.",
            en: "Google will show a \"Make a copy\" dialog. Click it to save the copy.",
          ),

          const SizedBox(height: 14),

          _infoBox(
            icon: Icons.auto_awesome_outlined,
            color: kTeal,
            id: "Apps Script sudah otomatis tersedia di dalam spreadsheet — tidak perlu paste kode apapun.",
            en: "Apps Script is already included — no manual coding needed.",
          ),
        ],
      ),

      action: Column(

        children: [

          // Primary: open template
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _openTemplate,
              icon: const Icon(
                Icons.open_in_new,
                color: Colors.white,
                size: 18,
              ),
              label: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Copy Spreadsheet Template",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Buka di browser",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                elevation: 0,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Secondary: already done → next step
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: _nextPage,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah Disalin →",
                    style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Already copied →",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // =====================================
  // STEP 2 — Open Apps Script
  // =====================================

  Widget _buildStep2() {

    return _buildStepShell(
      step: 2,
      icon: Icons.code_outlined,
      titleId: "Buka Apps Script",
      titleEn: "Open Apps Script",

      content: Column(
        children: [

          _descCard(
            id: "Buka spreadsheet hasil salinan, lalu navigasi ke menu Extensions.",
            en: "Open your copied spreadsheet, then navigate to the Extensions menu.",
          ),

          const SizedBox(height: 14),

          _stepListCard(const [
            ("Buka spreadsheet hasil salinan",
             "Open your copied spreadsheet"),
            ("Klik menu Extensions di toolbar atas",
             "Click Extensions in the top toolbar"),
            ("Pilih Apps Script",
             "Select Apps Script"),
          ]),

          const SizedBox(height: 14),

          _infoBox(
            icon: Icons.check_circle_outline,
            color: kTeal,
            id: "Apps Script sudah berisi semua kode yang diperlukan — tidak perlu input atau edit kode apapun.",
            en: "Apps Script is pre-configured with all required code. No editing needed.",
          ),
        ],
      ),

      action: _nextBtn(),
    );
  }



  // =====================================
  // STEP 3 — Deploy Web App
  // =====================================

  Widget _buildStep3() {

    return _buildStepShell(
      step: 3,
      icon: Icons.rocket_launch_outlined,
      titleId: "Deploy Web App",
      titleEn: "Deploy as Web App",

      content: Column(
        children: [

          _descCard(
            id: "Di halaman Apps Script, deploy script sebagai Web App.",
            en: "In the Apps Script editor, deploy your script as a Web App.",
          ),

          const SizedBox(height: 14),

          _stepListCard(const [
            ("Klik tombol Deploy (pojok kanan atas)",
             "Click the Deploy button (top right)"),
            ("Pilih New Deployment",
             "Choose New Deployment"),
            ("Pilih type: Web App",
             "Select type: Web App"),
            ("Who has access → Anyone",
             "Who has access → Anyone"),
            ("Klik Deploy, lalu klik Authorize jika diminta",
             "Click Deploy, then Authorize if prompted"),
            ("Copy URL yang muncul",
             "Copy the URL that appears"),
          ]),

          const SizedBox(height: 14),

          _warningBox(
            id: "Pastikan URL berakhir dengan /exec\nContoh: ...script.google.com/macros/s/xxx/exec",
            en: "The URL must end with /exec",
          ),
        ],
      ),

      action: _nextBtn(),
    );
  }



  // =====================================
  // STEP 4 — Paste URL
  // =====================================

  Widget _buildStep4() {

    return _buildStepShell(
      step: 4,
      icon: Icons.link_outlined,
      titleId: "Paste URL Backend",
      titleEn: "Paste the Backend URL",

      content: Column(
        children: [

          _descCard(
            id: "Paste URL /exec yang Anda copy dari deployment Apps Script tadi.",
            en: "Paste the /exec URL you copied from your Apps Script deployment.",
          ),

          const SizedBox(height: 14),

          // URL text field
          TextField(
            controller: _urlCtrl,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              hintText:
                  "https://script.google.com/macros/s/.../exec",
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.link,
                color: kPrimary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: kPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          _infoBox(
            icon: Icons.verified_outlined,
            color: kTeal,
            id: "Aplikasi akan memverifikasi koneksi ke backend sebelum menyimpan.",
            en: "The app will verify the backend connection before saving.",
          ),
        ],
      ),

      action: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _isValidating ? null : _validateAndSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: kTeal,
            elevation: 0,
            disabledBackgroundColor:
                kTeal.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isValidating
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Memverifikasi...",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Verifying...",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Simpan & Mulai",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Save & Start",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }



  // =====================================
  // SHARED HELPER WIDGETS
  // =====================================

  Widget _nextBtn() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Lanjut →",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Continue →",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _descCard({required String id, required String en}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            id,
            style: const TextStyle(fontSize: 14, height: 1.55),
          ),
          const SizedBox(height: 6),
          Text(
            en,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String id,
    required String en,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  en,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _warningBox({required String id, required String en}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  en,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB45309),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Each entry: (Indonesian text, English text)
  Widget _stepListCard(
    List<(String, String)> items,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final (id, en) = items[i];
          final isLast = i == items.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "${i + 1}",
                      style: const TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        id,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        en,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
