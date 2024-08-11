import 'package:dailyflowy/app/theme.dart';
import 'package:dailyflowy/app/views/utils.dart';
import 'package:dailyflowy/app/views/widgets/mouse_hover_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;

class NotePreview extends StatelessWidget {
  const NotePreview(
      {super.key,
      required this.title,
      this.updateTime,
      this.folderTitle,
      this.sumary});

  final String title;
  final int? updateTime;
  final String? folderTitle;
  final String? sumary;

  @override
  Widget build(BuildContext context) {
    final theme = ui.FluentTheme.of(context);
    final fontSize = 18.px;
    return MouseHoverBuilder(builder: (contex, hover) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: theme.cardColor,
            border:
                Border.all(color: theme.extension<CardBoardColor>()!.color)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (updateTime != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.timer,
                          size: 10,
                          color: theme.iconTheme.color!.withOpacity(0.4))
                      .marginOnly(right: 3),
                  Text(
                    DateFormat('yyyy-MM-dd').format(
                        DateTime.fromMillisecondsSinceEpoch(updateTime!)),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 10, color: Colors.grey),
                  )
                ],
              ).marginOnly(bottom: 4),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4.0,
                right: 10.0,
              ),
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.title!.copyWith(fontSize: fontSize)),
            ),
            ui.Expanded(
              child: Text(
                (sumary != null && sumary!.isNotEmpty) ? sumary! : '没有内容',
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: theme.typography.subtitle!
                    .copyWith(fontSize: 10, color: Colors.grey, height: 1.2),
              ),
            ),
            if (folderTitle != null)
              Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 14,
                    color: theme.typography.body!.color!.withOpacity(0.7),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Text(
                    '$folderTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: theme.typography.subtitle!.copyWith(
                        fontSize: 10,
                        color: theme.typography.body!.color!.withOpacity(0.7),
                        height: 1.2),
                  ),
                ],
              ).marginOnly(bottom: 4, top: 3),
          ],
        ),
      );
    });
  }
}
