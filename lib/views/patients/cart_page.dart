import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../widgets/HomeWidget/bottom_bar.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final cartMapEntries = cartService.itemsMap.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Builder(
          builder: (scaffoldContext) => cartService.items.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey[400]),
                SizedBox(height: 12),
                Text(
                  'Giỏ hàng trống',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
              : Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: cartService.isAllSelected,
                          onChanged: (value) {
                            cartService.toggleSelectAll(value!);
                          },
                        ),
                        Text(
                          "Chọn tất cả (${cartService.items.length})",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Tiếp tục mua sắm",
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemCount: cartMapEntries.length,
                  itemBuilder: (context, index) {
                    final entry = cartMapEntries[index];
                    final key = entry.key;
                    final cartItem = entry.value;
                    final medicine = cartItem.medicine;
                    final attribute = cartItem.attribute;

                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: cartItem.isSelected,
                                onChanged: (value) {
                                  cartService.toggleItemSelection(key, value!);
                                },
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildProductImage(
                                  medicine.medias.isNotEmpty
                                      ? medicine.medias[0].mediaUrl
                                      : '',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicine.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${attribute.priceOut}đ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildQuantitySelector(cartService, cartItem, key),
                                    Spacer(),
                                    IconButton(
                                      icon: Icon(Icons.delete_forever_outlined,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        _showDeleteConfirmationDialog(context, cartService, key);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildCheckoutSection(cartService, context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 2,
        bottomNavType: BottomNavigationBarType.fixed,
        onTap: (index) {},
        onNavTypeChanged: (_) {},
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Image.network(
      imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/60',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: 50, color: Colors.grey);
      },
    );
  }

  Widget _buildQuantitySelector(
      CartService cartService, CartItem cartItem, String key) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 20),
            onPressed: cartItem.quantity > 1
                ? () {
              cartService.updateQuantity(key, cartItem.quantity - 1);
            }
                : null,
          ),
          Text(
            '${cartItem.quantity}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 20),
            onPressed: () {
              cartService.updateQuantity(key, cartItem.quantity + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(CartService cartService, BuildContext context) {
    final selectedItems =
    cartService.items.where((item) => item.isSelected).toList();
    final totalSelected =
    selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Thành tiền:", style: TextStyle(fontSize: 16)),
              Text(
                '${totalSelected.toStringAsFixed(0)}đ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: selectedItems.isNotEmpty
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CheckoutPage(cartItems: selectedItems),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              minimumSize: Size(double.infinity, 50),
              elevation: 2,
            ),
            icon: Icon(Icons.shopping_bag),
            label: Text(
              "Mua hàng",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, CartService cartService, String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Xác nhận xóa"),
          content:
          Text("Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                cartService.removeFromCart(key);
                Navigator.of(context).pop();
              },
              child: Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
