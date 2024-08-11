import 'dart:math';

import 'package:dailyflowy/app/views/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluent_ui/fluent_ui.dart' as ui;

class TaskCard extends StatefulWidget {
  final String title;
  final String subTitle;
  final String desc;
  final Color color;
  final int? progressCount;
  final int? progressTotal;
  final void Function() onClickDelete;

  const TaskCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.desc,
    this.color = const Color.fromRGBO(108, 93, 211, 1),
    this.progressCount,
    this.progressTotal,
    required this.onClickDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0x3F6674C4),
            offset: Offset(0.px, 4.px),
            blurRadius: 12.px,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16.px),
        width: 280.px,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.color.withAlpha(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: SizedBox(
              height: 126.px,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                        child: Text(
                          widget.title
                              .substring(0, min(widget.title.length, 10)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 18.px,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ui.IconButton(
                        onPressed: widget.onClickDelete,
                        icon: Icon(
                          Icons.remove_circle,
                          size: 16.px,
                          color: const Color(0xFF8F95B2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (widget.subTitle.isNotEmpty)
                    Text(
                      widget.subTitle,
                      maxLines: 1,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                        height: 0.9,
                      ),
                    ).marginOnly(bottom: 8),
                  if (widget.desc.isNotEmpty)
                    Text(
                      widget.desc,
                      style: TextStyle(
                        fontSize: 14.px,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        height: 1.33,
                        color: const Color(0xFF86909C),
                      ),
                      textAlign: TextAlign.left,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ).marginOnly(bottom: 12),
                  const Spacer(),
                  if (widget.progressTotal != null)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.progressCount != null)
                          const Icon(
                            Icons.check_box,
                            size: 16,
                            color: Color.fromRGBO(143, 149, 178, 1),
                          ),
                        if (widget.progressCount != null)
                          Text(
                            '${widget.progressCount}/${widget.progressTotal}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              height: 1.33,
                              color: Color.fromRGBO(143, 149, 178, 1),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
