import 'dart:async';

import 'package:flutter/material.dart';

alertProcess(BuildContext context, StreamController<double> controller,
    double curentCount) {
  return showDialog(
      context: context,
      builder: (context) {
        return StreamBuilder(
            stream: controller.stream,
            builder: (context, AsyncSnapshot<double> snap) {
              double data = snap.data ?? 0.0;
              print("\n");
              print("\n");
              print("\n");
              print("\n");
              print(data);
              print("\n");
              print("\n");
              print("\n");
              print("\n");
              return AlertDialog(
                // title: const Text("Diabetes Prediction"),
                content: Container(
                  alignment: FractionalOffset.center,
                  height: 80.0,
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (data < 99) ? CircularProgressIndicator() : SizedBox(),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        // child: Text("Exporting...\n Please wait."),
                        child: Text((data < 100.0)
                            ? "Exporting...(${curentCount.toInt()}%)"
                            : "Exported successfully."),
                      ),
                    ],
                  ),
                ),
                actions: (data > 99)
                    ? [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK"),
                        ),
                      ]
                    : null,
              );
            });
      });
}
