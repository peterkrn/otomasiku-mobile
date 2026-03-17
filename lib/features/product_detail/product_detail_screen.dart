import 'package:flutter/material.dart';

/// Product Detail screen placeholder - to be implemented in M2-3
class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: Center(
        child: Text('Product Detail: $productId'),
      ),
    );
  }
}
