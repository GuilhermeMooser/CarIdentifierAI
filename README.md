# Sistema de Detecção de Carros

## Funcionalidades:
- Câmera nativa integrada
- Captura de alta qualidade
- Visualização de resultados com overlay
- Bounding boxes coloridas por classe
- Informações detalhadas de cada detecção

### Validações:
- Verificação de permissões da câmera
- Validação de conectividade
- Retry automático em falhas
- Feedback visual para o usuário
- Tratamento de timeout de rede
- Validação local de arquivos

# Configuração do App Flutter
## Pré-requisitos

- Flutter SDK 3.13+ instalado

## Instale as dependências
```
yaml
name: car_detector_app
description: Aplicativo para detecção de carros usando YOLO

version: 1.0.0+1

environment:
  sdk: '>=3.1.0 <4.0.0'
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+5
  dio: ^5.3.2
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
  image_picker: ^1.0.4
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  cached_network_image: ^3.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```
## Estrutura do Projeto
```
car_detector_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── detection_result.dart
│   ├── services/
│   │   └── api_service.dart
│   ├── bloc/
│   │   └── detection_bloc.dart
│   ├── screens/
│   │   ├── camera_screen.dart
│   │   └── result_screen.dart
│   └── widgets/
│       └── bounding_box_painter.dart
├── android/
└── ios/
```

## Permissões
#### Android (android/app/src/main/AndroidManifest.xml)
```
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

