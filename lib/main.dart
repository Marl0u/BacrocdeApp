import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(); // Initialize Firebase
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> scannedUnits = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Comparison Application'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final barcodeResult = await scanBarcode(context);
                if (barcodeResult != null) {
                  addOrUpdateProduct(
                    barcodeResult: barcodeResult,
                    category: '',
                    name: '',
                    units: '',
                    unitOfMeasure: '',
                    price: 0.0,
                  );
                  setState(() {
                    scannedUnits.add(barcodeResult);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Scanned Barcode: $barcodeResult'),
                    ),
                  );
                }
              },
              child: const Text('Open Scanner'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retrieveScannedUnits,
              child: const Text('Retrieve Scanned Units'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> scanBarcode(BuildContext context) async {
    try {
      final result = await SimpleBarcodeScannerPage();
      return result as String?;
    } catch (e) {
      print('Error scanning barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning barcode: $e'),
        ),
      );
      return null;
    }
  }

  void addOrUpdateProduct({
    required String barcodeResult,
    required String category,
    required String name,
    required String units,
    required String unitOfMeasure,
    required double price,
  }) {
    final productRef = firestore.collection('products').doc(barcodeResult);

    final pricePerUnitOfMeasure = price / double.parse(units);

    productRef.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        productRef.update({
          'category': category,
          'name': name,
          'units': units,
          'unitOfMeasure': unitOfMeasure,
          'price': price,
          'pricePerUnitOfMeasure': pricePerUnitOfMeasure,
          'lastUpdated': DateTime.now(),
        }).then((_) {
          print('Product with barcode $barcodeResult updated successfully.');
        }).catchError((error) {
          print('Error updating product: $error');
        });
      } else {
        productRef.set({
          'barcode': barcodeResult,
          'category': category,
          'name': name,
          'units': units,
          'unitOfMeasure': unitOfMeasure,
          'price': price,
          'pricePerUnitOfMeasure': pricePerUnitOfMeasure,
          'created': DateTime.now(),
        }).then((_) {
          print('Product with barcode $barcodeResult added successfully.');
        }).catchError((error) {
          print('Error adding product: $error');
        });
      }
    }).catchError((error) {
      print('Error checking product existence: $error');
    });
  }

  void _retrieveScannedUnits() {
    firestore.collection('products').get().then((querySnapshot) {
      final List<String> scannedUnitBarcodes = [];
      for (final doc in querySnapshot.docs) {
        scannedUnitBarcodes.add(doc['barcode']);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scanned Units'),
          content: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: scannedUnitBarcodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(scannedUnitBarcodes[index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      print('Error retrieving scanned units: $error');
    });
  }
}
