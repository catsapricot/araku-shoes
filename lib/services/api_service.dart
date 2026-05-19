import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // =====================================
  // DEFAULT URL
  // =====================================

  static const String defaultUrl =

      "https://script.google.com/macros/s/AKfycbzE5GT3hHsNkTP7PVlxng79VBCwRiTqi0UolVR3-lSdUR_nah-l_7ZvAR9aKv-N-lBt/exec";



  // =====================================
  // SAVE URL
  // =====================================

  static Future<void> saveApiUrl(
    String url,
  ) async {

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      "api_url",
      url,
    );
  }



  // =====================================
  // GET URL
  // =====================================

  static Future<String> getApiUrl()
  async {

    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
          "api_url",
        ) ??
        defaultUrl;
  }
}