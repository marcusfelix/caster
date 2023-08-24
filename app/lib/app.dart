import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/hex_color.dart';
import 'package:app/views/auth.dart';
import 'package:app/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  const App({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    
    final services = ServiceContext.of(context).controller;

    // Setting up theme
    ThemeData theme(configs) => ThemeData.from(
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: HexColor(configs["seed_color"]),
      ),
    );

    return ValueListenableBuilder(
      valueListenable: services.configs,
      builder: (context, configs, _) {
        return MaterialApp(
          key: ValueKey(configs["key"] ?? "app"),
          title: configs["app_name_string"],
          navigatorObservers: <NavigatorObserver>[services.observer],
          debugShowCheckedModeBanner: false,
          theme: theme(configs).copyWith(
            appBarTheme: AppBarTheme(
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: theme(configs).colorScheme.onPrimary
              ),
              iconTheme: IconThemeData(
                color: theme(configs).colorScheme.onPrimary
              ),
              elevation: 0
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder()
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: theme(configs).colorScheme.tertiaryContainer,
              foregroundColor: theme(configs).colorScheme.onTertiaryContainer,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              disabledElevation: 0,
            ),
          ),
          home: StreamBuilder<User?>(
            stream: services.auth.authStateChanges(),
            builder: (context, user) {
              // Determine if check for user auth based on config
              if(configs["require_auth_bool"]){
                if(user.data != null){
                  return const Home();
                } else {
                  return Auth();
                }
              } else {
                return const Home();
              }
            }
          ),
        );
      }
    );
  }

}