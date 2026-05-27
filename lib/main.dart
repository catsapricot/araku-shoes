import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/main_shell.dart';
import 'screens/setup/setup_wizard_page.dart';
import 'services/api_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  final hasUrl = await ApiService.hasApiUrl();

  runApp(MyApp(showSetup: !hasUrl));
}

class MyApp extends StatelessWidget {

  final bool showSetup;

  const MyApp({super.key, required this.showSetup});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Araku Shoes Care',

      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
      ),

      home: showSetup
          ? const SetupWizardPage()
          : const MainShell(),
    );
  }
}
