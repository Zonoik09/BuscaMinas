import 'dart:io';
import 'dart:math';

void main() {
  int columnes = 9;
  int files = 6;
  List<List<String>> tablero = generarTablero(columnes, files);
  List<List<String>> tableroConBombas = generarTableroConBombas(columnes, files);
  bool juegoTerminado = false;
  bool modoTrampa = false;
  int jugadas = 0;

  while (!juegoTerminado) {
    // Mostrar los tableros dependiendo del modo trampa
    if (modoTrampa) {
      imprimirTableroConBombas(tablero, tableroConBombas);
    } else {
      imprimirTablero(tablero);
    }

    print("\nEscriu una comanda:");
    String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) continue;

    // Activar o desactivar el modo trampa
    if (input.toLowerCase() == "cheat" || input.toLowerCase() == "trampes") {
      modoTrampa = true;
      print("Mode trampa activat! Es mostren els tresors.");
      continue;
    } else if (input.toLowerCase() == "disable-cheat" || input.toLowerCase() == "sortir-trampes") {
      modoTrampa = false;
      print("Mode trampa desactivat! Torna a jugar normalment.");
      continue;
    }

    // Mostrar ayuda
    if (input.toLowerCase() == "help" || input.toLowerCase() == "ajuda") {
      print("""Comandes disponibles:
- [lletra][número]: Escollir casella (exemple: B5)
- [lletra][número] flag o bandera: Posar o treure una bandera
- cheat o trampes: Mostrar el tauler amb les mines (activar mode trampa)
- disable-cheat o sortir-trampes: Amagar el tauler amb les mines
- help o ajuda: Mostrar aquest missatge
      """);
      continue;
    }

    // Validar entrada de jugadas
    RegExp regex = RegExp(r"^([a-fA-F])(\d+)(\s*(flag|FLAG|bandera|BANDERA))?$");
    Match? match = regex.firstMatch(input);

    if (match != null) {
      String filaLetra = match.group(1)!.toUpperCase();
      int columna = int.parse(match.group(2)!) - 1;
      bool esBandera = match.group(4) != null;

      int fila = filaLetra.codeUnitAt(0) - 'A'.codeUnitAt(0);

      if (fila < 0 || fila >= files || columna < 0 || columna >= columnes) {
        print("Posició fora del tauler!");
        continue;
      }

      if (esBandera) {
        bool banderaColocada = colocaBandera(tablero, columna, fila);
        if (banderaColocada) {
          print("Bandera colocada en $filaLetra${columna + 1}");
        } else {
          print("Bandera retirada de $filaLetra${columna + 1}");
        }
      } else {
        // Destapar casilla
        if (destapaCasella(tablero, tableroConBombas, columna, fila, jugadas == 0, true)) {
          print("Has perdut!");
          imprimirTableroConBombas(tablero, tableroConBombas);
          juegoTerminado = true;
        } else {
          jugadas++;
        }

        // Verificar si se ha ganado el juego
        if (jocCompletat(tablero, tableroConBombas)) {
          print("Enhorabona! Has completat el tauler en $jugadas jugades.");
          imprimirTableroConBombas(tablero, tableroConBombas);
          juegoTerminado = true;
        }
      }
    } else {
      print("Comanda no vàlida. Escriu 'ajuda' per veure les comandes disponibles.");
    }
  }
}

List<List<String>> generarTablero(int columnes, int files) {
  List<String> lletres = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"];
  List<List<String>> tablero = [];

  tablero.add([" ", for (int i = 1; i <= columnes; i++) i.toString()]);

  for (int i = 0; i < files; i++) {
    List<String> fila = [lletres[i]];
    for (int j = 0; j < columnes; j++) {
      fila.add("·");
    }
    tablero.add(fila);
  }

  return tablero;
}

List<List<String>> generarTableroConBombas(int columnes, int files) {
  List<List<String>> tablero = generarTablero(columnes, files);
  colocarBombas(tablero, columnes, files);
  return tablero;
}

void colocarBombas(List<List<String>> tablero, int columnes, int files) {
  Random random = Random();
  int totalBombas = 8;
  int bombasPorCuadrante = 2;

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

  anadirBombas(0, columnes ~/ 2 - 1, 0, files ~/ 2 - 1, bombasPorCuadrante);
  anadirBombas(columnes ~/ 2, columnes - 1, 0, files ~/ 2 - 1, bombasPorCuadrante);
  anadirBombas(0, columnes ~/ 2 - 1, files ~/ 2, files - 1, bombasPorCuadrante);
  anadirBombas(columnes ~/ 2, columnes - 1, files ~/ 2, files - 1, bombasPorCuadrante);
}

bool colocaBandera(List<List<String>> tablero, int columna, int fila) {
  if (tablero[fila + 1][columna + 1] == "#") {
    // Si ya hay una bandera, la quita
    tablero[fila + 1][columna + 1] = "·";
    return false; // Indica que se ha retirado la bandera
  } else if (tablero[fila + 1][columna + 1] == "·") {
    // Si está vacía, coloca la bandera
    tablero[fila + 1][columna + 1] = "#";
    return true; // Indica que se ha colocado la bandera
  } else {
    print("No puedes colocar una bandera aquí!");
    return false;
  }
}

bool destapaCasella(List<List<String>> tablero, List<List<String>> tableroConBombas, int x, int y, bool esPrimeraJugada, bool esJugadaUsuari) {
  if (x < 0 || x >= tablero[0].length - 1 || y < 0 || y >= tablero.length - 1 || tablero[y + 1][x + 1] != "·") {
    return false;
  }

  if (tableroConBombas[y + 1][x + 1] == "*") {
    if (esPrimeraJugada) {
      moverBomba(tableroConBombas, x, y);
      return false;
    } else if (esJugadaUsuari) {
      return true;
    } else {
      return false;
    }
  }

  int numMines = comptaMinesAdjacents(tableroConBombas, x, y);
  tablero[y + 1][x + 1] = numMines == 0 ? " " : numMines.toString();

  if (numMines == 0) {
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        if (dx != 0 || dy != 0) {
          destapaCasella(tablero, tableroConBombas, x + dx, y + dy, false, false);
        }
      }
    }
  }

  return false;
}

void moverBomba(List<List<String>> tableroConBombas, int x, int y) {
  for (int i = 1; i < tableroConBombas.length; i++) {
    for (int j = 1; j < tableroConBombas[i].length; j++) {
      if (tableroConBombas[i][j] == "·") {
        tableroConBombas[i][j] = "*";
        tableroConBombas[y + 1][x + 1] = "·";
        return;
      }
    }
  }
}

int comptaMinesAdjacents(List<List<String>> tablero, int x, int y) {
  int comptador = 0;

  for (int dx = -1; dx <= 1; dx++) {
    for (int dy = -1; dy <= 1; dy++) {
      if (dx != 0 || dy != 0) {
        int nx = x + dx;
        int ny = y + dy;

        if (nx >= 0 && nx < tablero[0].length - 1 && ny >= 0 && ny < tablero.length - 1 && tablero[ny + 1][nx + 1] == "*") {
          comptador++;
        }
      }
    }
  }

  return comptador;
}

void imprimirTablero(List<List<String>> tablero) {
  for (var fila in tablero) {
    print(fila.join(" "));
  }
}

void imprimirTableroConBombas(List<List<String>> tablero, List<List<String>> tableroConBombas) {
  print("Tauler amb trampa activat!");
  for (int i = 0; i < tablero.length; i++) {
    print(tablero[i].join(' ') + "   " + tableroConBombas[i].join(' '));
  }
}

bool jocCompletat(List<List<String>> tablero, List<List<String>> tableroConBombas) {
  for (int i = 1; i < tablero.length; i++) {
    for (int j = 1; j < tablero[i].length; j++) {
      if (tablero[i][j] == "·" && tableroConBombas[i][j] != "*") {
        return false;
      }
    }
  }
  return true;
}
