import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';

class WalletProvider with ChangeNotifier {
  double _balance = 150.75; // Demo balance
  bool _isLoading = false;
  String? _errorMessage;
  List<WalletTransaction> _transactions = [];

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WalletTransaction> get transactions => _transactions;

  WalletProvider() {
    _loadTransactions();
  }

  void _loadTransactions() {
    // Demo transactions
    _transactions = [
      WalletTransaction(
        id: '1',
        type: TransactionType.credit,
        amount: 100.00,
        description: 'Recarga via PIX',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: '2',
        type: TransactionType.debit,
        amount: 25.50,
        description: 'Corrida - Centro para Aeroporto',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: '3',
        type: TransactionType.debit,
        amount: 18.25,
        description: 'Corrida - Shopping para Casa',
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: TransactionStatus.completed,
      ),
      WalletTransaction(
        id: '4',
        type: TransactionType.credit,
        amount: 50.00,
        description: 'Recarga via Cartão',
        date: DateTime.now().subtract(const Duration(days: 4)),
        status: TransactionStatus.completed,
      ),
    ];
    notifyListeners();
  }

  Future<bool> addFunds({
    required double amount,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      // await ApiClient.instance.addFunds(amount: amount, paymentMethod: paymentMethod);
      
      // Demo implementation
      await Future.delayed(const Duration(seconds: 2));
      
      _balance += amount;
      
      // Add transaction to history
      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.credit,
        amount: amount,
        description: 'Recarga via ${_getPaymentMethodName(paymentMethod)}',
        date: DateTime.now(),
        status: TransactionStatus.completed,
      );
      
      _transactions.insert(0, transaction);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao processar recarga';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> processRecharge({
    required int userId,
    required double amount,
    required String paymentMethod,
    Map<String, String>? cardData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate amount
      if (amount < 5.0) {
        _errorMessage = 'Valor mínimo para recarga é R\$ 5,00';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      if (amount > 1000.0) {
        _errorMessage = 'Valor máximo para recarga é R\$ 1.000,00';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // TODO: Implement actual API call
      // await ApiClient.instance.processRecharge(userId: userId, amount: amount, paymentMethod: paymentMethod, cardData: cardData);
      
      // Demo implementation with different delays based on payment method
      int delay = 2;
      if (paymentMethod == 'pix') {
        delay = 1; // PIX is faster
      } else if (paymentMethod == 'boleto' || paymentMethod == 'bank_transfer') {
        delay = 3; // These take longer to process
      }
      
      await Future.delayed(Duration(seconds: delay));
      
      // Update balance immediately for instant payment methods
      if (paymentMethod == 'pix' || paymentMethod.contains('card')) {
        _balance += amount;
      }
      
      // Add transaction to history
      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.credit,
        amount: amount,
        description: 'Recarga da carteira - ${_getPaymentMethodName(paymentMethod)}',
        date: DateTime.now(),
        status: _getTransactionStatus(paymentMethod),
      );
      
      _transactions.insert(0, transaction);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao processar recarga. Tente novamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdrawFunds({
    required double amount,
    required String bankAccount,
  }) async {
    if (amount > _balance) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));
      
      _balance -= amount;
      
      // Add transaction to history
      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.debit,
        amount: amount,
        description: 'Saque para conta bancária',
        date: DateTime.now(),
        status: TransactionStatus.pending,
      );
      
      _transactions.insert(0, transaction);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshBalance() async {
    try {
      // TODO: Implement actual API call
      // final response = await ApiClient.instance.getWalletBalance();
      // _balance = response.balance;
      
      // Demo: Just reload transactions
      await Future.delayed(const Duration(seconds: 1));
      _loadTransactions();
    } catch (e) {
      debugPrint('Error refreshing balance: $e');
    }
  }

  void debitBalance(double amount, String description) {
    if (amount <= _balance) {
      _balance -= amount;
      
      final transaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: TransactionType.debit,
        amount: amount,
        description: description,
        date: DateTime.now(),
        status: TransactionStatus.completed,
      );
      
      _transactions.insert(0, transaction);
      notifyListeners();
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'pix':
        return 'PIX';
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'debit_card':
        return 'Cartão de Débito';
      case 'boleto':
        return 'Boleto Bancário';
      case 'bank_transfer':
        return 'Transferência Bancária';
      default:
        return 'Outro';
    }
  }

  TransactionStatus _getTransactionStatus(String paymentMethod) {
    switch (paymentMethod) {
      case 'pix':
      case 'credit_card':
      case 'debit_card':
        return TransactionStatus.completed;
      case 'boleto':
      case 'bank_transfer':
        return TransactionStatus.pending;
      default:
        return TransactionStatus.pending;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final TransactionStatus status;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.status,
  });
}

enum TransactionType { credit, debit }
enum TransactionStatus { pending, completed, failed }