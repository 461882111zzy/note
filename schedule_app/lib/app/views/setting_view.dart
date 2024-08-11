
import 'package:dailyflowy/app/controllers/assets_controller.dart';
import 'package:dailyflowy/app/controllers/db.dart';
import 'package:dailyflowy/app/data/asset.dart';
import 'package:dailyflowy/app/modules/0_home/controllers/home_controller.dart';
import 'package:dailyflowy/app/views/js_plugin_editor.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<int?> showSettingDialog(BuildContext context) async {
  return await ui.showDialog<int>(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: true,
      builder: (context) {
        return const _DialogImpl();
      });
}

class _DialogImpl extends StatefulWidget {
  const _DialogImpl({Key? key}) : super(key: key);

  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<_DialogImpl> with IsarMixin {
  int _selected = 0;
  String _filePath = '';

  @override
  void initState() {
    super.initState();
    Db.get().then((value) {
      _filePath = value.directory!;
      setState(() {});
    });
  }

  Future<(String, String, String, String)> _loadAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    return (appName, packageName, version, buildNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ui.FlyoutContent(
        child: Container(
          width: 700,
          height: 500,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '设置',
                    style: TextStyle(fontSize: 25),
                  )),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                        width: 150,
                        child: Column(
                          children: [
                            ListTile(
                              minLeadingWidth: 10,
                              selected: _selected == 0,
                              leading: const Icon(Icons.file_present, size: 20),
                              title: const Text('文件'),
                              selectedColor:
                                  ui.FluentTheme.of(context).selectionColor,
                              hoverColor:
                                  ui.FluentTheme.of(context).activeColor,
                              onTap: () {
                                setState(() {
                                  _selected = 0;
                                });
                              },
                            ),
                            ListTile(
                              minLeadingWidth: 10,
                              selected: _selected == 1,
                              leading: const Icon(
                                Icons.extension,
                                size: 20,
                              ),
                              title: const Text('插件'),
                              selectedColor:
                                  ui.FluentTheme.of(context).selectionColor,
                              hoverColor:
                                  ui.FluentTheme.of(context).activeColor,
                              onTap: () {
                                setState(() {
                                  _selected = 1;
                                });
                              },
                            ),
                            ListTile(
                              minLeadingWidth: 10,
                              selected: _selected == 2,
                              leading: const Icon(
                                Icons.color_lens,
                                size: 20,
                              ),
                              title: const Text('主题'),
                              selectedColor:
                                  ui.FluentTheme.of(context).selectionColor,
                              hoverColor:
                                  ui.FluentTheme.of(context).activeColor,
                              onTap: () {
                                setState(() {
                                  _selected = 2;
                                });
                              },
                            ),
                            ListTile(
                              minLeadingWidth: 10,
                              selected: _selected == 3,
                              leading: const Icon(
                                Icons.info,
                                size: 20,
                              ),
                              title: const Text('关于'),
                              selectedColor:
                                  ui.FluentTheme.of(context).selectionColor,
                              hoverColor:
                                  ui.FluentTheme.of(context).activeColor,
                              onTap: () {
                                setState(() {
                                  _selected = 3;
                                });
                              },
                            )
                          ],
                        )),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 0.5,
                      color: Colors.grey,
                    ),
                    Expanded(child: _buildContent(context, _selected)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    final widgetBuilders = [
      _buildFileDir,
      _buildPluginList,
      _buildThemeWidget,
      _buildAboutWidget,
    ];

    return widgetBuilders[index](context);
  }

  Widget _buildFileDir(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            textWidthBasis: TextWidthBasis.longestLine,
            text: TextSpan(
                text: _filePath,
                style: TextStyle(
                    height: 1.0,
                    color:
                        ui.FluentTheme.of(context).typography.subtitle!.color),
                children: [
                  WidgetSpan(
                      child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 24,
                          child: MouseRegionBuilder(builder: (context, _) {
                            return const Icon(
                              Icons.open_in_new,
                              size: 16,
                            );
                          }),
                          onPressed: () {
                            launchUrl(Uri.file(_filePath));
                          }))
                ]),
          ),
          ui.FilledButton(
            child: Text('备份数据'),
            onPressed: () {
              backup();
            },
          ).marginOnly(top: 10),
        ],
      ),
    );
  }

  void backup() async {
    initIsar();
    await asureInstance();
    copyFile(isar!.path!, '${isar!.path}_backup');
  }

  Widget _buildPluginList(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: MouseRegionBuilder(builder: (context, entered) {
        return Wrap(
          children: [
            GestureDetector(
              onTap: () async {
                final assets = Get.find<AssetsController>();
                var res = await assets.findByTitleAndType(
                    assetTypePlugin, 'schedule');

                // ignore: use_build_context_synchronously
                showPluginDialog(context, res?.content, (value) async {
                  res = res ?? AssetData()
                    ..title = 'schedule'
                    ..type = assetTypePlugin;
                  res?.content = value;
                  res?.id = await assets.updateAssetData(res!);
                });
              },
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Card(
                      color: !entered
                          ? ui.FluentTheme.of(context).cardColor
                          : ui.FluentTheme.of(context).accentColor,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule),
                            Text('外部日程'),
                          ],
                        ),
                      ))),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildThemeWidget(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return ui.ListView(
      children: [
        Text(
          '外观',
          style: ui.FluentTheme.of(context).typography.subtitle,
        ),
        ui.RadioButton(
            checked: homeController.mode == ui.ThemeMode.system,
            content: const Text(
              '自动',
              style: TextStyle(fontSize: 13),
            ).marginSymmetric(vertical: 5),
            onChanged: (checked) {
              if (checked) {
                homeController.mode = ui.ThemeMode.system;
              }
            }),
        ui.RadioButton(
            checked: homeController.mode == ui.ThemeMode.light,
            content: const Text(
              '浅色',
              style: TextStyle(fontSize: 13),
            ).marginSymmetric(vertical: 5),
            onChanged: (checked) {
              if (checked) {
                homeController.mode = ui.ThemeMode.light;
              }
            }),
        ui.RadioButton(
            checked: homeController.mode == ui.ThemeMode.dark,
            content: const Text(
              '深色',
              style: TextStyle(fontSize: 13),
            ).marginSymmetric(vertical: 5),
            onChanged: (checked) {
              if (checked) {
                homeController.mode = ui.ThemeMode.dark;
              }
            })
      ],
    );
  }

  //关于和隐私说明,展示APP的版本号和隐私说明
  Widget _buildAboutWidget(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: FutureBuilder<(String, String, String, String)>(
        future: _loadAppInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('应用名称: ${snapshot.data!.$1}'),
                Text('版本号: ${snapshot.data!.$3}+${snapshot.data!.$4}'),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  '版本说明:',
                ),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
