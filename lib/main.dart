import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'trade_provider.dart';
import 'storage_service.dart';
import 'notification_service.dart';
import 'trade_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await StorageService.init();
  await StorageService.cleanupExpiredTrades(); 
  await StorageService.closeBox();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TradeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trade Signals',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    final trades = Provider.of<TradeProvider>(context).trades;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trade Signals",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: trades.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.radar,
                    size: 80,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Scanning Market...",
                    style: TextStyle(color: Colors.white.withOpacity(0.3)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final signal = trades[index];
                return Dismissible(
                  key: Key(signal.key.toString()),
                  direction:
                      DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF121212),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    Provider.of<TradeProvider>(
                      context,
                      listen: false,
                    ).removeTrade(signal);
                  },
                  child: TradeCard(
                    signal: signal,
                    onDelete: () {
                      Provider.of<TradeProvider>(
                        context,
                        listen: false,
                      ).removeTrade(signal);
                    },
                  ),
                );
              },
            ),
    );
  }
}
