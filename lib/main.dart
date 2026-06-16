import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echoes_of_the_foundry_floor/initial_screen.dart';
import 'package:echoes_of_the_foundry_floor/providers/user_provider.dart';
import 'package:echoes_of_the_foundry_floor/screens/add_screen.dart';
import 'package:echoes_of_the_foundry_floor/screens/info_screen.dart';
import 'package:echoes_of_the_foundry_floor/screens/main_navigation.dart';
import 'package:echoes_of_the_foundry_floor/screens/showcase_screen.dart';
import 'package:echoes_of_the_foundry_floor/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: MyApp(preferences: preferences)));
}

class MyApp extends ConsumerWidget {
  final SharedPreferences preferences;
  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Echoes of the Foundry Floor',
            theme: appTheme,
            home: userProv.firstTimeUser
                ? const InitialScreen()
                : const MainNavigation(),
            routes: {
              '/home': (context) => const MainNavigation(),
              '/initial_screen': (context) => const InitialScreen(),
              '/showcase': (context) => const ShowcaseScreen(),
              '/add_screen': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return AddScreen(
                  isEdit: args['isEdit'] as bool? ?? false,
                  currentIndex: args['currentIndex'] as int? ?? 0,
                );
              },
              '/info_screen': (context) {
                final obj = ModalRoute.of(context)?.settings.arguments;
                int routeIndex = 0;
                if (obj is int) {
                  routeIndex = obj;
                } else if (obj is Map<String, dynamic>) {
                  routeIndex = obj['index'] as int? ?? 0;
                }
                return InfoScreen(index: routeIndex);
              },
            },
          ),
        );
      },
    );
  }
}
