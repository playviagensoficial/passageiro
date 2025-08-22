import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/maps/providers/map_provider.dart';
import '../../features/ride/providers/ride_provider.dart';
import '../../features/ride/providers/ride_tracking_provider.dart';
import '../../features/driver/providers/driver_provider.dart';
import '../../features/wallet/providers/wallet_provider.dart';

class ProviderWrapper extends StatefulWidget {
  final Widget child;
  
  const ProviderWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ProviderWrapper> createState() => _ProviderWrapperState();
}

class _ProviderWrapperState extends State<ProviderWrapper> {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    try {
      print('🔄 [ProviderWrapper] Inicializando providers...');
      
      // Wait a frame to ensure the providers are mounted
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      // Try to access all providers to ensure they exist
      print('🔄 [ProviderWrapper] Verificando AuthProvider...');
      final authProvider = context.read<AuthProvider>();
      
      print('🔄 [ProviderWrapper] Verificando MapProvider...');
      final mapProvider = context.read<MapProvider>();
      
      print('🔄 [ProviderWrapper] Verificando RideProvider...');
      final rideProvider = context.read<RideProvider>();
      
      print('🔄 [ProviderWrapper] Verificando RideTrackingProvider...');
      final rideTrackingProvider = context.read<RideTrackingProvider>();
      
      print('🔄 [ProviderWrapper] Verificando DriverProvider...');
      final driverProvider = context.read<DriverProvider>();
      
      print('🔄 [ProviderWrapper] Verificando WalletProvider...');
      final walletProvider = context.read<WalletProvider>();
      
      print('✅ [ProviderWrapper] Todos os providers encontrados');
      
      // Initialize critical providers
      print('🔄 [ProviderWrapper] Inicializando AuthProvider...');
      await authProvider.initialize();
      
      print('🔄 [ProviderWrapper] Inicializando RideProvider...');
      await rideProvider.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
      print('✅ [ProviderWrapper] Providers inicializados com sucesso');
    } catch (error) {
      print('❌ [ProviderWrapper] Erro na inicialização: $error');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erro de Inicialização',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Erro desconhecido',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _isInitialized = false;
                    });
                    _initializeProviders();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF00),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Inicializando Play Viagens...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}