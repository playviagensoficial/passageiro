import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/whatsapp_provider.dart';
import '../../../core/models/whatsapp_message.dart';
import '../../../shared/theme/app_theme.dart';

class WhatsAppHistoryScreen extends StatefulWidget {
  final int? userId;
  final String? userType;
  final bool showHeader;

  const WhatsAppHistoryScreen({
    Key? key,
    this.userId,
    this.userType,
    this.showHeader = true,
  }) : super(key: key);

  @override
  State<WhatsAppHistoryScreen> createState() => _WhatsAppHistoryScreenState();
}

class _WhatsAppHistoryScreenState extends State<WhatsAppHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  WhatsAppStatus? _selectedStatus;
  WhatsAppMessageType? _selectedMessageType;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Inicializa o provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WhatsAppProvider>().initialize(
        userId: widget.userId,
        userType: widget.userType,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      // Carrega mais mensagens quando chega ao final
      context.read<WhatsAppProvider>().loadMoreMessages(
        userId: widget.userId,
        userType: widget.userType,
      );
    }
  }

  void _onRefresh() {
    context.read<WhatsAppProvider>().loadMessageHistory(
      userId: widget.userId,
      userType: widget.userType,
      refresh: true,
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    
    context.read<WhatsAppProvider>().searchMessages(
      query: query.isEmpty ? null : query,
      status: _selectedStatus,
      messageType: _selectedMessageType,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    _selectedStatus = null;
    _selectedMessageType = null;
    
    context.read<WhatsAppProvider>().clearFilters(
      userId: widget.userId,
      userType: widget.userType,
    );
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: widget.showHeader ? _buildAppBar() : null,
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Consumer<WhatsAppProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }

                if (provider.error != null) {
                  return _buildErrorWidget(provider.error!);
                }

                if (provider.messages.isEmpty) {
                  return _buildEmptyWidget();
                }

                return RefreshIndicator(
                  onRefresh: () async => _onRefresh(),
                  color: AppTheme.primaryColor,
                  child: _buildMessagesList(provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      title: const Row(
        children: [
          Icon(Icons.message, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'WhatsApp',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      elevation: 0,
      actions: [
        Consumer<WhatsAppProvider>(
          builder: (context, provider, child) {
            final stats = provider.getQuickStats();
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${stats['total']} mensagens',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[700]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Barra de busca
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar mensagens...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: AppTheme.primaryColor),
                onPressed: _onSearch,
              ),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _onSearch(),
          ),
          
          const SizedBox(height: 12),
          
          // Filtros
          Row(
            children: [
              Expanded(
                child: _buildStatusFilter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMessageTypeFilter(),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _clearFilters,
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white70,
                ),
                tooltip: 'Limpar filtros',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<WhatsAppStatus?>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white),
      items: [
        const DropdownMenuItem<WhatsAppStatus?>(
          value: null,
          child: Text('Todos os status'),
        ),
        ...WhatsAppStatus.values.map((status) {
          return DropdownMenuItem<WhatsAppStatus?>(
            value: status,
            child: Row(
              children: [
                Text(status.emoji),
                const SizedBox(width: 8),
                Text(status.displayName),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
        _onSearch();
      },
    );
  }

  Widget _buildMessageTypeFilter() {
    return DropdownButtonFormField<WhatsAppMessageType?>(
      value: _selectedMessageType,
      decoration: InputDecoration(
        labelText: 'Tipo',
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white),
      items: [
        const DropdownMenuItem<WhatsAppMessageType?>(
          value: null,
          child: Text('Todos os tipos'),
        ),
        ...WhatsAppMessageType.values.map((type) {
          return DropdownMenuItem<WhatsAppMessageType?>(
            value: type,
            child: Text(type.displayName),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedMessageType = value;
        });
        _onSearch();
      },
    );
  }

  Widget _buildMessagesList(WhatsAppProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.messages.length + (provider.hasMoreMessages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.messages.length) {
          // Loading indicator para carregar mais
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ),
          );
        }

        final message = provider.messages[index];
        return _buildMessageCard(message);
      },
    );
  }

  Widget _buildMessageCard(WhatsAppMessage message) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status e tipo
            Row(
              children: [
                _buildStatusChip(message.status),
                const SizedBox(width: 8),
                _buildMessageTypeChip(message.messageType),
                const Spacer(),
                Text(
                  DateFormat('dd/MM HH:mm').format(message.sentAt),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Informações do destinatário
            Row(
              children: [
                Icon(
                  Icons.phone,
                  color: Colors.grey[400],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatPhoneDisplay(message.phone),
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (message.userName != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${message.userName}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Conteúdo da mensagem
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            
            if (message.category != null) ...[
              const SizedBox(height: 8),
              _buildCategoryChip(message.category!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(WhatsAppStatus status) {
    Color backgroundColor;
    switch (status) {
      case WhatsAppStatus.sent:
        backgroundColor = Colors.blue;
        break;
      case WhatsAppStatus.delivered:
        backgroundColor = Colors.green;
        break;
      case WhatsAppStatus.read:
        backgroundColor = Colors.purple;
        break;
      case WhatsAppStatus.failed:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTypeChip(WhatsAppMessageType messageType) {
    final isManual = messageType == WhatsAppMessageType.manual;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isManual ? Colors.orange : Colors.cyan,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isManual ? Icons.person : Icons.auto_awesome,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            messageType.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma mensagem encontrada',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As mensagens do WhatsApp aparecerão aqui',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar mensagens',
            style: TextStyle(
              color: Colors.red[400],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  String _formatPhoneDisplay(String phone) {
    // Remove o código do país (55) se presente
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('55')) {
      cleaned = cleaned.substring(2);
    }
    
    // Formata como (XX) XXXXX-XXXX
    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    }
    
    return phone; // Retorna original se não conseguir formatar
  }
}