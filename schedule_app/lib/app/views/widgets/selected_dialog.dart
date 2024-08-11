import 'package:fluent_ui/fluent_ui.dart';

Future<int?> showSelectedDialog(
    BuildContext context, String title, String content) async {
  return await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _DialogImpl(title: title, content: content);
      });
}

class _DialogImpl extends StatelessWidget {
  final String title;
  final String content;
  const _DialogImpl({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          content,
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(1),
          child: const Text(
            '确定',
          ),
        ),
        Button(
          onPressed: () => Navigator.of(context).pop(0),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
