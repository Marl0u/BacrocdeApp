// import 'package:flutter/material.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(); // Initialize Firebase
//   } catch (e) {
//     print('Error initializing Firebase: $e');
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Barcode Scanner Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//       ),
//       home: const HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage();

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final List<String> scannedUnits = [];
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Price Comparison Application'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 final barcodeResult = await scanBarcode(context);
//                 if (barcodeResult != null) {
//                   addOrUpdateProduct(
//                     barcodeResult: barcodeResult,
//                     category: '',
//                     name: '',
//                     units: '',
//                     unitOfMeasure: '',
//                     price: 0.0,
//                   );
//                   setState(() {
//                     scannedUnits.add(barcodeResult);
//                   });
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Scanned Barcode: $barcodeResult'),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Open Scanner'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _retrieveScannedUnits,
//               child: const Text('Retrieve Scanned Units'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<String?> scanBarcode(BuildContext context) async {
//     try {
//       final result = await SimpleBarcodeScannerPage();
//       return result as String?;
//     } catch (e) {
//       print('Error scanning barcode: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error scanning barcode: $e'),
//         ),
//       );
//       return null;
//     }
//   }

//   void addOrUpdateProduct({
//     required String barcodeResult,
//     required String category,
//     required String name,
//     required String units,
//     required String unitOfMeasure,
//     required double price,
//   }) {
//     final productRef = firestore.collection('products').doc(barcodeResult);

//     final pricePerUnitOfMeasure = price / double.parse(units);

//     productRef.get().then((docSnapshot) {
//       if (docSnapshot.exists) {
//         productRef.update({
//           'category': category,
//           'name': name,
//           'units': units,
//           'unitOfMeasure': unitOfMeasure,
//           'price': price,
//           'pricePerUnitOfMeasure': pricePerUnitOfMeasure,
//           'lastUpdated': DateTime.now(),
//         }).then((_) {
//           print('Product with barcode $barcodeResult updated successfully.');
//         }).catchError((error) {
//           print('Error updating product: $error');
//         });
//       } else {
//         productRef.set({
//           'barcode': barcodeResult,
//           'category': category,
//           'name': name,
//           'units': units,
//           'unitOfMeasure': unitOfMeasure,
//           'price': price,
//           'pricePerUnitOfMeasure': pricePerUnitOfMeasure,
//           'created': DateTime.now(),
//         }).then((_) {
//           print('Product with barcode $barcodeResult added successfully.');
//         }).catchError((error) {
//           print('Error adding product: $error');
//         });
//       }
//     }).catchError((error) {
//       print('Error checking product existence: $error');
//     });
//   }

//   void _retrieveScannedUnits() {
//     firestore.collection('products').get().then((querySnapshot) {
//       final List<String> scannedUnitBarcodes = [];
//       for (final doc in querySnapshot.docs) {
//         scannedUnitBarcodes.add(doc['barcode']);
//       }

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Scanned Units'),
//           content: SizedBox(
//             height: 200,
//             child: ListView.builder(
//               itemCount: scannedUnitBarcodes.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(scannedUnitBarcodes[index]),
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         ),
//       );
//     }).catchError((error) {
//       print('Error retrieving scanned units: $error');
//     });
//   }
// }
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green, // Change to Colors.green
      ),
      home: const HomePage(),
    );
  }
}

class PromoDetails {
  String category;
  String name;
  String units;
  String unitOfMeasure;
  double price;
  double pricePerUnitOfMeasure;

  PromoDetails({
    required this.category,
    required this.name,
    required this.units,
    required this.unitOfMeasure,
    required this.price,
  }) : pricePerUnitOfMeasure = _calculatePricePerUnit(price, units);

  static double _calculatePricePerUnit(double price, String units) {
    try {
      final doubleUnits = double.parse(units);
      return price / doubleUnits;
    } catch (e) {
      print('Error parsing units: $e');
      return 0.0; // Return a default value or handle the error as needed
    }
  }
}



class HomePage extends StatefulWidget {

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String barcodeResult = '';
  List<PromoDetails> promoList = [
    PromoDetails(
      category: 'Electronics',
      name: 'Smartphone',
      units: '10',
      unitOfMeasure: 'Pieces',
      price: 500.0,
    ),
    PromoDetails(
      category: 'Groceries',
      name: 'Baked Beans',
      units: '10',
      unitOfMeasure: 'kg',
      price: 15.0,
    ),
    PromoDetails(
      category: 'Clothing',
      name: 'T-Shirt',
      units: '5',
      unitOfMeasure: 'Pieces',
      price: 20.0,
    ),
    // Add more PromoDetails objects as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await scanBarcode(context);
                setState(() {
                  barcodeResult = result as String;
                });
                _showPromoForm(context);
              },
              child: const Text('Open Scanner'),
            ),
            Text('Barcode Result: $barcodeResult'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromoListScreen(promoList: promoList),
                  ),
                );
              },
              child: const Text('View Promo List'),
            ),
          ],
        ),
      ),
    );
  }

  Future<SimpleBarcodeScannerPage?> scanBarcode(BuildContext context) async {
    try {
      final result = await const SimpleBarcodeScannerPage();
      return result; // Return the result directly
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

  void _showPromoForm(BuildContext context) {
    String category = '';
    String name = '';
    String units = '';
    String unitOfMeasure = '';
    double price = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fill in Promo Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  category = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Units'),
                onChanged: (value) {
                  units = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Unit of Measure'),
                onChanged: (value) {
                  unitOfMeasure = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                onChanged: (value) {
                  price = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final promoDetails = PromoDetails(
                  category: category,
                  name: name,
                  units: units,
                  unitOfMeasure: unitOfMeasure,
                  price: price,
                );
                _addOrUpdatePromo(promoDetails);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addOrUpdatePromo(PromoDetails newPromo) {
    bool found = false;
    for (int i = 0; i < promoList.length; i++) {
      if (promoList[i].name == newPromo.name) {
        promoList[i] = newPromo;
        found = true;
        break;
      }
    }
    if (!found) {
      promoList.add(newPromo);
    }
    setState(() {});
  }
}
class PromoListScreen extends StatelessWidget {
  final List<PromoDetails> promoList;
  const PromoListScreen({Key? key, required this.promoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort promoList in descending order based on unitOfMeasure
    promoList.sort((a, b) => b.unitOfMeasure.compareTo(a.unitOfMeasure));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo List'),
      ),
      body: GridView.builder(
        itemCount: promoList.isEmpty ? 1 : promoList.length + 1, // Add one for the header row
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // Adjusted to fit the new column
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Display headers
            return Card(
              color: Theme.of(context).primaryColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  Text(
                    'Units',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  Text(
                    'Unit of Measure',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  Text(
                    'Price',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                  Text(
                    'Price Per Unit', // New column header
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent),
                  ),
                ],
              ),
            );
          } else {
            // Display promo details
            final promo = promoList[index - 1];
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(promo.category),
                  Text(promo.name),
                  Text(promo.units),
                  Text(promo.unitOfMeasure),
                  Text(promo.price.toString()),
                  Text(promo.pricePerUnitOfMeasure.toString()), // Display pricePerUnitOfMeasure
                ],
              ),
            );
          }
        },
      ),
    );
  }
}



