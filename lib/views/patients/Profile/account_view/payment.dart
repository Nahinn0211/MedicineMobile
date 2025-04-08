import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Model class for credit card information
class CreditCard {
  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final String cvv;
  final String cardType; // Visa, MasterCard, JCB

  CreditCard({
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.cvv,
    required this.cardType,
  });

  // Get last 4 digits of card number
  String get lastFourDigits => cardNumber.length > 4
      ? cardNumber.substring(cardNumber.length - 4)
      : cardNumber;

  // Get card type icon
  IconData get cardTypeIcon {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'jcb':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}

class AccountViewPaymentMethodPage extends StatefulWidget {
  @override
  _AccountViewPaymentMethodPageState createState() => _AccountViewPaymentMethodPageState();
}

class _AccountViewPaymentMethodPageState extends State<AccountViewPaymentMethodPage> {
  // List to store saved cards
  List<CreditCard> savedCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Quản lý thẻ thanh toán',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Main content with Expanded to fill the available space
          Expanded(
            child: savedCards.isEmpty
                ? _buildEmptyState()
                : _buildSavedCardsView(),
          ),

          // Info text about supported card types
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Áp dụng với thẻ quốc tế Visa, Master, JCB',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // "Add card" button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to add card screen and wait for result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPaymentCardPage()),
                  );

                  // If a new card was added, update the state
                  if (result != null && result is CreditCard) {
                    setState(() {
                      savedCards.add(result);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Thêm thẻ',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),

          // Bottom spacer to ensure the button isn't too close to the bottom
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Widget to display when no cards are saved
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Credit card illustration
          Image.asset(
            'assets/images/credit_card_placeholder.png',
            width: 200,
            height: 160,
            // If you don't have this image, you can use a placeholder:
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 160,
                color: Colors.grey[200],
                child: Icon(
                  Icons.credit_card,
                  size: 80,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // "No payment methods" text
          Text(
            'Chưa có thẻ thanh toán nào.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display saved cards
  Widget _buildSavedCardsView() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: savedCards.length,
      itemBuilder: (context, index) {
        final card = savedCards[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blue.shade200, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Card type and actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(card.cardTypeIcon, color: Colors.blue, size: 32),
                        SizedBox(width: 8),
                        Text(
                          card.cardType,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteCard(index);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa thẻ'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Card details
                Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      '**** **** **** ${card.lastFourDigits}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Cardholder name
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      card.cardholderName,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Expiry date
                Row(
                  children: [
                    Icon(Icons.date_range, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Hạn thẻ: ${card.expiryDate}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to delete a card
  void _deleteCard(int index) {
    setState(() {
      savedCards.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa thẻ thanh toán')),
    );
  }
}

// AddPaymentCardPage for adding a new payment card
class AddPaymentCardPage extends StatefulWidget {
  @override
  _AddPaymentCardPageState createState() => _AddPaymentCardPageState();
}

class _AddPaymentCardPageState extends State<AddPaymentCardPage> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _cardholderName = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardType = 'Visa'; // Default card type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Thêm thẻ thanh toán',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card type selection
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Loại thẻ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                value: _cardType,
                items: ['Visa', 'MasterCard', 'JCB'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _cardType = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Card information fields
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Số thẻ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                onChanged: (value) {
                  setState(() {
                    _cardNumber = value.replaceAll(' ', ''); // Remove spaces for storage
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số thẻ';
                  }
                  if (_cardNumber.length < 16) {
                    return 'Số thẻ phải có 16 chữ số';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên chủ thẻ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                onChanged: (value) {
                  setState(() {
                    _cardholderName = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên chủ thẻ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              Row(
                children: [
              Expanded(
              child: GestureDetector(
              onTap: () async {
      // Show custom Month and Year picker
      final selectedDate = await _selectExpiryDate(context);
      if (selectedDate != null) {
      setState(() {
      _expiryDate = selectedDate;
      });
      }
      },
        child: AbsorbPointer(
          // Disable manual input
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Hạn thẻ (MM/YY)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.date_range),
            ),
            controller: TextEditingController(text: _expiryDate),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập hạn thẻ';
              }
              if (!_validateExpiryDate(value)) {
                return 'Hạn thẻ không hợp lệ';
              }
              return null;
            },
          ),
        ),
              )
              ),

                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3), // Limit input to 3 characters
                        FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      ],
                      onChanged: (value) {
                        setState(() {
                          _cvv = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập CVV';
                        }
                        if (value.length != 3) {
                          return 'CVV phải là 3 chữ số';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Support text
              Text(
                'Áp dụng với thẻ quốc tế Visa, Master, JCB',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create new card object
                      final newCard = CreditCard(
                        cardNumber: _cardNumber,
                        cardholderName: _cardholderName,
                        expiryDate: _expiryDate,
                        cvv: _cvv,
                        cardType: _cardType,
                      );

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã lưu thẻ thanh toán')),
                      );

                      // Return to previous screen with the new card
                      Navigator.pop(context, newCard);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Lưu thẻ',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateExpiryDate(String input) {
    if (input.length != 5) return false;
    final parts = input.split('/');
    if (parts.length != 2) return false;

    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    // Check if the card is not expired
    final now = DateTime.now();
    final cardYear = 2000 + year; // Assuming 20xx format

    if (cardYear < now.year) return false;
    if (cardYear == now.year && month < now.month) return false;

    return true;
  }
}

Future<String?> _selectExpiryDate(BuildContext context) async {
  DateTime now = DateTime.now();
  DateTime initialDate = DateTime(now.year, now.month);

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(now.year, now.month),
    lastDate: DateTime(now.year + 25),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue, // Header background color
            onPrimary: Colors.white, // Header text color
            onSurface: Colors.black, // Body text color
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    final selectedMonth = picked.month.toString().padLeft(2, '0');
    final selectedYear = picked.year.toString().substring(2); // get last 2 digits of the year
    return '$selectedMonth/$selectedYear'; // Return in MM/YY format
  }
  return null;
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(' ', '');

    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    // Format the text with spaces every 4 digits
    var newText = '';
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        newText += ' ';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}