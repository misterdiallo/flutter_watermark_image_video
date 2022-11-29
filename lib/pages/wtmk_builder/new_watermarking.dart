import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// ignore: must_be_immutable
class NewWatermarking extends StatefulWidget {
  List<AssetEntity> listAssets;
  File watermark;
  NewWatermarking(
      {super.key, required this.listAssets, required this.watermark});

  @override
  State<NewWatermarking> createState() => _NewWatermarkingState();
}

class _NewWatermarkingState extends State<NewWatermarking> {
  final ValueNotifier _process = ValueNotifier(0);
  late String processMessage;
  bool isProcessing = false;
  double processCount = 0;
  //Create an instance of ScreenshotController
  late ScreenshotController screenshotController;

  late AssetEntity selectedAsset;

  late File watermarkFile;

  Widget _viewAssetWidget(BuildContext context, AssetEntity entity) {
    return ExtendedImage(
      width: MediaQuery.of(context).size.width,
      image: AssetEntityImageProvider(entity,
          isOriginal: true, thumbnailFormat: ThumbnailFormat.png),
      fit: BoxFit.fill,
      enableLoadState: true,
      enableMemoryCache: true,
      filterQuality: FilterQuality.high,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Image.asset(
              "assets/loading.gif",
              fit: BoxFit.fill,
              width: 30,
            );
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return GestureDetector(
              child: Image.asset(
                "assets/failed.png",
                fit: BoxFit.fill,
                width: 30,
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
        }
      },
    );
  }

  Widget _watermark(File watermarkFile) {
    return ExtendedImage(
      width: MediaQuery.of(context).size.width,
      image: Image.file(watermarkFile).image,
      fit: BoxFit.fill,
      enableLoadState: true,
      enableMemoryCache: true,
      filterQuality: FilterQuality.high,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Image.asset(
              "assets/loading.gif",
              fit: BoxFit.fill,
              width: 30,
            );
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return GestureDetector(
              child: Image.asset(
                "assets/failed.png",
                fit: BoxFit.fill,
                width: 30,
              ),
              onTap: () {
                state.reLoadImage();
              },
            );
        }
      },
    );
  }

  Widget _buildStack(
    AssetEntity assetEntity,
    watermarkFile,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (assetEntity.type == AssetType.image)
          _viewAssetWidget(context, assetEntity),
        if (assetEntity.type == AssetType.video)
          _viewAssetWidget(context, assetEntity),
        _watermark(watermarkFile),
      ],
    );
  }

  @override
  void initState() {
    screenshotController = ScreenshotController();
    watermarkFile = widget.watermark;
    selectedAsset = widget.listAssets[0];
    processMessage = "";

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<AssetEntity> listAssets = widget.listAssets;

    Future exportFiles({
      required List<AssetEntity> listAssets,
    }) async {
      // ProgressDialog pd = ProgressDialog(context: context);
      double processTotal = listAssets.length.toDouble();
      setState(() {
        processCount = 0;
        _process.value = 0;
        isProcessing = true;
        processMessage = "Exporting files...";
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Alpha",
        builder: (_) => WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            contentPadding: EdgeInsets.only(
              left: 10.0,
              top: 10.0,
              right: 10.0,
              bottom: 5.0,
            ),
            elevation: 10.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            content: ValueListenableBuilder(
                valueListenable: _process,
                builder: (BuildContext context, dynamic value, Widget? child) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            value < 99.9
                                ? CircularProgressIndicator()
                                : SizedBox(),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              // child: Text("Exporting...\n Please wait."),
                              child: Text(value < 100.0
                                  ? "Exporting...(${value.toInt()}%)"
                                  : "Exported successfully."),
                            ),
                          ],
                        ),
                        value > 99.9
                            ? SizedBox(
                                height: 20,
                              )
                            : SizedBox(),
                        value > 99.9
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("OK"),
                                  ),
                                ],
                              )
                            : SizedBox(),
                      ],
                    ),
                  );
                }),
          ),
        ),
      );
      for (int i = 0; i < listAssets.length; i++) {
        AssetEntity asset = listAssets[i];
        print(asset.type);
        await screenshotController
            .captureFromWidget(_buildStack(asset, watermarkFile))
            .then((Uint8List image) async {
          final directory = await getApplicationDocumentsDirectory();
          String fileName =
              'fileCapture-${DateTime.now().microsecondsSinceEpoch}-image.png';
          final imagePath = await File('${directory.path}/$fileName').create();
          File watermarkValid = File(imagePath.path);
          await watermarkValid.writeAsBytes(image);

          await GallerySaver.saveImage(watermarkValid.path).then((value) {
            setState(() {
              processCount = ((i + 1) * 100 / listAssets.length);
              print('Done: $processCount%');
              print('Saved: $fileName');
            });
            _process.value = processCount;
            // pd.update(value: i + 1, msg: 'File Downloading');
            // controller.add(processCount);
          });
        });
      }
    }

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
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _buildStack(
              selectedAsset,
              watermarkFile,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text(!isProcessing
                    ? "Export ${listAssets.length} files"
                    : processMessage),
                onPressed: () =>
                    exportFiles(listAssets: listAssets).then((value) {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
