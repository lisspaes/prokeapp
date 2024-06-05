import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pokemonprueba/main.dart';
import 'package:pokemonprueba/models/pokemon.dart';
import 'package:pokemonprueba/services/storage_service.dart';
import 'package:pokemonprueba/ui/login_form.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 209, 77, 77),
      body: PageView(children: [
        PokemonView(size: size),
        UserView(
          size: size,
        )
      ]),
    );
  }
}

class UserView extends StatelessWidget {
  UserView({
    super.key,
    required this.size,
    this.user,
  });
  final Size size;

  void exitUser(BuildContext context) {
    user != null ? auth.signOut : erasedAll(context);
  }

  void erasedAll(BuildContext context) async {
    await storageService.eliminarTodo();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user;
  static StorageService storageService = StorageService();

  Future<List<String>> loadPokemonFavs() async {
    final db = await pokeDb;
    final List<Map<String, dynamic>> savedPokemon =
        await db.query('pokemon_favs');
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'image': age as String,
          } in savedPokemon)
        name
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.2,
          width: size.width,
          child: ClipPath(
            clipper: EncabezadoUsuario(),
            child: Container(
              color: const Color.fromARGB(255, 186, 58, 49),
            ),
          ),
        ),
        Center(
            child: ListView(
          padding: EdgeInsets.only(top: 300, left: 20, right: 20),
          children: [
            Text("Favoritos"),
            SizedBox(height: 20,),
            FutureBuilder(
                future: loadPokemonFavs(),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data ?? [];

                    return Column(
                      children: data
                          .map((p) => Container(
                                width: 200,
                                height: 50,
                                color: Colors.white,
                                child: Center(child: Text(p)),
                                
                              ))
                          .toList(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text("error");
                  }

                  return Text("cargando");
                }),
          ],
        )),
        Positioned(
          bottom: 40,
          right: 40,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            label: Text("Salir"),
            onPressed: () {
              exitUser(context);
            },
            icon: const Icon(Icons.navigate_next),
          ),
        )
      ],
    );
  }
}

class PokemonView extends StatefulWidget {
  const PokemonView({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<PokemonView> createState() => _PokemonViewState();
}

class _PokemonViewState extends State<PokemonView> {
  Pokemon? pokemon;
  int pokemonId = 0;
  bool isFav = false;

  @override
  void initState() {
    getPokemon();
    super.initState();
  }

  Future<void> getPokemon() async {
    pokemonId++;
    final response =
        await Dio().get('https://pokeapi.co/api/v2/pokemon/$pokemonId');
    pokemon = Pokemon.fromJson(response.data);
    
    final db = await pokeDb;
    final pokemonExists = await db.query('pokemon_favs', where: 'id = ?', whereArgs: [pokemon!.id]);
    isFav = pokemonExists.length > 0;

    setState(() {});
  }

  void savePokemonFav() async {
    if (pokemon == null) return;

    final db = await pokeDb;

    final pokemonExists = await db.query('pokemon_favs', where: 'id = ?', whereArgs: [pokemon!.id]);

    if(pokemonExists.length > 0){
      await db.delete('pokemon_favs', where: 'id = ?', whereArgs: [pokemon!.id]);
      isFav = false;
      setState(() {});
      return;
    }

    await db.insert(
      'pokemon_favs',
      pokemon!.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    isFav = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.size.height * 0.2,
          width: widget.size.width,
          child: ClipPath(
            clipper: Encabezado(),
            child: Container(
              color: const Color.fromARGB(255, 186, 58, 49),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 70,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 100,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow,
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 130,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
        ),
        Positioned(
          top: 270,
          right: 30,
          child: IconButton(
            onPressed: savePokemonFav,
            icon: Icon(
              Icons.star,
              size: 40,
              color: isFav ? Colors.yellow : Colors.grey,
            ),
          ),
        ),
        Center(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            height: widget.size.height * 0.3,
            width: widget.size.width * 0.8,
            child: Container(
              height: widget.size.height * 0.2,
              width: widget.size.width * 0.4,
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: const Color.fromARGB(255, 119, 181, 232),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -40,
                        right: -10,
                        height: 200,
                        child: Opacity(
                            opacity: 0.5,
                            child: Image.asset('assets/pokeball.png')),
                      ),
                      if (pokemon != null) ...[
                        Positioned(
                            bottom: -50,
                            right: -20,
                            child: Image.network(
                              pokemon!.sprites.frontDefault,
                              height: 300,
                              fit: BoxFit.fitHeight,
                            ))
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 210,
          left: 40,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          bottom: 225,
          left: 100,
          child: Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.yellow,
            ),
          ),
        ),
        Positioned(
          bottom: 225,
          left: 180,
          child: Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
            bottom: 150,
            left: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Text(
                  pokemon?.name ?? 'Sin datos',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            )),
        Positioned(
            bottom: 40,
            left: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pokemon ID: ${pokemon?.id ?? "Deconocido"}'),
                      Text('Altura: ${pokemon?.height ?? "Desconocido"}'),
                      Text('Peso: ${pokemon?.weight ?? "Desconocido"}'),
                      Text(
                          'Movimiento: ${pokemon?.moves[0].move.name ?? "Desconocido"}')
                    ]),
              ),
            )),
        Positioned(
          bottom: 40,
          right: 40,
          child: FloatingActionButton(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            onPressed: getPokemon,
            child: const Icon(Icons.navigate_next),
          ),
        )
      ],
    );
  }
}

class Encabezado extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width, 0.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class EncabezadoUsuario extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
