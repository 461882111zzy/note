import 'url_route.dart';

void locateFolder({String? workspace, String? folder}) {
  if (folder == null && workspace == null) {
    return;
  }
  uriRoute.shell(Uri(
      path: 'p', queryParameters: {'workspace': workspace, 'folder': folder}));
}
