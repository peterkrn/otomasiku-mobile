import 'package:flutter/material.dart';

/// Cart screen placeholder - to be implemented in M2-4
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: const Center(
        child: Text('Cart'),
      ),
    );
  }
}
