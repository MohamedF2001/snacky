import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              width: double.infinity,
              height: 100,
              child: Text("data"),
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Text("Catégorie"),
                TextButton(onPressed: () {}, child: Text("Voir plus"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
