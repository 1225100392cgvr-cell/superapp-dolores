import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:super_dolores/main.dart' as app;
import 'package:super_dolores/presentacion/pantallas/pantalla_chat.dart';

/// Recorre la SuperApp en el emulador y toma una captura de cada pantalla.
/// Se corre con: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/capturas_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> foto(WidgetTester tester, String nombre) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await binding.takeScreenshot(nombre);
  }

  Finder enBarra(IconData icono) =>
      find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(icono));

  Future<void> tocar(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f.first);
    await tester.pumpAndSettle();
    await tester.tap(f.first);
    await tester.pumpAndSettle();
  }

  testWidgets('recorrido de la SuperApp con capturas', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();
    await foto(tester, '01_inicio');

    // Mensajes: chat con Luis, texto y dinero dentro del chat.
    await tocar(tester, enBarra(Icons.chat));
    await tocar(tester, find.widgetWithText(ActionChip, 'Luis'));
    await tester.enterText(
        find.descendant(of: find.byType(PantallaChat), matching: find.byType(TextField)), '¡Hola Luis! Te mando lo de las tortillas');
    await tocar(tester, find.byIcon(Icons.send));
    await tocar(tester, find.byIcon(Icons.attach_money));
    await foto(tester, '02_chat_con_dinero');

    // Monedero: saldo y movimientos.
    await tocar(tester, enBarra(Icons.account_balance_wallet));
    await foto(tester, '03_monedero');

    // Tienda: carrito y compra con comisión.
    await tocar(tester, enBarra(Icons.storefront));
    await foto(tester, '04_negocios');
    await tocar(tester, find.text('Tortillería La Güera'));
    await tocar(tester, find.byIcon(Icons.add_circle_outline));
    await tocar(tester, find.byIcon(Icons.add_circle_outline));
    await tocar(tester, find.textContaining('Pagar con monedero'));
    await foto(tester, '05_compra_tortilleria');

    // Viajes: máquina de estados completa.
    await tocar(tester, enBarra(Icons.local_taxi));
    await tocar(tester, find.text('Pedir viaje'));
    await tocar(tester, find.text('(Simular) conductor acepta'));
    await tocar(tester, find.text('(Simular) iniciar'));
    await tocar(tester, find.text('(Simular) llegar y pagar'));
    await foto(tester, '06_viaje_finalizado');

    // Inicio otra vez: puntos de lealtad y sugerencia.
    await tocar(tester, enBarra(Icons.home));
    await foto(tester, '07_inicio_con_puntos');

    // Tablero de retención.
    await tocar(tester, find.text('Tablero de retención (datos simulados)'));
    await foto(tester, '08_tablero_retencion');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Mini-app de un tercero: los permisos la bloquean.
    await tocar(tester, find.text('Mini-app de un tercero (probar permisos)'));
    await tocar(tester, find.text('Intentar leer mi saldo'));
    await foto(tester, '09_horoscopo_bloqueado');
  });
}
