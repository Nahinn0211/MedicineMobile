import 'package:flutter/material.dart';

class AddressManagementPage extends StatefulWidget {
  AddressManagementPage({
    Key? key,
  }) : super(key: key);

  @override
  _AddressManagementPageState createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {

  List<Address> addresses = []; // Initialize as empty list


  void _addNewAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressPage(
          onAddressAdded: (Address newAddress) {
            setState(() {
              // Add the new address to our list
              addresses.add(newAddress);

              // If the new address is default, update other addresses
              if (newAddress.isDefault) {
                for (int i = 0; i < addresses.length - 1; i++) {
                  if (addresses[i].isDefault) {
                    // Create a new address with isDefault set to false
                    addresses[i] = Address(
                      name: addresses[i].name,
                      phone: addresses[i].phone,
                      fullAddress: addresses[i].fullAddress,
                      isDefault: false,
                    );
                  }
                }
              }
            });
          },
        ),
      ),
    );
  }

  void _editAddress(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressPage(
          existingAddress: addresses[index],
          onAddressAdded: (Address updatedAddress) {
            setState(() {
              // Update the address at this index
              addresses[index] = updatedAddress;

              // If the updated address is default, update other addresses
              if (updatedAddress.isDefault) {
                for (int i = 0; i < addresses.length; i++) {
                  if (i != index && addresses[i].isDefault) {
                    addresses[i] = Address(
                      name: addresses[i].name,
                      phone: addresses[i].phone,
                      fullAddress: addresses[i].fullAddress,
                      isDefault: false,
                    );
                  }
                }
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Quản lý số địa chỉ',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: addresses.isEmpty
          ? _buildEmptyAddressState()
          : _buildAddressList(),
    );
  }

  Widget _buildEmptyAddressState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location icon with paper planes
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 10,
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 10,
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Quý khách chưa lưu địa chỉ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Cập nhật địa chỉ ngay để có trải nghiệm mua hàng nhanh nhất.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _addNewAddress,
            child: Text(
              'Thêm địa chỉ mới',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: addresses.length + 1, // +1 for the add button
      itemBuilder: (context, index) {
        if (index == addresses.length) {
          // Last item is the "Add New Address" button
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: _addNewAddress,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('Thêm địa chỉ mới'),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          );
        }

        // Regular address items
        final address = addresses[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    if (address.isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Mặc định',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        _editAddress(index);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(address.phone),
                SizedBox(height: 4),
                Text(address.fullAddress),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Simple Address model
class Address {
  final String name;
  final String phone;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.name,
    required this.phone,
    required this.fullAddress,
    this.isDefault = false,
  });
}

// Add Address Page
class AddAddressPage extends StatefulWidget {
  final Function(Address) onAddressAdded;
  final Address? existingAddress;

  AddAddressPage({
    required this.onAddressAdded,
    this.existingAddress,
  });

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if available
    _nameController = TextEditingController(text: widget.existingAddress?.name ?? '');
    _phoneController = TextEditingController(text: widget.existingAddress?.phone ?? '');
    _addressController = TextEditingController(text: widget.existingAddress?.fullAddress ?? '');
    _isDefault = widget.existingAddress?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        name: _nameController.text,
        phone: _phoneController.text,
        fullAddress: _addressController.text,
        isDefault: _isDefault,
      );

      widget.onAddressAdded(address);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Address field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ chi tiết',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Default address checkbox
              CheckboxListTile(
                title: Text('Đặt làm địa chỉ mặc định'),
                value: _isDefault,
                activeColor: Colors.blue,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
              ),

              SizedBox(height: 30),

              // Save button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  child: Text(
                    isEditing ? 'Cập nhật địa chỉ' : 'Lưu địa chỉ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}