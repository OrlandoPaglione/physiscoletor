# Physis Coletor

# Aplicativo de Impressão de Etiquetas Bluetooth
Este é um aplicativo Flutter que permite escanear códigos de barras, gerar etiquetas de código de barras e imprimi-las em uma impressora Bluetooth térmica.

<b>Recursos Principais<br></b>
Escanear Códigos de Barras: Utiliza a biblioteca barcode_scan2 para escanear códigos de barras.<br>
Gerar e Imprimir Etiquetas: Gera etiquetas de código de barras e as imprime em uma impressora térmica Bluetooth.<br>
Conexão Bluetooth: Conecta-se a uma impressora Bluetooth para imprimir as etiquetas.<br>
# Instalação e Uso
Clone este repositório.<br>
Certifique-se de ter o Flutter e o ambiente de desenvolvimento configurados.<br>
Execute flutter pub get para instalar as dependências necessárias.<br>
Compile e execute o aplicativo em um dispositivo ou emulador.<br>
# <b>Como Usar<br></b>
Na tela de login, insira suas credenciais e selecione a loja desejada.<br>
Na tela principal, clique em "Ler Código de Barras" para escanear um código de barras.<br>
Insira o número de etiquetas desejado.<br>
Clique em "Imprimir Etiquetas" para imprimir as etiquetas.<br>
Selecione a impressora Bluetooth disponível.<br>
As etiquetas serão impressas na impressora selecionada.<br>
Dependências Principais<br>
bluetooth_thermal_printer: Biblioteca para comunicação com impressoras térmicas Bluetooth.<br>
esc_pos_utils: Utilitários para formatação de dados de impressão.<br>
flutter_bluetooth_serial: Integração Bluetooth para comunicação com dispositivos Bluetooth.<br>
barcode_scan2: Biblioteca para escanear códigos de barras.<br>
