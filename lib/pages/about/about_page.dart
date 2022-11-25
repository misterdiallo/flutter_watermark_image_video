import 'package:flutter/material.dart';
import 'package:flutter_pick_file/constants/menu_item_method.dart';
import 'package:flutter_pick_file/data/info_data.dart';

import 'menu_page.dart/app_functions_page.dart';
import 'menu_page.dart/author_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with AutomaticKeepAliveClientMixin {
  Widget get tips {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(InfoData.appDescription),
    );
  }

  List<MenuItemMethod> get menuList {
    return <MenuItemMethod>[
      MenuItemMethod(
        icon: '🧳',
        name: AppData.appAboutPageMenu0,
        description: AppData.appAboutPageMenu0Description,
        method: (BuildContext context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const DirectoryFileAssetPicker(),
          ),
        ),
      ),
      MenuItemMethod(
        icon: '👨🏽‍🔧',
        name: AppData.appAboutPageMenu1,
        description: AppData.appAboutPageMenu1Description,
        method: (BuildContext context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const MultiTabAssetPicker()),
        ),
      ),
      MenuItemMethod(
        icon: '🔂',
        name: AppData.appAboutPageMenu2,
        description: AppData.appAboutPageMenu2Description,
        method: (BuildContext context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const MultiTabAssetPicker()),
        ),
      ),
    ];
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        tips,
        Expanded(
          child: _MenuListView(listMenu: menuList),
        ),
      ],
    );
  }
}

class _MenuListView extends StatelessWidget {
  // ignore: unused_element
  const _MenuListView({super.key, required this.listMenu});

  final List<MenuItemMethod> listMenu;

  Widget meuItemBuilder(BuildContext context, int index) {
    final MenuItemMethod model = listMenu[index];
    return InkWell(
      onTap: () => model.method(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
          vertical: 10.0,
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(2.0),
              width: 48,
              height: 48,
              child: Center(
                child: Text(
                  model.icon,
                  style: const TextStyle(fontSize: 28.0),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    model.description,
                    style: Theme.of(context).textTheme.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      itemCount: listMenu.length,
      itemBuilder: meuItemBuilder,
    );
  }
}
