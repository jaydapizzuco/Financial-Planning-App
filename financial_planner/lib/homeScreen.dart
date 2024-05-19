import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login/loginScreen.dart';
import 'models/Balance.dart';
import 'models/UserModel.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'notification.dart';


class HomeScreen extends StatefulWidget {
final String? userId;

HomeScreen({this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  String?  imageId;
  num? _gainedThisMonth;
  num? _spentThisMonth;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
     setUsername();
     setGainedAndSpentThisMonth();
    setState(() {
      isLoading = false;
    });
  }

  void setUsername() async {
    String? name = await getUsernameById(widget.userId);
    setState(() {
      username = name;
    });
  }

  Future<Map<String, dynamic>> fetchImageDetails(String imageId) async {
    final String apiKey = 'Wo-eZKilz0cfrfV_kioT5UpQyrxNv2R0bFf159dNIok';
    final String baseUrl = 'https://api.unsplash.com';
    final String endpoint = '/photos/$imageId';

    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: {
      'Authorization': 'Client-ID $apiKey',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch image details from Unsplash');
    }
  }

  void setGainedAndSpentThisMonth() async {
    num? gains = await getGainedThisMonthAmountById(widget.userId);
    num? spending = await getSpentThisMonthAmountById(widget.userId);
    setState(() {
      _gainedThisMonth = gains;
      _spentThisMonth = spending;
      setImageId();
    });
  }

  void setImageId() {
    if (_gainedThisMonth != null && _spentThisMonth != null) {
      setState(() {
        if (_gainedThisMonth! >= _spentThisMonth!) {
          imageId = "ZVprbBmT8QA";
        } else {
          imageId = "ljnEImGhvgY";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || imageId == null || _gainedThisMonth ==  null || _spentThisMonth == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("HomePage",
                    style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),),
                  Text("Welcome Back ${username}",
                    style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),),

                  FutureBuilder<Map<String, dynamic>>(
                      future: fetchImageDetails(imageId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          final imageUrl = snapshot.data!['urls']['regular'];
                          return Center(
                            child: Image.network(
                              imageUrl,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      }),
                  SizedBox(
                      width: 200,
                      child: ElevatedButton(onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                            builder: (context) => LoginScreen()), (
                            route) => false);
                      }, child: Text("Logout", style: TextStyle(fontSize: 24),)
                      )
                  ),
                ]
            )
        ),
      );
    }
  }

  Future<String?> getUsernameById(String? id) async {
    String? username;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userModel = UserModel.fromSnapshot(querySnapshot.docs.first);
        username = userModel.username;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return username;
  }

  Future<num?> getGainedThisMonthAmountById(String? id) async {
    num? gained;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        gained = balance.gainedThisMonth;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return gained;
  }

  Future<num?> getSpentThisMonthAmountById(String? id) async {
    num? spendings;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Balances')
          .where('userId', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Balance balance = Balance.fromSnapshot(querySnapshot.docs.first);
        spendings = balance.spentThisMonth;
      }
    } catch (error) {
      print('Error getting ID: $error');
    }

    return spendings;
  }
}