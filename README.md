# Play Viagens - App do Passageiro

Este é o aplicativo Flutter dedicado aos passageiros da plataforma Play Viagens.

## Características

- Interface focada em passageiros
- Solicitar corridas
- Rastreamento em tempo real
- Histórico de viagens
- Sistema de pagamento
- Avaliação de motoristas

## Como executar

1. Instalar dependências:
```bash
flutter pub get
```

2. Gerar modelos (se necessário):
```bash
flutter packages pub run build_runner build
```

3. Executar no Android:
```bash
flutter run -d android
```

## Estrutura

- `lib/features/auth/` - Autenticação
- `lib/features/passenger/` - Funcionalidades do passageiro
- `lib/features/maps/` - Integração com Google Maps
- `lib/features/ride/` - Gerenciamento de corridas
- `lib/core/` - Modelos e API client

## Configuração

- Google Maps API Key já configurada
- API base URL: http://localhost:5010
- Tema: Modo escuro com cor primária verde (#00CC00)
