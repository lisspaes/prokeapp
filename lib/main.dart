import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:pokemonprueba/configuration/theme_app.dart';
import 'package:pokemonprueba/services/firebase_notification.dart';
import 'package:pokemonprueba/firebase_options.dart';
import 'package:pokemonprueba/ui/home_screen.dart';
import 'package:pokemonprueba/ui/login_form.dart';


late Future<Database> pokeDb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  FirebaseConf().initNotifications();

  pokeDb = openDatabase(
    join(await getDatabasesPath(), 'pokemon_database.db'),
    
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE pokemon_favs(id INTEGER PRIMARY KEY, name TEXT, image TEXT)',
      );
    },
    version: 1,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? user;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: myTheme,
      home: 
      user != null 
      ? HomeScreen()
      : const LoginView()

    );
  }
}
