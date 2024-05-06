import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class CoffeeItem {
  final String name;
  final double price;
  final String imageAsset;

  CoffeeItem({required this.name, required this.price, required this.imageAsset});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CoffeeMenu(),
    );
  }
}

class CoffeeMenu extends StatefulWidget {
  @override
  _CoffeeMenuState createState() => _CoffeeMenuState();


}

class _CoffeeMenuState extends State<CoffeeMenu> {
  final List<CoffeeItem> _menuItems = [
    CoffeeItem(name: 'Espresso', price: 7, imageAsset: 'assets/espresso.png'),
    CoffeeItem(name: 'Latte', price: 13, imageAsset: 'assets/latte.png'),
    CoffeeItem(name: 'Cappuccino', price: 11, imageAsset: 'assets/cappuccino.png'),
    CoffeeItem(name: 'Mocha', price: 14, imageAsset: 'assets/mocha.png'),
  ];

  final Map<CoffeeItem, int> _cartItems = {};

  double _totalPrice = 0.0;

  void _addToCart(CoffeeItem item) {
    setState(() {
      if (_cartItems.containsKey(item)) {
        _cartItems[item] = _cartItems[item]! + 1;
      } else {
        _cartItems[item] = 1;
      }
      _totalPrice += item.price;
    });
  }

  void _removeFromCart(CoffeeItem item) {
    setState(() {
      int quantity = _cartItems[item] ?? 0;
      if (quantity > 0) {
        _cartItems[item] = quantity - 1;
        if (quantity == 1) {
          _cartItems.remove(item);
        }
        _totalPrice -= item.price;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _totalPrice = 0.0;
    });
  }

  void _navigateToOrderSummary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummary(
          cartItems: _cartItems,
          totalPrice: _totalPrice,
          onOrderSubmitted: () => _clearCart(),
          removeFromCart: _removeFromCart, // Pass the method reference
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 7),
        child: Container(
          color: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Center(
            child: Text(
              'Coffee Shop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.brown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Image.asset(
                        item.imageAsset,
                        width: 50,
                        height: 50,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _addToCart(item),
                          ),
                        ],
                      ),
                      subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${_totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _clearCart(),
                  child: const Text('Clear Cart'),
                ),
                ElevatedButton(
                  onPressed: () => _navigateToOrderSummary(context),
                  child: const Text('View Order'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummary extends StatefulWidget {
  final Map<CoffeeItem, int> cartItems;
  double totalPrice;
  final VoidCallback onOrderSubmitted;
  final Function(CoffeeItem) removeFromCart;

  OrderSummary({
    required this.cartItems,
    required this.totalPrice,
    required this.onOrderSubmitted,
    required this.removeFromCart,
  });

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 6),
        child: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Order Summary',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.brown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems.keys.elementAt(index);
                  int quantity = widget.cartItems[item]!;
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Image.asset(
                        item.imageAsset,
                        width: 50,
                        height: 50,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$quantity ${item.name}'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (quantity > 0) {
                                      widget.removeFromCart(item);
                                      quantity--; // Decrement the quantity
                                      if (quantity == 0) {
                                        widget.cartItems.remove(item);
                                      } else {
                                        widget.cartItems[item] = quantity;
                                      }
                                      widget.totalPrice -= item.price; // Update the total price
                                    }
                                  });
                                },
                              ),

                              Text(quantity.toString()),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Text('\$${(item.price * quantity).toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${widget.totalPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.onOrderSubmitted();
                  Navigator.pop(context);
                },
                child: const Text('Submit Order'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Menu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
