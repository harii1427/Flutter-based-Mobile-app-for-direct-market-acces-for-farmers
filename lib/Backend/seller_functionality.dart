// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:far/Frontend/details_page.dart';
import 'package:far/utils/api.dart';

Future<void> fetchUserId(BuildContext context, StateSetter setState,
    Function(String?) setUserId, Function fetchVegetables) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    setState(() {
      setUserId(user.uid);
    });
    fetchVegetables();
  }
}

Future<void> fetchVegetablesData(BuildContext context, String? userId,
    StateSetter setState, Function(List<dynamic>, bool) setVegetablesLoading) async {
  if (userId == null) return;

  setState(() {
    setVegetablesLoading([], true);
  });

  final response = await http.get(
    Uri.parse(
        'http://192.168.118.161:8000/api/categoryFieldsByUserId?user_id=$userId'),
  );

  if (response.statusCode == 200) {
    setState(() {
      setVegetablesLoading(json.decode(response.body), false);
    });
  } else {
    setState(() {
      setVegetablesLoading([], false);
    });
  }
}

Future<void> deleteVegetable(BuildContext context, String userId, String categoryFieldsId,
    StateSetter setState, List<dynamic> vegetables) async {
  final response = await http.delete(
    Uri.parse(
        'http://192.168.118.161:8000/api/categoryFields/$userId/$categoryFieldsId'),
  );

  if (response.statusCode == 200) {
    setState(() {
      vegetables.removeWhere((vegetable) => vegetable['_id'] == categoryFieldsId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category field deleted successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete category field')),
    );
  }
}

void showDeleteConfirmationDialog(BuildContext context, String categoryFieldsId,
    List<dynamic> vegetables, StateSetter setState) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              deleteVegetable(context, FirebaseAuth.instance.currentUser!.uid,
                  categoryFieldsId, setState, vegetables);
              Navigator.of(context).pop();
            },
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}

void editVegetable(BuildContext context, Vegetable vegetable, List<dynamic> vegetables,
    StateSetter setState) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailsPage(
        vegetable: vegetable,
        isEditMode: true,
        onVegetableUpdated: (updatedVegetable) {
          if (updatedVegetable != null) {
            setState(() {
              final index =
                  vegetables.indexWhere((v) => v['_id'] == updatedVegetable.id);
              if (index != -1) {
                vegetables[index] = updatedVegetable.toJson();
              }
            });
          }
        }, animal: null,
      ),
    ),
  );
}
