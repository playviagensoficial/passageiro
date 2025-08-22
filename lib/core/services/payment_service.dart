import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../api/api_client.dart';

class PaymentService {
  static final ApiClient _apiClient = ApiClient.instance;

  // Card machine payment integration
  static Future<Map<String, dynamic>> processCardMachinePayment({
    required int rideId,
    required double amount,
    required String driverId,
    String cardType = 'credit', // 'credit' or 'debit'
  }) async {
    try {
      print('💳 Processando pagamento na maquininha - Valor: R\$ ${amount.toStringAsFixed(2)}');
      
      final response = await _apiClient.post('/api/payments/card-machine', {
        'ride_id': rideId,
        'amount': amount,
        'driver_id': driverId,
        'card_type': cardType,
        'payment_method': 'card_machine',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        return {
          'success': true,
          'transaction_id': data['transaction_id'],
          'authorization_code': data['authorization_code'],
          'receipt_url': data['receipt_url'],
          'message': 'Pagamento aprovado na maquininha',
          'driver_fee': data['driver_fee'], // Taxa que fica com o motorista
          'platform_fee': data['platform_fee'], // Taxa da plataforma
        };
      } else {
        throw Exception(response.data?['error'] ?? 'Erro no pagamento');
      }
    } catch (e) {
      print('❌ Erro no pagamento com maquininha: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erro ao processar pagamento na maquininha',
      };
    }
  }

  // PIX payment
  static Future<Map<String, dynamic>> processPIXPayment({
    required int rideId,
    required double amount,
    required String driverId,
  }) async {
    try {
      print('💱 Gerando PIX - Valor: R\$ ${amount.toStringAsFixed(2)}');
      
      final response = await _apiClient.post('/api/payments/pix', {
        'ride_id': rideId,
        'amount': amount,
        'driver_id': driverId,
        'payment_method': 'pix',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        return {
          'success': true,
          'pix_code': data['pix_code'],
          'qr_code': data['qr_code'],
          'expires_at': data['expires_at'],
          'message': 'PIX gerado com sucesso',
          'driver_fee': data['driver_fee'],
          'platform_fee': data['platform_fee'],
        };
      } else {
        throw Exception(response.data?['error'] ?? 'Erro ao gerar PIX');
      }
    } catch (e) {
      print('❌ Erro no PIX: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erro ao gerar PIX',
      };
    }
  }

  // Cash payment
  static Future<Map<String, dynamic>> processCashPayment({
    required int rideId,
    required double amount,
    required String driverId,
  }) async {
    try {
      print('💵 Registrando pagamento em dinheiro - Valor: R\$ ${amount.toStringAsFixed(2)}');
      
      final response = await _apiClient.post('/api/payments/cash', {
        'ride_id': rideId,
        'amount': amount,
        'driver_id': driverId,
        'payment_method': 'cash',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        return {
          'success': true,
          'transaction_id': data['transaction_id'],
          'message': 'Pagamento em dinheiro registrado',
          'driver_fee': data['driver_fee'],
          'platform_fee': data['platform_fee'],
        };
      } else {
        throw Exception(response.data?['error'] ?? 'Erro ao registrar pagamento');
      }
    } catch (e) {
      print('❌ Erro no pagamento em dinheiro: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erro ao registrar pagamento em dinheiro',
      };
    }
  }

  // Wallet payment
  static Future<Map<String, dynamic>> processWalletPayment({
    required int rideId,
    required double amount,
    required String driverId,
  }) async {
    try {
      print('🏦 Processando pagamento via carteira - Valor: R\$ ${amount.toStringAsFixed(2)}');
      
      final response = await _apiClient.post('/api/payments/wallet', {
        'ride_id': rideId,
        'amount': amount,
        'driver_id': driverId,
        'payment_method': 'wallet',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        return {
          'success': true,
          'transaction_id': data['transaction_id'],
          'new_balance': data['new_balance'],
          'message': 'Pagamento realizado via carteira',
          'driver_fee': data['driver_fee'],
          'platform_fee': data['platform_fee'],
        };
      } else {
        throw Exception(response.data?['error'] ?? 'Saldo insuficiente ou erro na carteira');
      }
    } catch (e) {
      print('❌ Erro no pagamento via carteira: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Erro ao processar pagamento via carteira',
      };
    }
  }

  // Get payment status
  static Future<Map<String, dynamic>> getPaymentStatus(String transactionId) async {
    try {
      final response = await _apiClient.get('/api/payments/status/$transactionId');
      
      if (response.statusCode == 200 && response.data != null) {
        return {
          'success': true,
          'status': response.data['status'],
          'message': response.data['message'],
          'details': response.data,
        };
      } else {
        throw Exception('Erro ao consultar status do pagamento');
      }
    } catch (e) {
      print('❌ Erro ao consultar pagamento: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Calculate fees breakdown for transparency
  static Map<String, dynamic> calculateFeesBreakdown({
    required double rideAmount,
    required String paymentMethod,
  }) {
    // Fee structure for different payment methods
    Map<String, Map<String, dynamic>> feeStructure = {
      'card_machine': {
        'platform_rate': 0.20, // 20% para plataforma
        'card_processing_fee': 0.03, // 3% taxa do cartão
        'driver_rate': 0.77, // 77% para motorista
      },
      'pix': {
        'platform_rate': 0.15, // 15% para plataforma (menor taxa)
        'card_processing_fee': 0.0, // Sem taxa de processamento
        'driver_rate': 0.85, // 85% para motorista
      },
      'cash': {
        'platform_rate': 0.25, // 25% para plataforma (maior taxa)
        'card_processing_fee': 0.0, // Sem taxa de processamento
        'driver_rate': 0.75, // 75% para motorista
      },
      'wallet': {
        'platform_rate': 0.10, // 10% para plataforma (menor taxa)
        'card_processing_fee': 0.0, // Sem taxa de processamento
        'driver_rate': 0.90, // 90% para motorista
      },
    };

    final fees = feeStructure[paymentMethod] ?? feeStructure['cash']!;
    
    final cardProcessingFee = rideAmount * fees['card_processing_fee'];
    final platformFee = rideAmount * fees['platform_rate'];
    final driverAmount = rideAmount * fees['driver_rate'] - cardProcessingFee;

    return {
      'ride_amount': double.parse(rideAmount.toStringAsFixed(2)),
      'platform_fee': double.parse(platformFee.toStringAsFixed(2)),
      'card_processing_fee': double.parse(cardProcessingFee.toStringAsFixed(2)),
      'driver_amount': double.parse(driverAmount.toStringAsFixed(2)),
      'platform_rate': fees['platform_rate'],
      'driver_rate': fees['driver_rate'],
      'payment_method': paymentMethod,
      'total_fees': double.parse((platformFee + cardProcessingFee).toStringAsFixed(2)),
    };
  }

  // Process payment based on selected method
  static Future<Map<String, dynamic>> processPayment({
    required int rideId,
    required double amount,
    required String driverId,
    required String paymentMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    print('💰 Processando pagamento: $paymentMethod - R\$ ${amount.toStringAsFixed(2)}');
    
    // Calculate fees first
    final feesBreakdown = calculateFeesBreakdown(
      rideAmount: amount,
      paymentMethod: paymentMethod,
    );
    
    switch (paymentMethod) {
      case 'card_machine':
        final result = await processCardMachinePayment(
          rideId: rideId,
          amount: amount,
          driverId: driverId,
          cardType: additionalData?['card_type'] ?? 'credit',
        );
        result['fees_breakdown'] = feesBreakdown;
        return result;
        
      case 'pix':
        final result = await processPIXPayment(
          rideId: rideId,
          amount: amount,
          driverId: driverId,
        );
        result['fees_breakdown'] = feesBreakdown;
        return result;
        
      case 'cash':
        final result = await processCashPayment(
          rideId: rideId,
          amount: amount,
          driverId: driverId,
        );
        result['fees_breakdown'] = feesBreakdown;
        return result;
        
      case 'wallet':
        final result = await processWalletPayment(
          rideId: rideId,
          amount: amount,
          driverId: driverId,
        );
        result['fees_breakdown'] = feesBreakdown;
        return result;
        
      default:
        return {
          'success': false,
          'error': 'Método de pagamento inválido',
          'message': 'Selecione um método de pagamento válido',
        };
    }
  }

  // Check driver card machine availability
  static Future<bool> checkDriverCardMachineAvailable(String driverId) async {
    try {
      final response = await _apiClient.get('/api/drivers/$driverId/card-machine-status');
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data['card_machine_available'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Erro ao verificar maquininha do motorista: $e');
      return false;
    }
  }

  // Get driver payment methods available
  static Future<List<String>> getDriverPaymentMethods(String driverId) async {
    try {
      final response = await _apiClient.get('/api/drivers/$driverId/payment-methods');
      
      if (response.statusCode == 200 && response.data != null) {
        return List<String>.from(response.data['available_methods'] ?? []);
      }
      return ['cash']; // Fallback para dinheiro apenas
    } catch (e) {
      print('❌ Erro ao buscar métodos de pagamento do motorista: $e');
      return ['cash'];
    }
  }
}