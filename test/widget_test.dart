import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:play_viagens_passageiro/main.dart';
import 'package:play_viagens_passageiro/features/auth/providers/auth_provider.dart';
import 'package:play_viagens_passageiro/features/maps/providers/map_provider.dart';
import 'package:play_viagens_passageiro/features/ride/providers/ride_provider.dart';
import 'package:play_viagens_passageiro/features/driver/providers/driver_provider.dart';

void main() {
  group('Passenger App Widget Tests', () {
    testWidgets('should display passenger splash screen correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MapProvider()),
            ChangeNotifierProvider(create: (_) => RideProvider()),
            ChangeNotifierProvider(create: (_) => DriverProvider()),
          ],
          child: const MaterialApp(
            home: PlayViagensApp(),
          ),
        ),
      );

      // Assert - Check if splash screen elements are present
      expect(find.text('PLAY VIAGENS'), findsOneWidget);
      expect(find.text('PASSAGEIRO'), findsOneWidget);
      expect(find.text('Sua viagem começa aqui'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have correct app title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const PlayViagensApp());

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Assert
      expect(materialApp.title, 'Play Viagens - Passageiro');
    });

    testWidgets('should display car icon in splash screen', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MapProvider()),
            ChangeNotifierProvider(create: (_) => RideProvider()),
            ChangeNotifierProvider(create: (_) => DriverProvider()),
          ],
          child: const MaterialApp(
            home: PlayViagensApp(),
          ),
        ),
      );

      // Assert - Check if car icon is present
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });
  });
}
