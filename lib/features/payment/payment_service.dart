import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../core/api/api_client.dart';

class PaymentService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Stripe with publishable key
      // In production, this would come from environment configuration
      const publishableKey = 'pk_test_your_stripe_publishable_key'; // Replace with your key
      
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = 'merchant.com.playviagens.passageiro';
      
      await Stripe.instance.applySettings();
      
      _initialized = true;
      print('💳 Stripe inicializado');
    } catch (error) {
      print('❌ Erro ao inicializar pagamentos: $error');
    }
  }

  // Process ride payment
  static Future<PaymentResult> processRidePayment({
    required int rideId,
    required double amount,
    required PaymentMethod paymentMethod,
    String currency = 'BRL',
  }) async {
    try {
      print('💳 Processando pagamento da corrida #$rideId: ${paymentMethod.type}');

      switch (paymentMethod.type) {
        case PaymentType.card:
          return await _processCardPayment(rideId, amount, currency);
        case PaymentType.pix:
          return await _processPixPayment(rideId, amount);
        case PaymentType.cash:
          return await _processCashPayment(rideId, amount);
        case PaymentType.wallet:
          return await _processWalletPayment(rideId, amount);
      }
    } catch (error) {
      return PaymentResult(
        success: false,
        error: 'Erro ao processar pagamento: $error',
      );
    }
  }

  static Future<PaymentResult> _processCardPayment(
    int rideId,
    double amount,
    String currency,
  ) async {
    try {
      // Create payment intent on backend
      final response = await ApiClient.instance.createPaymentIntent(
        amount: amount,
        currency: currency,
        rideId: rideId,
      );

      if (response.statusCode != 200) {
        return PaymentResult(
          success: false,
          error: 'Falha ao criar intenção de pagamento',
        );
      }

      final data = response.data;
      final clientSecret = data['clientSecret'] as String;

      // Confirm payment with Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      return PaymentResult(
        success: true,
        paymentId: data['id'],
        message: 'Pagamento processado com sucesso',
      );
    } catch (error) {
      if (error is StripeException) {
        return PaymentResult(
          success: false,
          error: _getStripeErrorMessage(error),
        );
      }
      
      return PaymentResult(
        success: false,
        error: 'Erro no pagamento com cartão',
      );
    }
  }

  static Future<PaymentResult> _processPixPayment(int rideId, double amount) async {
    try {
      final response = await ApiClient.instance.generatePixPayment(
        rideId: rideId,
        amount: amount,
      );

      if (response.statusCode != 200) {
        return PaymentResult(
          success: false,
          error: 'Falha ao gerar PIX',
        );
      }

      final data = response.data;
      
      return PaymentResult(
        success: true,
        paymentId: data['paymentId'],
        pixData: PixData(
          qrCode: data['qrCode'],
          pixKey: data['pixKey'],
          paymentCode: data['paymentCode'],
        ),
        message: 'PIX gerado com sucesso. Use o QR Code para pagar.',
      );
    } catch (error) {
      return PaymentResult(
        success: false,
        error: 'Erro ao gerar PIX: $error',
      );
    }
  }

  static Future<PaymentResult> _processCashPayment(int rideId, double amount) async {
    try {
      final response = await ApiClient.instance.registerCashPayment(
        rideId: rideId,
        amount: amount,
      );

      if (response.statusCode != 200) {
        return PaymentResult(
          success: false,
          error: 'Falha ao registrar pagamento em dinheiro',
        );
      }

      return PaymentResult(
        success: true,
        paymentId: response.data['paymentId'],
        message: 'Pagamento em dinheiro registrado. Pague diretamente ao motorista.',
      );
    } catch (error) {
      return PaymentResult(
        success: false,
        error: 'Erro ao registrar pagamento em dinheiro: $error',
      );
    }
  }

  static Future<PaymentResult> _processWalletPayment(int rideId, double amount) async {
    try {
      final response = await ApiClient.instance.processWalletPayment(
        rideId: rideId,
        amount: amount,
      );

      if (response.statusCode != 200) {
        final error = response.data['error'] ?? 'Falha no pagamento via carteira';
        return PaymentResult(
          success: false,
          error: error,
        );
      }

      return PaymentResult(
        success: true,
        paymentId: response.data['paymentId'],
        message: 'Pagamento debitado da sua carteira',
      );
    } catch (error) {
      return PaymentResult(
        success: false,
        error: 'Erro no pagamento via carteira: $error',
      );
    }
  }

  // Get user payment methods
  static Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await ApiClient.instance.getPaymentMethods();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['methods'];
        return data.map((item) => PaymentMethod.fromJson(item)).toList();
      }
    } catch (error) {
      print('❌ Erro ao buscar métodos de pagamento: $error');
    }
    
    // Return default payment methods
    return [
      PaymentMethod(type: PaymentType.card, name: 'Cartão de Crédito'),
      PaymentMethod(type: PaymentType.pix, name: 'PIX'),
      PaymentMethod(type: PaymentType.cash, name: 'Dinheiro'),
      PaymentMethod(type: PaymentType.wallet, name: 'Carteira Play Viagens'),
    ];
  }

  // Get wallet balance
  static Future<double> getWalletBalance() async {
    try {
      final response = await ApiClient.instance.getWalletBalance();
      
      if (response.statusCode == 200) {
        return (response.data['balance'] as num).toDouble();
      }
    } catch (error) {
      print('❌ Erro ao buscar saldo da carteira: $error');
    }
    
    return 0.0;
  }

  // Add money to wallet
  static Future<PaymentResult> addMoneyToWallet({
    required double amount,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      final response = await ApiClient.instance.addMoneyToWallet(
        amount: amount,
        paymentMethodId: paymentMethod.id,
      );

      if (response.statusCode == 200) {
        return PaymentResult(
          success: true,
          paymentId: response.data['transactionId'],
          message: 'R\$ ${amount.toStringAsFixed(2)} adicionados à sua carteira',
        );
      } else {
        return PaymentResult(
          success: false,
          error: response.data['error'] ?? 'Falha ao adicionar dinheiro',
        );
      }
    } catch (error) {
      return PaymentResult(
        success: false,
        error: 'Erro ao adicionar dinheiro à carteira: $error',
      );
    }
  }

  static String _getStripeErrorMessage(StripeException error) {
    switch (error.error.code) {
      case FailureCode.CardDeclined:
        return 'Cartão recusado. Verifique os dados ou tente outro cartão.';
      case FailureCode.ExpiredCard:
        return 'Cartão expirado. Verifique a data de validade.';
      case FailureCode.IncorrectCvc:
        return 'Código de segurança (CVC) incorreto.';
      case FailureCode.InsufficientFunds:
        return 'Saldo insuficiente no cartão.';
      case FailureCode.InvalidCvc:
        return 'Código de segurança (CVC) inválido.';
      case FailureCode.InvalidExpiryMonth:
        return 'Mês de expiração inválido.';
      case FailureCode.InvalidExpiryYear:
        return 'Ano de expiração inválido.';
      case FailureCode.InvalidNumber:
        return 'Número do cartão inválido.';
      default:
        return error.error.message ?? 'Erro no pagamento. Tente novamente.';
    }
  }
}

// Data classes
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? error;
  final String? message;
  final PixData? pixData;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.error,
    this.message,
    this.pixData,
  });
}

class PaymentMethod {
  final PaymentType type;
  final String name;
  final String? id;
  final String? last4;
  final String? brand;
  final String? pixKey;

  PaymentMethod({
    required this.type,
    required this.name,
    this.id,
    this.last4,
    this.brand,
    this.pixKey,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      type: PaymentType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => PaymentType.card,
      ),
      name: json['name'],
      id: json['id'],
      last4: json['last4'],
      brand: json['brand'],
      pixKey: json['pixKey'],
    );
  }

  String get displayName {
    switch (type) {
      case PaymentType.card:
        if (last4 != null && brand != null) {
          return '$brand •••• $last4';
        }
        return name;
      case PaymentType.pix:
        return pixKey != null ? 'PIX - $pixKey' : name;
      default:
        return name;
    }
  }

  String get icon {
    switch (type) {
      case PaymentType.card:
        return '💳';
      case PaymentType.pix:
        return '🔗';
      case PaymentType.cash:
        return '💵';
      case PaymentType.wallet:
        return '💰';
    }
  }
}

enum PaymentType { card, pix, cash, wallet }

class PixData {
  final String qrCode;
  final String pixKey;
  final String paymentCode;

  PixData({
    required this.qrCode,
    required this.pixKey,
    required this.paymentCode,
  });
}