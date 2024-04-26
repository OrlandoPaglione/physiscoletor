import 'package:flutter/material.dart';
import 'package:physiscoletor/main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List<String> lojas = [
    'Loja 1',
    'Loja 2',
    'Loja 3',
    'Loja 4',
    'Depósito'
  ];
  late TextEditingController tokenController;
  late TextEditingController nomeController;
  var lojaSelecionada1 = 'Loja 1';
  // late TextEditingController senhaController;

  @override
  void initState() {
    super.initState();
    tokenController = TextEditingController();
    nomeController = TextEditingController();
    // senhaController = TextEditingController();
  }

  @override
  void dispose() {
    tokenController.dispose();
    nomeController.dispose();
    //  senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login e Seleção de Loja'),
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView para permitir a rolagem
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Login:'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Text('Senha:'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: tokenController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),
              /*  Text('Insira a Senha:'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ),*/

              Text('Selecione uma Loja:'),
              DropdownButton<String>(
                value: lojas[0],
                onChanged: (String? newValue) {
                  // Atualizar a loja selecionada
                  // Você pode armazenar essa seleção em algum lugar para uso posterior
                  // Atualizar a loja selecionada quando o usuário fizer uma seleção
                  setState(() {
                    lojaSelecionada1 = newValue!;
                  });
                },
                items: lojas.map((String loja) {
                  return DropdownMenuItem<String>(
                    value: loja,
                    child: Text(loja),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navegar para a página principal após o login e a seleção da loja
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BarcodeScannerScreen(
                        token: tokenController.text,
                        nome: nomeController.text,
                        lojas: lojas,
                        lojaSelecionada: lojaSelecionada1,
                        // Passando a lista de lojas
                        // senha: senhaController.text,
                      ),
                    ),
                  );
                },
                child: Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
