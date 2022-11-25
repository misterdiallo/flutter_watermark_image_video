import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pick_file/constants/watermark_model.dart';
import 'package:flutter_pick_file/data/list_watermark.dart';
import 'package:flutter_pick_file/pages/wtmk_builder/watermarking.dart';
import 'package:flutter_pick_file/pages/wtmk_builder/widgets/pick_file_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class WatermarkBuilder extends StatefulWidget {
  final List<AssetEntity> assets;
  WatermarkBuilder({super.key, required this.assets});

  @override
  State<WatermarkBuilder> createState() => _WatermarkBuilderState();
}

class _WatermarkBuilderState extends State<WatermarkBuilder> {
  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? imageWatermarkBytes;
  late TextEditingController _textEditingController;
  late bool isWatermarkSelected;
  late int currentSelected;
  dynamic selectedWatermark = FadeInImage(
    placeholder: Image.memory(kTransparentImage).image,
    image: Image.memory(kTransparentImage).image,
    fit: BoxFit.fill,
  );

  builViewWatermark({type, content}) {
    if (type == "text") {
      setState(() {
        isWatermarkSelected = true;
        selectedWatermark = WidgetsToImage(
          controller: controller,
          child: Stack(
            children: <Widget>[
              FadeInImage(
                placeholder: Image.memory(kTransparentImage).image,
                image: Image.memory(kTransparentImage).image,
                fit: BoxFit.fill,
              ),
              Center(
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      });
    }
    if (type == "image") {
      setState(() {
        isWatermarkSelected = true;
        selectedWatermark = WidgetsToImage(
          controller: controller,
          child: FadeInImage(
            placeholder: Image.memory(kTransparentImage).image,
            image: Image.file(File(content)).image,
            fit: BoxFit.contain,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    isWatermarkSelected = false;
    currentSelected = -999;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    isWatermarkSelected = false;
    currentSelected = -999;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.assets);
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Watermark"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (isWatermarkSelected)
                Container(
                  height: 250,
                  child: selectedWatermark,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      var pick = await PickFileFunction.onImageButtonPressed(
                          ImageSource.gallery);
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: PickFileFunction.previewImage(
                                  pick.runtimeType == String ? pick : null,
                                  pick.runtimeType != String ? pick : null,
                                  pick.runtimeType == String ? pick : null),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    pick.runtimeType == XFile
                                        ? ElevatedButton(
                                            child: Text("Save"),
                                            onPressed: () {
                                              XFile image = pick;
                                              if (image.path.isNotEmpty) {
                                                setState(() {
                                                  isWatermarkSelected = false;
                                                  currentSelected = -999;
                                                  listWatermark.insert(
                                                    0,
                                                    WatermarkModel(
                                                      id: 3,
                                                      name: "add_image",
                                                      content: image.path,
                                                      type: "image",
                                                      created_date:
                                                          DateTime.now(),
                                                      updated_date:
                                                          DateTime.now(),
                                                      widget: Image.file(
                                                          File(image.path)),
                                                      onpressed: image.path,
                                                    ),
                                                  );
                                                });
                                              }
                                              Navigator.pop(context);
                                            },
                                          )
                                        : Container(),
                                  ],
                                ),
                              ],
                            );
                          });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_search_rounded,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Add Image"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: TextField(
                                minLines: 1,
                                maxLines: 3,
                                onChanged: (value) {},
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                    hintText: "Entre Your text here"),
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _textEditingController.text = "";
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Save'),
                                      onPressed: () {
                                        if (_textEditingController
                                            .text.isNotEmpty) {
                                          setState(() {
                                            isWatermarkSelected = false;
                                            currentSelected = -999;
                                            listWatermark.insert(
                                              0,
                                              WatermarkModel(
                                                id: 2,
                                                name:
                                                    _textEditingController.text,
                                                content:
                                                    _textEditingController.text,
                                                type: "text",
                                                created_date: DateTime.now(),
                                                updated_date: DateTime.now(),
                                                widget: Text(
                                                    _textEditingController
                                                        .text),
                                                onpressed: Text(
                                                    _textEditingController
                                                        .text),
                                              ),
                                            );

                                            _textEditingController.text = "";
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Add Text"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              if (listWatermark.isNotEmpty)
                Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Text("My Watermarks"),
                  Expanded(child: Divider()),
                ]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                      // reverse: true,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4),
                      itemCount: listWatermark.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return InkWell(
                          onTap: () {
                            builViewWatermark(
                              type: listWatermark[index].type,
                              content: listWatermark[index].content,
                            );
                            setState(() {
                              currentSelected = index;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: listWatermark[index].type == "text"
                                      ? Container(
                                          child: Text(
                                            listWatermark[index].content,
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : FadeInImage(
                                          placeholder:
                                              Image.memory(kTransparentImage)
                                                  .image,
                                          image: Image.file(File(
                                                  listWatermark[index].content))
                                              .image,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                if (currentSelected == index)
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.blue[900]!.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.done,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isWatermarkSelected
          ? FloatingActionButton(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              onPressed: () async {
                final bytes = await controller.capture();
                setState(() {
                  imageWatermarkBytes = bytes;
                });

                try {
                  final Uint8List pngBytes = imageWatermarkBytes!;
                  //create file
                  final String dir =
                      (await getApplicationDocumentsDirectory()).path;
                  final String fullPath =
                      '$dir/${DateTime.now().millisecond}.png';
                  File watermarkValid = File(fullPath);
                  await watermarkValid.writeAsBytes(pngBytes);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Image.file(watermarkValid),
                        );
                      });
                  Navigator.of(context).push<void>(MaterialPageRoute<void>(
                      builder: (_) => Watermaking(
                            listAssets: widget.assets,
                            watermark: watermarkValid,
                          )));
                  // await GallerySaver.saveImage(watermarkValid.path)
                  //     .then((value) {
                  //   setState(() {
                  //     print('screenshot saved!');
                  //   });
                  //   // showDialog(
                  //   //     context: context,
                  //   //     builder: (context) {
                  //   //       return AlertDialog(
                  //   //         content: Image.file(watermarkValid),
                  //   //       );
                  //   //     });
                  // });
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(e.toString()),
                        );
                      });
                }

                // Image(
                //   image: AssetEntityImageProvider(widget.assets[0],
                //       isOriginal: true),
                //   fit: BoxFit.cover,
                // ),
                //   Stack(
                //     children: <Widget>[
                //       Positioned.fill(child: _imageAssetWidget(context)),
                //       ColoredBox(
                //         color: Theme.of(context).dividerColor.withOpacity(0.3),
                //         child: Center(
                //           child: Icon(
                //             Icons.video_library,
                //             color: Colors.white,
                //             size: isDisplayingDetail ? 24.0 : 16.0,
                //           ),
                //         ),
                //       ),
                //     ],
                //   );
                // },
              },
              child: Icon(Icons.done_all),
            )
          : null,
    );
  }
}
