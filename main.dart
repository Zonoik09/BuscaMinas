import 'dart:io';
import 'dart:math';

void main() {
  List<dynamic> tablero = generarTablero(9, 6);
  List<dynamic> tableroConBombas = generarTableroConBombas(9,6);
  // Imprimir el tablero
  while (true) {
    imprimirTablero(tablero);
    print("Commanda: ");
    String? input = stdin.readLineSync();

    switch (input) {
      case "flag": // Esto capaz lo tengo que cambiar porque se tiene que poner
        // se establece la bandera
      case "cheat":
        // muestra la trampa
        imprimirTablero(tableroConBombas);
      case "ajuda":
        //Pone los comandos
        print("Cheats o trampes: Mostra el tauler amb les bombes.");
        print("Flag o bandera: Pots posar una bandera en la casella que vols. Per exemple: > B5 flag");
        print("Per marcar una casilla has de posar la lletra y el numero correspondent. Per exemple: > B5");
    }
  }
}

List<dynamic> generarTablero(int column, int row) {
  List<String> letras = ["A","B","C","D","F","G","H"];
  List matriz = [[" ",1,2,3,4,5,6,7,8,9]];
  for (int i = 0; i<=row-1;i++) {
    List lista = [];
    lista.add(letras[i]);
    for (int y = 0; y<=column-1;y++) {
      lista.add("·");
    }
    matriz.add(lista);
  }

  return matriz;
}

void imprimirTablero(List<dynamic> tablero) {
  for (var fila in tablero) {
    // Convierte cada fila a una cadena separada por espacios
    print(fila.join(' '));
  }
}



/*
// Retorna 'true' si explota 'false' altrament
funció destapaCasella(tauler, x, y, esPrimeraJugada, esJugadaUsuari)
   si (x, y) és fora dels límits o ja descoberta o té bandera
       retorna false

   si (x, y) és bomba
       si esPrimeraJugada
           mou la bomba a una posició buida aleatòria
       sinó si esJugadaUsuari
           retorna true  // Indica explosió
       sinó
           retorna false // No explota durant la recursivitat

   numMines = comptaMinesAdjacents(tauler, x, y)
   marca (x, y) com descoberta amb numMines

   si numMines == 0:
       per cada (dx, dy) al voltant:
           destapaCasella(tauler, x + dx, y + dy, false, false)

   retorna false // No explota
 */

// Arreglar toda esta parte.
List<List<dynamic>> generarTableroConBombas(int columnas, int filas) {
  List<String> letras = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"];
  List<List<dynamic>> tablero = [];

  // Crear encabezado del tablero
  tablero.add([" ", for (int i = 1; i <= columnas; i++) i]);

  // Crear filas con celdas vacías
  for (int i = 0; i < filas-1; i++) {
    List<dynamic> fila = [letras[i]];
    for (int j = 0; j < columnas-1; j++) {
      fila.add("·");
    }
    tablero.add(fila);
  }

  // Colocar las bombas
  colocarBombas(tablero, columnas, filas);

  return tablero;
}

void colocarBombas(List<List<dynamic>> tablero, int columnas, int filas) {
  Random random = Random();
  int totalBombas = 8;
  int bombasPorCuadrante = 2;

  // Función auxiliar para añadir bombas
  void anadirBombas(int startX, int endX, int startY, int endY, int bombasNecesarias) {
    int bombasAnadidas = 0;
      while (bombasAnadidas < bombasNecesarias) {
      int x = random.nextInt(endX - startX + 1) + startX;
      int y = random.nextInt(endY - startY + 1) + startY;
        if (tablero[y + 1][x + 1] != "*") {
        tablero[y + 1][x + 1] = "*";
        bombasAnadidas++;
        }
    }
  }

  anadirBombas(0, columnas ~/ 2 - 1, 0, filas ~/ 2 - 1, bombasPorCuadrante);
  anadirBombas(columnas ~/ 2, columnas - 1, 0, filas ~/ 2 - 1, bombasPorCuadrante);
  anadirBombas(0, columnas ~/ 2 - 1, filas ~/ 2, filas - 1, bombasPorCuadrante);
  anadirBombas(columnas ~/ 2, columnas - 1, filas ~/ 2, filas - 1, bombasPorCuadrante);
}





