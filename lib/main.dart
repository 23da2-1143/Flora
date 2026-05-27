import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'utils/app_theme.dart';
import 'models/cart.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/shop/product_details_screen.dart';
import 'screens/cart/checkout_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/my_orders_screen.dart';
import 'screens/profile/wishlist_screen.dart';
import 'screens/profile/shipping_addresses_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/manage_products_screen.dart';
import 'screens/profile/add_edit_product_screen.dart';
import 'models/product.dart';

import 'models/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirestoreService.seedProductsIfNeeded();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const FloraFernApp(),
    ),
  );
}

class FloraFernApp extends StatelessWidget {
  const FloraFernApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return MaterialApp(
      title: 'Flora & Fern',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigation(),
        '/checkout': (context) => const CheckoutScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/my-orders': (context) => const MyOrdersScreen(),
        '/wishlist': (context) => const WishlistScreen(),
        '/shipping-addresses': (context) => const ShippingAddressesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/manage-products': (context) => const ManageProductsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-details') {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          );
        }
        if (settings.name == '/add-edit-product') {
          final product = settings.arguments as Product?;
          return MaterialPageRoute(
            builder: (context) => AddEditProductScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
