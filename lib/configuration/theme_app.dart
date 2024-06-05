import 'package:flutter/material.dart';


final ThemeData myTheme = ThemeData(
  primarySwatch:Colors.red,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.red,),
    appBarTheme: AppBarTheme(
    color:Colors.red,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white)

    )
  ),
  
  floatingActionButtonTheme:const FloatingActionButtonThemeData(
    backgroundColor: Color(0xffe21f1d ),
    foregroundColor: Colors.white),
    dialogTheme: const DialogTheme(
      backgroundColor: Color.fromARGB(255, 255, 255, 255)
    ),
   
);