import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class Watermaking extends StatefulWidget {
  List<AssetEntity> listAssets;
  File watermark;
  Watermaking({super.key, required this.listAssets, required this.watermark});

  @override
  State<Watermaking> createState() => _WatermakingState();
}

class _WatermakingState extends State<Watermaking> {
  var combinedVariable;
  var watermarkVariable;
  late AssetEntity selectedAsset;
  @override
  void initState() {
    watermarkVariable = _watermark(widget.watermark);
    selectedAsset = widget.listAssets[0];
    super.initState();
  }

  // WidgetsToImageController to access widget
  WidgetsToImageController widgetToImageController = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? finalVersion;
  Widget _imageAssetWidget(BuildContext context, AssetEntity entity) {
    return Image(
      image: AssetEntityImageProvider(entity, isOriginal: true),
      fit: BoxFit.cover,
    );
  }

  Widget _videoAssetWidget(BuildContext context, AssetEntity entity) {
    return Positioned.fill(
      child: Image(
        image: AssetEntityImageProvider(entity, isOriginal: true),
        fit: BoxFit.cover,
      ),
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      top: 0.0,
    );
  }

  Widget _watermark(File watermarkFile) {
    return Container(height: 50, width: 50, child: Image.file(watermarkFile));
  }

  Widget _combined(
      AssetEntity assetEntity, Widget watermakFile, BuildContext context) {
    return WidgetsToImage(
      controller: widgetToImageController,
      child: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (assetEntity.type == AssetType.image)
              _imageAssetWidget(context, assetEntity),
            if (assetEntity.type == AssetType.video)
              _videoAssetWidget(context, assetEntity),
            watermarkVariable,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<AssetEntity> listAssets = widget.listAssets;
    File watermark = widget.watermark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            child: Row(
              children: [
                Icon(
                  Icons.file_present_rounded,
                  size: 15,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  " ${listAssets.length}",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.amber[900],
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            itemBuilder: (context) {
              return List.generate(listAssets.length, (index) {
                return PopupMenuItem(
                  onTap: () {
                    setState(() {
                      selectedAsset = listAssets[index];
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    child: Image(
                      image: AssetEntityImageProvider(listAssets[index],
                          isOriginal: false),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              });
            },
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _combined(selectedAsset, watermarkVariable, context),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (listAssets.length > 1) {
                  for (var i = 0; i < listAssets.length; i++) {
                    setState(() {
                      selectedAsset = listAssets[i];
                    });

                    final bytes = await widgetToImageController.capture();
                    setState(() {
                      finalVersion = bytes;
                    });
                    String extensionname =
                        listAssets[i].type == AssetType.video ? ".mp4" : ".png";
                    try {
                      final Uint8List pngBytes = finalVersion!;
                      final String dir =
                          (await getApplicationDocumentsDirectory()).path;
                      final String fullPath =
                          '$dir/$i-${DateTime.now().millisecond}$extensionname';
                      File watermarkValid = File(fullPath);
                      await watermarkValid.writeAsBytes(pngBytes);
                      if (listAssets[i].type == AssetType.video) {
                        await GallerySaver.saveVideo(watermarkValid.path)
                            .then((value) {
                          setState(() {
                            print(' Video saved!');
                          });
                        });
                      } else {
                        await GallerySaver.saveImage(watermarkValid.path)
                            .then((value) {
                          setState(() {
                            print('Image saved!');
                          });
                        });
                      }
                    } catch (e) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text(e.toString()),
                            );
                          });
                    }
                  }
                } else {
                  final bytes = await widgetToImageController.capture();
                  setState(() {
                    finalVersion = bytes;
                  });

                  String extensionname =
                      selectedAsset.type == AssetType.video ? ".mp4" : ".png";
                  try {
                    final Uint8List pngBytes = finalVersion!;
                    final String dir =
                        (await getApplicationDocumentsDirectory()).path;
                    final String fullPath =
                        '$dir/${DateTime.now().microsecond}-${DateTime.now().millisecond}$extensionname';
                    File watermarkValid = File(fullPath);
                    await watermarkValid.writeAsBytes(pngBytes);

                    await GallerySaver.saveImage(watermarkValid.path)
                        .then((value) {
                      setState(() {
                        print('screenshot saved!');
                      });
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text("File Saved successfully."),
                            );
                          });
                    });
                    if (selectedAsset.type == AssetType.video) {
                      await GallerySaver.saveVideo(watermarkValid.path)
                          .then((value) {
                        setState(() {
                          print('1 video saved!');
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Video Saved successfully."),
                              );
                            });
                      });
                    } else {
                      await GallerySaver.saveImage(watermarkValid.path)
                          .then((value) {
                        setState(() {
                          print('1 image saved!');
                        });
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Image Saved successfully."),
                              );
                            });
                      });
                    }
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(e.toString()),
                          );
                        });
                  }
                }
              },
              child: Text("Export ${listAssets.length} files"),
            ),
          ],
        ),
      ),
    );
  }
}
