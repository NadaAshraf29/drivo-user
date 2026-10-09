import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ChooseWidget extends StatefulWidget {
  final List<String> nameList;
  final List<Widget>? nameWidget;

  const ChooseWidget({
    super.key,
    required this.nameList,
    this.nameWidget,
  });

  @override
  State<ChooseWidget> createState() => _ChooseWidgetState();
}

int selectedIndex = 0;

class _ChooseWidgetState extends State<ChooseWidget> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              widget.nameList.length,
              (index) {
                bool isSelect = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    width: size.width * 0.24,
                    height: size.height * 0.05 + 6,
                    duration: Duration(milliseconds: 500),
                    margin:
                        EdgeInsets.symmetric(horizontal: size.width * 0.01 + 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isSelect
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                    ),
                    child: Center(
                      child: Text(
                        widget.nameList[index],
                        style: isSelect
                            ? textMedium.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).cardColor)
                            : textRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryFixed),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        widget.nameWidget?[selectedIndex] ?? SizedBox.shrink(),
      ],
    );
  }
}
