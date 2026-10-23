/*
MINI PRODUCT CATALOG
Active implementation: go_router
The Navigator implementation is preserved in comments at the bottom.

PART 1 — LIFECYCLE ANSWERS

a) When a page opens for the first time, initState(), didChangeDependencies(),
   and build() run in that order. deactivate() and dispose() do not run on
   the first opening.

b) After pressing a favorite button, setState() schedules build() to run again.
   initState() does not run again just because the widget rebuilds.

c) When leaving a page, deactivate() runs when its State is removed from the
   widget tree. dispose() runs when that State is permanently removed.
   When returning to a previous page, it may rebuild. Exact lifecycle logs
   depend on the router and whether a page/state is retained or removed.

d) When the browser is resized, ProductsPage depends on MediaQuery through
   MediaQuery.sizeOf(context). A size change notifies that dependency, so
   didChangeDependencies() runs again and build() updates the layout.

PART 4 — GO_ROUTER ANSWERS

1) context.go() navigates to a location and replaces the current route stack
   configuration. In this app, Login -> Products uses context.goNamed('products').
   context.push() adds a page on top of the current stack. In this app,
   Products -> Details uses context.push<String>(...).

2) We use go for Login -> Products because Login should not remain as a page
   to return to with the app's back navigation. We use push for Products ->
   Details because Details is a temporary page and we need to return to
   Products and receive the Add to Cart result.

3) A query parameter is written after ? in a URL:
   /products?user=Aya (the actual URL value is the name entered by the user)
   A path parameter is part of the path itself:
   /details/Laptop/1200
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'product_widgets.dart';

void main() {
  runApp(const MyApp());
}
final List<Map<String, dynamic>> catalogProducts = [
  {
    'name': 'Laptop',
    'price': 1200,
    'image': 'images/lap.png',
  },
  {
    'name': 'Headphones',
    'price': 150,
    'image': 'images/headphone.png',
  },
  {
    'name': 'Smart Watch',
    'price': 250,
    'image': 'images/smartwatch.png',
  },
  {
    'name': 'Keyboard',
    'price': 80,
    'image': 'images/keyboard.png',
  },
  {
    'name': 'Mouse',
    'price': 40,
    'image': 'images/mouse.png',
  },
  {
    'name': 'Phone',
    'price': 900,
    'image': 'images/phone.png',
  },
];

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (context, state) {
        final username = state.uri.queryParameters['user'] ?? 'Guest';
        return ProductsPage(username: username);
      },
    ),
    GoRoute(
      path: '/details/:name/:price',
      name: 'details',
      builder: (context, state) {
        final name = state.pathParameters['name'] ?? 'Unknown product';
        final price = int.tryParse(state.pathParameters['price'] ?? '') ?? 0;
        return ProductDetailsPage(
          name: name,
          price: price,
          image: catalogProducts.firstWhere(
                (product) => product['name'] == name,
          )['image'] as String,
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A4A53),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8A4A53),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers read the text entered in the two TextFields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('LoginPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('LoginPage: didChangeDependencies');
  }

  void login() {
    final username = nameController.text.trim();
    final email = emailController.text.trim();

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and email.')),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    // Send the entered name to ProductsPage as a query parameter.
    context.goNamed(
      'products',
      queryParameters: {'user': username},
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginPage: build');

    return Scaffold(
      appBar: AppBar(
    title: const Text('Mini Product Catalog'),
    ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to our store!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => login(),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: login,
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint('LoginPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('LoginPage: dispose');
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

class ProductsPage extends StatefulWidget {
  final String username;

  const ProductsPage({super.key, required this.username});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  int favorites = 0;
  Size screenSize = Size.zero;
  String cartMessage = '';

  @override
  void initState() {
    super.initState();
    debugPrint('ProductsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.sizeOf(context);
    debugPrint(
      'ProductsPage: didChangeDependencies -> '
      'width: ${screenSize.width}, height: ${screenSize.height}',
    );
  }

  Future<void> openProduct(int index) async {
    final product = catalogProducts[index];
    final productName = product['name'] as String;
    final productPrice = product['price'] as int;

    final result = await context.push<String>(
      Uri(
        pathSegments: [
          '',
          'details',
          productName,
          productPrice.toString(),
        ],
      ).toString(),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        cartMessage = result;
      });
    }
  }

  void addFavorite() {
    setState(() {
      favorites++;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProductsPage: build');
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Products'),
        ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.username}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('Favorites: $favorites'),
            Text(
              'Screen width: ${screenSize.width.toStringAsFixed(1)} px',
            ),
            if (cartMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                cartMessage,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: isSmallScreen
                  ? ProductsListView(
                      products: catalogProducts,
                      onFavoritePressed: addFavorite,
                      onProductTap: openProduct,
                    )
                  : ProductsGridView(
                      products: catalogProducts,
                      onFavoritePressed: addFavorite,
                      onProductTap: openProduct,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint('ProductsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('ProductsPage: dispose');
    super.dispose();
  }
}

class ProductDetailsPage extends StatefulWidget {
  final String name;
  final int price;
  final String image;

  const ProductDetailsPage({
    super.key,
    required this.name,
    required this.price,
    required this.image,
  });
  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('ProductDetailsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('ProductDetailsPage: didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProductDetailsPage: build');

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.image,
                height: 400,
                width: 400,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '\$${widget.price}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  context.pop('${widget.name} added to cart');
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint('ProductDetailsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('ProductDetailsPage: dispose');
    super.dispose();
  }
}

/*
// ============================================================
// PART 2 — NAVIGATOR VERSION
// Uses MaterialApp, onGenerateRoute, pushNamed, push and pop.
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Product Catalog - Navigator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8A4A53),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8A4A53),
          foregroundColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8A4A53),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const NavigatorLoginPage(),
              settings: settings,
            );

          case '/products':
            final username = settings.arguments as String? ?? 'Guest';

            return MaterialPageRoute(
              builder: (_) => NavigatorProductsPage(
                username: username,
              ),
              settings: settings,
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const NavigatorLoginPage(),
              settings: settings,
            );
        }
      },
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class NavigatorLoginPage extends StatefulWidget {
  const NavigatorLoginPage({super.key});

  @override
  State<NavigatorLoginPage> createState() =>
      _NavigatorLoginPageState();
}

class _NavigatorLoginPageState extends State<NavigatorLoginPage> {
  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('NavigatorLoginPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('NavigatorLoginPage: didChangeDependencies');
  }

  void login() {
    final username = nameController.text.trim();
    final email = emailController.text.trim();

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name and email.'),
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/products',
      arguments: username,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NavigatorLoginPage: build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Product Catalog'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 80,
                  color: Color(0xFF8A4A53),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Welcome to Mini Product Catalog!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => login(),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: login,
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint('NavigatorLoginPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('NavigatorLoginPage: dispose');
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}

// ============================================================
// PRODUCTS PAGE
// ============================================================

class NavigatorProductsPage extends StatefulWidget {
  final String username;

  const NavigatorProductsPage({
    super.key,
    required this.username,
  });

  @override
  State<NavigatorProductsPage> createState() =>
      _NavigatorProductsPageState();
}

class _NavigatorProductsPageState
    extends State<NavigatorProductsPage> {
  int favorites = 0;
  Size screenSize = Size.zero;
  String cartMessage = '';

  @override
  void initState() {
    super.initState();
    debugPrint('NavigatorProductsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    screenSize = MediaQuery.sizeOf(context);

    debugPrint(
      'NavigatorProductsPage: didChangeDependencies -> '
          'width: ${screenSize.width}, '
          'height: ${screenSize.height}',
    );
  }

  Future<void> openProduct(int index) async {
    final product = catalogProducts[index];

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => NavigatorProductDetailsPage(
          name: product['name'] as String,
          price: product['price'] as int,
          image: product['image'] as String,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        cartMessage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NavigatorProductsPage: build');

    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.username}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text('Favorites: $favorites'),

            Text(
              'Screen width: '
                  '${screenSize.width.toStringAsFixed(1)} px',
            ),

            if (cartMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                cartMessage,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 12),

            Expanded(
              child: isSmallScreen
                  ? ProductsListView(
                products: catalogProducts,
                onFavoritePressed: () {
                  setState(() {
                    favorites++;
                  });
                },
                onProductTap: openProduct,
              )
                  : ProductsGridView(
                products: catalogProducts,
                onFavoritePressed: () {
                  setState(() {
                    favorites++;
                  });
                },
                onProductTap: openProduct,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint('NavigatorProductsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('NavigatorProductsPage: dispose');
    super.dispose();
  }
}

// ============================================================
// PRODUCT DETAILS PAGE
// ============================================================

class NavigatorProductDetailsPage extends StatefulWidget {
  final String name;
  final int price;
  final String image;

  const NavigatorProductDetailsPage({
    super.key,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  State<NavigatorProductDetailsPage> createState() =>
      _NavigatorProductDetailsPageState();
}

class _NavigatorProductDetailsPageState
    extends State<NavigatorProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('NavigatorProductDetailsPage: initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint(
      'NavigatorProductDetailsPage: didChangeDependencies',
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('NavigatorProductDetailsPage: build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.image,
                height: 500,
                width: 500,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              ),

              const SizedBox(height: 10),

              Text(
                widget.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '\$${widget.price}',
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF8A4A53),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      '${widget.name} added to cart',
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    debugPrint('NavigatorProductDetailsPage: deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('NavigatorProductDetailsPage: dispose');
    super.dispose();
  }
}
*/