import 'package:flutter/material.dart';
import 'package:second_accounting/utils/AppUtils.dart';


class ImageDialog extends StatelessWidget {
  final String img;
  final VoidCallback? onClose;

  const ImageDialog({
    super.key,
    required this.img,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: 600,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder<Image>(
              future: AppUtils.getImagePath2(img),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return snapshot.data!;
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ));
  }
}
