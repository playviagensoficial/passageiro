import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/google_maps_service.dart';

class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final Function(PlaceDetails)? onPlaceSelected;
  final VoidCallback? onChanged;
  final bool enabled;

  const AddressAutocompleteField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.prefixIconColor,
    this.onPlaceSelected,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  List<PlaceAutocomplete> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  bool _isSelectingPlace = false;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay hiding suggestions to allow for tap on suggestion
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _showSuggestions = false;
          });
        }
      });
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    
    // Skip processing if we're in the middle of selecting a place or field is disabled
    if (_isSelectingPlace || !widget.enabled) {
      return;
    }
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (text.length >= 3) {
      // Add debounce to avoid too many API calls
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (!_isSelectingPlace && widget.enabled) {
          _searchPlaces(text);
        }
      });
    } else {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
      });
    }
    
    // Removed widget.onChanged?.call() from here to avoid triggering on every text change
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await GoogleMapsService.getPlaceAutocomplete(query);
      
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _showSuggestions = suggestions.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro na busca de lugares: $e');
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _showSuggestions = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectPlace(PlaceAutocomplete suggestion) async {
    // Set flag to prevent multiple selections
    _isSelectingPlace = true;
    
    // Hide suggestions immediately
    setState(() {
      _showSuggestions = false;
    });

    // Set the text to the full description
    widget.controller.text = suggestion.description;
    
    // Remove focus to hide keyboard
    _focusNode.unfocus();

    // Get place details and notify parent
    if (widget.onPlaceSelected != null) {
      try {
        final details = await GoogleMapsService.getPlaceDetails(suggestion.placeId);
        if (details != null) {
          widget.onPlaceSelected!(details);
          // Call onChanged only after place is selected
          widget.onChanged?.call();
        }
      } catch (e) {
        print('❌ Erro ao buscar detalhes do lugar: $e');
      }
    }
    
    // Reset flag after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _isSelectingPlace = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00FF00), width: 2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  widget.prefixIcon,
                  color: widget.prefixIconColor,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  style: TextStyle(
                    color: widget.enabled ? Colors.white : Colors.grey[400],
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF00FF00),
                      strokeWidth: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Suggestions dropdown
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF333333)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: _suggestions.take(5).map((suggestion) {
                return InkWell(
                  onTap: () => _selectPlace(suggestion),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: _suggestions.indexOf(suggestion) < _suggestions.length - 1
                            ? const BorderSide(color: Color(0xFF333333), width: 0.5)
                            : BorderSide.none,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF00FF00),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.mainText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (suggestion.secondaryText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  suggestion.secondaryText,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}