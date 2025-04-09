import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (scaffoldContext) =>
        cartService.items.isEmpty
            ? Center(
          child: Text(
            'Giỏ hàng trống',
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          children: [
            // Chọn tất cả & tiếp tục mua sắm
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
                    onPressed: () {
                      Navigator.pop(scaffoldContext); // Tiếp tục mua sắm
                    },
                    child: Text(
                      "Tiếp tục mua sắm",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách sản phẩm trong giỏ hàng
            Expanded(
              child: ListView.builder(
                itemCount: cartService.items.length,
                itemBuilder: (context, index) {
                  final cartItem = cartService.items[index];
                  final medicine = cartItem.medicine;
                  final attribute = cartItem.attribute;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: _buildProductImage(
                          medicine.medias.isNotEmpty
                              ? medicine.medias[0].mediaUrl
                              : ''), // Kiểm tra và hiển thị mediaUrl
                      title: Text(
                        medicine.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            '${attribute.priceOut}đ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.grey),
                                onPressed: () {
                                  cartService.removeFromCart(cartItem);
                                },
                              ),
                              _buildQuantitySelector(cartService, cartItem),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Thanh toán
            _buildCheckoutSection(cartService, scaffoldContext),
          ],
        ),
      ),
    );
  }

// Widget hiển thị tổng tiền & nút "Mua hàng"
  Widget _buildCheckoutSection(CartService cartService, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thành tiền",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${cartService.total.toStringAsFixed(0)}đ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: cartService.items.isNotEmpty
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CheckoutPage(cartItems: cartService.items),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              minimumSize: Size(double.infinity, 48),
            ),
            child: Text(
              "Mua hàng",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductImage(String imageUrl) {
    return Image.network(
      imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/60', // Sử dụng placeholder nếu không có hình ảnh
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.broken_image, size: 50, color: Colors.grey);
      },
    );
  }
  Widget _buildQuantitySelector(CartService cartService, CartItem cartItem) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.blue),
          onPressed: cartItem.quantity > 1
              ? () {
            cartService.updateQuantity(cartItem, cartItem.quantity - 1);
          }
              : null,
        ),
        Text(
          '${cartItem.quantity}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: () {
            cartService.updateQuantity(cartItem, cartItem.quantity + 1);
          },
        ),
      ],
    );
  }
}