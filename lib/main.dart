import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/maps/providers/map_provider.dart';
import 'features/ride/providers/ride_provider.dart';
import 'features/ride/providers/ride_tracking_provider.dart';
import 'features/driver/providers/driver_provider.dart';
import 'features/wallet/providers/wallet_provider.dart';
import 'features/whatsapp/providers/whatsapp_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/passenger/screens/passenger_home_screen.dart';
import 'features/passenger/screens/passenger_profile_screen.dart';
import 'features/passenger/screens/passenger_rides_screen.dart';
import 'features/passenger/screens/passenger_wallet_screen.dart';
import 'features/passenger/screens/simple_ride_request_screen.dart';
import 'features/driver/screens/driver_home_screen.dart';
import 'features/wallet/screens/add_funds_screen.dart';
import 'features/wallet/screens/wallet_screen.dart';
import 'features/wallet/screens/wallet_recharge_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/passenger/screens/edit_profile_screen.dart';
import 'features/passenger/screens/ride_history_screen.dart';
import 'features/passenger/screens/scheduled_rides_screen.dart';
import 'features/passenger/screens/activity_screen.dart';
import 'features/passenger/screens/account_screen.dart';
import 'features/passenger/screens/schedule_ride_screen.dart';
import 'features/passenger/screens/first_trip_screen.dart';
import 'features/passenger/screens/services_screen.dart';
import 'features/passenger/screens/profile_screen.dart';
import 'features/passenger/screens/documents_screen.dart';
import 'features/passenger/screens/welcome_screen.dart';
import 'features/passenger/screens/new_request_ride_screen.dart';
import 'features/passenger/screens/ride_accepted_screen.dart';
import 'features/passenger/screens/ride_in_progress_screen.dart';
import 'features/passenger/screens/ride_evaluation_screen.dart';
import 'features/passenger/screens/ride_payment_screen.dart';
import 'features/passenger/screens/document_upload_screen.dart';
import 'features/passenger/screens/support_screen.dart';
import 'features/passenger/screens/passenger_documents_screen.dart';
import 'features/passenger/screens/passenger_support_screen.dart';
import 'features/passenger/screens/ride_waiting_screen.dart';
import 'features/whatsapp/screens/whatsapp_history_screen.dart';
import 'features/auth/screens/whatsapp_verification_screen.dart';
import 'core/widgets/provider_wrapper.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const PlayViagensApp());
}

class PlayViagensApp extends StatelessWidget {
  const PlayViagensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<MapProvider>(create: (_) => MapProvider()),
        ChangeNotifierProvider<RideProvider>(create: (_) => RideProvider()),
        ChangeNotifierProvider<RideTrackingProvider>(create: (_) => RideTrackingProvider()),
        ChangeNotifierProvider<DriverProvider>(create: (_) => DriverProvider()),
        ChangeNotifierProvider<WalletProvider>(create: (_) => WalletProvider()),
        ChangeNotifierProvider<WhatsAppProvider>(create: (_) => WhatsAppProvider()),
      ],
      child: MaterialApp(
        title: 'Play Viagens - Passageiro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(), // Usar SplashScreen para inicializar auth corretamente
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/passenger-home': (context) => const ProviderWrapper(child: PassengerHomeScreen()),
          '/passenger-profile': (context) => const ProviderWrapper(child: PassengerProfileScreen()),
          '/passenger-rides': (context) => const ProviderWrapper(child: PassengerRidesScreen()),
          '/passenger-wallet': (context) => const ProviderWrapper(child: PassengerWalletScreen()),
          '/driver-home': (context) => const ProviderWrapper(child: DriverHomeScreen()),
          '/request-ride': (context) => const ProviderWrapper(child: SimpleRideRequestScreen()),
          '/add-funds': (context) => const ProviderWrapper(child: AddFundsScreen()),
          '/wallet': (context) => const ProviderWrapper(child: WalletScreen()),
          '/wallet-recharge': (context) => const ProviderWrapper(child: WalletRechargeScreen()),
          '/edit-profile': (context) => const ProviderWrapper(child: EditProfileScreen()),
          '/ride-history': (context) => const ProviderWrapper(child: RideHistoryScreen()),
          '/scheduled-rides': (context) => const ProviderWrapper(child: ScheduledRidesScreen()),
          '/whatsapp': (context) => const ProviderWrapper(child: WhatsAppHistoryScreen(userType: 'passenger')),
          '/activity': (context) => const ProviderWrapper(child: ActivityScreen()),
          '/account': (context) => const ProviderWrapper(child: AccountScreen()),
          '/schedule-ride': (context) => const ProviderWrapper(child: ScheduleRideScreen()),
          '/first-trip': (context) => const ProviderWrapper(child: FirstTripScreen()),
          '/services': (context) => const ProviderWrapper(child: ServicesScreen()),
          '/profile': (context) => const ProviderWrapper(child: ProfileScreen()),
          '/documents': (context) => const ProviderWrapper(child: DocumentsScreen()),
          '/welcome': (context) => const ProviderWrapper(child: WelcomeScreen()),
          '/new-request-ride': (context) => const ProviderWrapper(child: NewRequestRideScreen()),
          '/ride-accepted': (context) => const ProviderWrapper(child: RideAcceptedScreen()),
          '/ride-in-progress': (context) => const ProviderWrapper(child: RideInProgressScreen()),
          '/ride-payment': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ProviderWrapper(
              child: RidePaymentScreen(
                rideId: args['rideId'],
                rideAmount: args['rideAmount'],
                driverId: args['driverId'],
                driverName: args['driverName'],
              ),
            );
          },
          '/ride-evaluation': (context) => const ProviderWrapper(child: RideEvaluationScreen()),
          '/document-upload': (context) => const ProviderWrapper(child: DocumentUploadScreen()),
          '/support': (context) => const ProviderWrapper(child: SupportScreen()),
          '/passenger-documents': (context) => const ProviderWrapper(child: PassengerDocumentsScreen()),
          '/passenger-support': (context) => const ProviderWrapper(child: PassengerSupportScreen()),
          '/ride-waiting': (context) => const ProviderWrapper(child: RideWaitingScreen()),
          '/whatsapp-verification': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return WhatsAppVerificationScreen(
              phoneNumber: args['phoneNumber'],
              tempToken: args['tempToken'],
            );
          },
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for animation to complete first
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      
      // Quick auth check only
      print('🔄 Verificando autenticação...');
      await authProvider.initialize();
      
      // Wait a bit more for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navigate to appropriate screen - ProviderWrapper will handle full initialization
      if (authProvider.isLoggedIn) {
        print('🏠 Navegando para home screen...');
        if (authProvider.isDriver) {
          Navigator.pushReplacementNamed(context, '/driver-home');
        } else {
          Navigator.pushReplacementNamed(context, '/passenger-home');
        }
      } else {
        print('🔐 Navegando para tela de login...');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      print('❌ Erro durante inicialização: $error');
      
      if (!mounted) return;
      
      // Em caso de erro, vá para login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Play Viagens - Design Original
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF00),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF00).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Texto "play Viagens"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'play',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 0.9,
                          ),
                        ),
                        Text(
                          'Viagens',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Badge "PASSAGEIRO"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00FF00), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person, color: Color(0xFF00FF00), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'PASSAGEIRO',
                        style: TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sua viagem começa aqui',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  width: 50,
                  height: 50,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}