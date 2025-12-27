import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:messenger_like_app/src/core/modules/connection_checker_module.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/controllers/chat_controller.dart';
import 'src/core/theme/app_theme.dart';
import 'src/repositories/auth_repository.dart';
import 'src/repositories/chat_repository.dart';
import 'src/repositories/supabase_auth_repository.dart';
import 'src/repositories/supabase_chat_repository.dart';
import 'src/views/widgets/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await Supabase.initialize(url: 'https://ohaahwijqpwqltevvxjv.supabase.co', anonKey: 'sb_publishable_Ti1kfFmFQFPt4zXFwUJXjA_oGNIgy5e');
  } catch (e) {
    debugPrint("Supabase Init Error: $e");
  }

  final authRepo = SupabaseAuthRepository();
  await authRepo.initialize();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepo),
        Provider<ChatRepository>(create: (_) => SupabaseChatRepository()),
        ChangeNotifierProvider(create: (context) => ChatController(repository: context.read<ChatRepository>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Messenger Clone',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) => ConnectionCheckerModule(child: child),
        );
      },
    );
  }
}
