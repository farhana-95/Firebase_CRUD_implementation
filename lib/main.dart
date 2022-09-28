import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _products=
  FirebaseFirestore.instance.collection('products');

  

  final TextEditingController _nameController= TextEditingController();
  final TextEditingController _priceController= TextEditingController();
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if(documentSnapshot != null) {
      _nameController.text = documentSnapshot['Name'];
      _priceController.text = documentSnapshot['Price'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx){
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      final String name= _nameController.text;
                      final double? price =
                      double.tryParse(_priceController.text);
                      if(price != null){
                        await _products
                            .doc(documentSnapshot!.id)
                            .update({"Name": name, "Price": price});
                        _nameController.text='';
                        _priceController.text='';
                      }
                    }
                )
              ],
            ),
          );
        }
    );
  }
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    if(documentSnapshot != null) {
      _nameController.text = documentSnapshot['Name'];
      _priceController.text = documentSnapshot['Price'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx){
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      final String name= _nameController.text;
                      final double? price =
                      double.tryParse(_priceController.text);
                      if(price != null){
                        await _products.add({"Name": name, "Price": price});
                        _nameController.text='';
                        _priceController.text='';
                      }
                    }
                )
              ],
            ),
          );
        }
    );
  }
  Future<void> _delete(String productId) async{
    await _products.doc(productId).delete();
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Product Deleted!")
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: ()=> _create(),
        backgroundColor: Color(0xFF580565),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
          if(streamSnapshot.hasData){
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index){
                final DocumentSnapshot documentSnapshot=
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['Name']),
                    subtitle: Text(documentSnapshot['Price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit, color: Color(
                          0xFF580565)),
                              onPressed: ()=>
                                  _update(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete, color: Color(
                                  0xFF580565),),
                              onPressed: ()=>
                                  _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },

            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

    );
  }
}


