import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'pages/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';
import 'pages/analytics_screen.dart';
import 'pages/goals_page.dart';
import 'pages/money_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AnalyticsApp());
}

const _defaultLightColorScheme = ColorScheme.light();
const _defaultDarkColorScheme = ColorScheme.dark();

class AnalyticsApp extends StatelessWidget {
  const AnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = _defaultLightColorScheme;
          darkColorScheme = _defaultDarkColorScheme;
        }

        return MaterialApp(
          title: 'Analytics',
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          // themeMode: ThemeMode.system, // You can manage this via settings later
          home: const MainScreen(), // Changed to MainScreen
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to Home/Analytics

  // Placeholder for actual pages/content
  Widget _getPage(int index) {
    switch (index) {
      case 0: // Home/Analytics
        return AnalyticsContent();
      case 1: // Money
        return const MoneyPage();
      case 2: // Graph - Now points to AnalyticsContent
        return AnalyticsContent(); // Changed this line
      case 3: // Target
        return const GoalsPage();
      case 4: // User/Settings
        return const SettingsScreen();
      default:
        return AnalyticsContent(); // Fallback
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = "Home";
    switch (_selectedIndex) {
      case 0:
        appBarTitle = "Home";
        break;
      case 1:
        appBarTitle = "Money";
        break;
      case 2:
        appBarTitle = "Analytics";
        break;
      case 3:
        appBarTitle = "Target";
        break;
      case 4:
        appBarTitle = "Settings";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        centerTitle: true,
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16), // Adjusted padding for 5 items
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(Icons.home_filled, "Home", 0),
              _buildNavIcon(Icons.attach_money, "Money", 1),
              _buildNavIcon(Icons.bar_chart_outlined, "Graph", 2),
              _buildNavIcon(Icons.flag, "Target", 3), // New Target icon
              _buildNavIcon(Icons.settings, "Settings", 4),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildNavIcon(IconData iconData, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final Color highlightColor = Theme.of(context).colorScheme.secondaryContainer;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavTap(index),
        borderRadius: BorderRadius.circular(24), // Should match highlight's border radius
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0), // Adjusted margin for 5 items
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: isSelected
              ? BoxDecoration(
                  color: highlightColor,
                  borderRadius: BorderRadius.circular(24),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
