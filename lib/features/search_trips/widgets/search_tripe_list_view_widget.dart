import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_item_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class SearchTripeListViewWidget extends StatelessWidget {
  const SearchTripeListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return SearchTripeItemWidget();
        });
  }
}
