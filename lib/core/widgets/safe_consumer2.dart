import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget que fornece Consumer2 com verificação de providers
/// Evita o erro "Could not find the correct Provider"
class SafeConsumer2<T extends ChangeNotifier, U extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T provider1, U provider2, Widget? child) builder;
  final Widget? child;
  final Widget Function()? onProviderNotFound;

  const SafeConsumer2({
    super.key,
    required this.builder,
    this.child,
    this.onProviderNotFound,
  });

  @override
  Widget build(BuildContext context) {
    try {
      // Tentar acessar os providers antes de usar Consumer2
      final provider1 = context.read<T>();
      final provider2 = context.read<U>();
      
      print('✅ [SafeConsumer2] Providers ${T.toString()} e ${U.toString()} encontrados');
      
      return Consumer2<T, U>(
        builder: builder,
        child: child,
      );
    } catch (error) {
      print('❌ [SafeConsumer2] Erro ao acessar providers: $error');
      
      if (onProviderNotFound != null) {
        return onProviderNotFound!();
      }
      
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Providers não encontrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro: ${T.toString()} ou ${U.toString()} não estão disponíveis',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Voltar ao Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}