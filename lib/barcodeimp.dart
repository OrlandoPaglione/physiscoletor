import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    as btSerial;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'login_page.dart';

void main() {
  runApp(MyApp());
}

bool connected = false;
List availableBluetoothDevices = [];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  final String token;
  final String nome;
  final List<String> lojas;
  final String lojaSelecionada;

  BarcodeScannerScreen({
    required this.token,
    required this.nome,
    required this.lojas,
    required this.lojaSelecionada,
  });

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String scannedCode = '';
  int numberOfLabels = 1;
  btSerial.BluetoothConnection? connection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lojaSelecionada),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Código de Barras Lido:'),
            Text(
              scannedCode,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                /// String code = await scanBarcode();
                await _generateBarcode(scannedCode);
                setState(() {
                  scannedCode = scannedCode;
                  if (scannedCode == '-1') {
                    scannedCode = '7891235458';
                  }
                });
              },
              child: Text('Ler Código de Barras'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Número de Etiquetas: '),
                SizedBox(
                  width: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        numberOfLabels = int.tryParse(value) ?? 1;
                      });
                    },
                    controller:
                        TextEditingController(text: numberOfLabels.toString()),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                printGraphics(scannedCode, numberOfLabels);
                consumeHttpEndpoint(scannedCode, numberOfLabels);
              },
              child: Text('Imprimir Etiquetas'),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Verifique as impressoras disponivels"),
                TextButton(
                  onPressed: () {
                    this.getBluetooth();
                  },
                  child: Text("Pesquisar Impressoras"),
                ),
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: availableBluetoothDevices.isNotEmpty
                        ? availableBluetoothDevices.length
                        : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String select = availableBluetoothDevices[index];
                          List list = select.split("#");
                          String mac = list[1];
                          this.setConnect(mac);
                        },
                        title: Text('${availableBluetoothDevices[index]}'),
                        subtitle: Text("Click para conectar"),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                /* TextButton(
                  onPressed: this.printGraphics,
                  child: Text("Print"),
                ),*/
                /*  TextButton(
                  onPressed: connected ? this.printTicket() : null,
                  child: Text("Print Ticket"),
                ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateBarcode(String code) async {
    // Solicitar que o usuário digitalize ou insira o código EAN13
    try {
      var result = await BarcodeScanner.scan(); // Digitalize o código de barras

      if (!mounted) return;

      setState(() {
        scannedCode = result.rawContent;
      });
    } on Exception catch (e) {
      print('Erro ao escanear o código de barras: $e');
      return;
    }
  }

/* esta não disponivel em android mais antigo 
  Future<String> scanBarcode() async {
    try {
      String code = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.BARCODE,
      );
      return code;
    } catch (e) {
      return 'Erro ao escanear: $e';
    }
  }
*/
  Future<void> printLabels(String code, int quantity) async {
    final btSerial.FlutterBluetoothSerial bluetooth =
        btSerial.FlutterBluetoothSerial.instance;
    List<btSerial.BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } catch (e) {
      print('Erro ao obter dispositivos Bluetooth emparelhados: $e');
    }

    if (devices.isNotEmpty) {
      btSerial.BluetoothDevice device = devices.first;
      try {
        connection =
            await btSerial.BluetoothConnection.toAddress(device.address);
        connection?.output.add(Uint8List.fromList([27, 64]));
        connection?.output.add(Uint8List.fromList([10, 13]));
        connection?.output.add(Uint8List.fromList([27, 97, 1]));
        for (int i = 0; i < quantity; i++) {
          connection?.output
              .add(Uint8List.fromList('Código de Barras: $code\n'.codeUnits));
          connection?.output.add(Uint8List.fromList([10, 13]));
        }
        await connection?.output.allSent;
        await Future.delayed(Duration(seconds: 1));
        connection?.finish();
        await connection?.close();
      } catch (e) {
        print('Erro ao imprimir: $e');
      }
    } else {
      print('Nenhum dispositivo Bluetooth emparelhado encontrado.');
    }
  }
/*
  Future<List<int>> getGraphicsTicket() async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    bytes += generator.qrcode('example.com');

    bytes += generator.hr();

    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.cut();

    return bytes;
  }
*/

  Future<List<int>> getGraphicsTicket(String barcodeData) async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
//    bytes += generator.qrcode('example.com');
    ///  bytes += generator.hr();
    List<int> barData = barcodeData.runes
        .map((int rune) => int.parse(String.fromCharCode(rune)))
        .toList();
    //final List<int> barData = barcodeData.codeUnits; // Usar a String recebida como dados de código de barras
    ///final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    /// print(barData.toString());
    bytes += generator.barcode(Barcode.ean13(barData));

    ///.upcA(barData));
    bytes += generator.cut();
    return bytes;
  }

  Future<void> printGraphics(String codeData, int quantity) async {
    String? isConnected = await BluetoothThermalPrinter.connectionStatus;
    if (isConnected == "true") {
      for (int i = 0; i < quantity; i++) {
        var result =
            await BluetoothThermalPrinter.writeText("Produto de Teste\n"
                "Valor 85,89 "
                "\n$codeData"
                "\n");
        List<int> bytes = await getGraphicsTicket('$codeData');
        result = await BluetoothThermalPrinter.writeBytes(bytes);
        print("Print $result");
      }
    } else {
      //Hadnle Not Connected Senario
    }
  }
  /*print("imprimindo " + isConnected.toString());
    if (isConnected == "true") {
      List<int> bytes = await getGraphicsTicket(codeData);
      var result = await BluetoothThermalPrinter.writeBytes(bytes);
      result = await BluetoothThermalPrinter.writeText("Produto de teste\n"
          "valor 50,25"
          "\n$codeData"
          "\n");

      print("Print $result");
    } else {
      // Handle Not Connected Scenario
    }
  }*/

  Future<void> setConnect(String mac) async {
    print('string ' + mac.toString());
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state connected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths!;
    });
  }

  Future<void> consumeHttpEndpoint(String code, int quantity) async {
    final url = Uri.parse('http://209.14.68.135:8084/etiquetas');
    final body = {
      'code': code,
      'quantity': quantity.toString(),
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        print('Solicitação HTTP bem-sucedida. Resposta: ${response.body}');
      } else {
        print(
            'Erro na solicitação HTTP. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao fazer a solicitação HTTP: $e');
    }
  }
}
