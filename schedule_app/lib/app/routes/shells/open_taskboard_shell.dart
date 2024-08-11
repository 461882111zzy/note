import 'package:dailyflowy/app/modules/0_home/controllers/home_controller.dart';
import 'package:dailyflowy/app/routes/url_route.dart';
import 'package:get/get.dart';

class OpenTaskboardShell extends IShell {
  @override
  bool canShell(Uri uri) {
    return (uri.path == 'p' && uri.queryParameters.containsKey('workspace'));
  }

  @override
  void shell(Uri uri) {
    final workspace = uri.queryParameters['workspace'];
    final folder = uri.queryParameters['folder'];

    final home = Get.find<HomeController>();
    home.tabController.index = 1;
    Future.delayed(const Duration(milliseconds: 200), () {
      home.locateController.locate(workspace, folder);
    });
  }
}
