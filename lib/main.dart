import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'routes/app_router.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/hr_viewmodel.dart';
import 'viewmodels/nrm_viewmodel.dart';
import 'viewmodels/maintenance_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HrViewModel()),
        ChangeNotifierProvider(create: (_) => NrmViewModel()),
        ChangeNotifierProvider(create: (_) => MaintenanceViewModel()),
      ],
      child: const PMPApp(),
    ),
  );
}

class PMPApp extends StatelessWidget {
  const PMPApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PMP Application',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
