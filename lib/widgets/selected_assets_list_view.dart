import 'package:flutter/material.dart';
import 'package:flutter_pick_file/pages/wtmk_builder/watermark_builder.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart'
    show AssetEntity, AssetPicker, AssetPickerViewer;

import '../main.dart' show themeColor;
import 'asset_widget_builder.dart';

class SelectedAssetsListView extends StatelessWidget {
  const SelectedAssetsListView({
    super.key,
    required this.assets,
    required this.isDisplayingDetail,
    required this.onResult,
    required this.onRemoveAsset,
  });

  final List<AssetEntity> assets;
  final ValueNotifier<bool> isDisplayingDetail;
  final void Function(List<AssetEntity>? result) onResult;
  final void Function(int index) onRemoveAsset;

  Widget _selectedAssetWidget(BuildContext context, int index) {
    final AssetEntity asset = assets.elementAt(index);
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayingDetail,
      // ! Selected files
      builder: (_, bool value, __) => GestureDetector(
        onTap: () async {
          if (value) {
            final List<AssetEntity>? result =
                await AssetPickerViewer.pushToViewer(
              context,
              currentIndex: index,
              previewAssets: assets,
              themeData: AssetPicker.themeData(themeColor),
            );
            onResult(result);
          }
        },
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: AssetWidgetBuilder(
              entity: asset,
              isDisplayingDetail: value,
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedAssetDeleteButton(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => onRemoveAsset(index),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
        ),
        child: const Icon(Icons.close, size: 18.0),
      ),
    );
  }

  Widget get selectedAssetsListView {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        scrollDirection: Axis.horizontal,
        itemCount: assets.length,
        itemBuilder: (BuildContext c, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _selectedAssetWidget(c, index)),
                  ValueListenableBuilder<bool>(
                    valueListenable: isDisplayingDetail,
                    builder: (_, bool value, __) => AnimatedPositioned(
                      duration: kThemeAnimationDuration,
                      top: value ? 6.0 : -30.0,
                      right: value ? 6.0 : -30.0,
                      child: _selectedAssetDeleteButton(c, index),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDisplayingDetail,
      builder: (_, bool value, __) => AnimatedContainer(
        duration: kThemeChangeDuration,
        curve: Curves.easeInOut,
        height: assets.isNotEmpty
            ? value
                ? 120.0
                : 90.0
            : 40.0,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30.0,
              child: GestureDetector(
                onTap: () {
                  if (assets.isNotEmpty) {
                    isDisplayingDetail.value = !isDisplayingDetail.value;
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (assets.isNotEmpty)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 10.0),
                        child: Icon(
                          value ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 18.0,
                        ),
                      ),
                    const Text('Selected Files'),
                    if (assets.isNotEmpty)
                      InkWell(
                        onTap: () {
                          // ! Push the watermarke page
                          Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      WatermarkBuilder(assets: assets)));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  "Valid",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 14, 235, 40),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Icon(
                                  Icons.done,
                                  size: 18,
                                  color: Color.fromARGB(255, 14, 235, 40),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            selectedAssetsListView,
          ],
        ),
      ),
    );
  }
}
