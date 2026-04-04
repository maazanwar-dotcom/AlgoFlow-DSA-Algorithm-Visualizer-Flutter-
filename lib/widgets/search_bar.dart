import 'package:flutter/material.dart';

getSearchBar(
  String hintText,
  TextEditingController searchController,
  ValueChanged<String> onChanged,
) {
  return TextField(
    controller: searchController,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(Icons.search_outlined),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),

        borderSide: BorderSide.none,
      ),
    ),
  );
}
