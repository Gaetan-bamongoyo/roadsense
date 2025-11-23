// import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

Future<void> printPaiementTicket() async {
  try {
    // Initialisation de l'imprimante
    final isConnected = await SunmiPrinter.bindingPrinter();
    if (isConnected == null || !isConnected) {
      print("Imprimante Sunmi non détectée !");
      return;
    }

    await SunmiPrinter.initPrinter();

    // Logo depuis assets (ton image dans le projet)
    // Assure-toi d'avoir ton logo dans pubspec.yaml :
    // assets:
    //   - assets/logo.png
    // ByteData bytes = await rootBundle.load('assets/logo.png');
    // final Uint8List logoBytes = bytes.buffer.asUint8List();
    // await SunmiPrinter.printBitmap(logoBytes);

    // Ligne de séparation
    await SunmiPrinter.printText("──────────────");

    // Informations du ticket
    await SunmiPrinter.printText(
      "Poste : Poste de péage Mwanda\n",
      style: SunmiTextStyle(bold: true),
    );
    await SunmiPrinter.printText("Conducteur : John Doe\n");
    await SunmiPrinter.printText("Type d'engin : Moto\n");
    await SunmiPrinter.printText("Montant : 5000 FC\n");
    await SunmiPrinter.printText("Quantité : 1\n");
    await SunmiPrinter.printText("Tarif : 5000 FC\n");
    await SunmiPrinter.printText("Reçu N° : 123456\n");
    await SunmiPrinter.printText("Date : 22/11/2025 16:00\n");
    await SunmiPrinter.printText("Agent : Gaëtan\n");

    // Ligne de séparation
    await SunmiPrinter.printText("──────────────");

    // Message final
    await SunmiPrinter.printText(
      "Merci pour votre passage !\n",
      style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true),
    );

    // Saut de lignes
    await SunmiPrinter.lineWrap(3);

  } catch (e) {
    print("Erreur impression : $e");
  }
}
