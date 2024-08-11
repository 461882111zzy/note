abstract class IShell {
  bool canShell(Uri uri);
  void shell(Uri uri);
}

class UriRoute {
  static const String home = '/';
  final List<IShell> _shells = [];

  void addShell(IShell shell) {
    _shells.remove(shell);
    _shells.add(shell);
  }

  void shell(Uri uri) {
    for (var element in _shells) {
      if (element.canShell(uri)) {
        element.shell(uri);
      }
    }
  }
}

final uriRoute = UriRoute();
