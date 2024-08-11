import 'dart:math';

import 'package:dailyflowy/app/views/utils.dart';
import 'package:dailyflowy/app/views/widgets/mouse_region_builder.dart';
import 'package:dailyflowy/app/views/widgets/selected_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FolderCard extends StatefulWidget {
  final String title;
  final String subTitle;
  final String desc;
  final Color color;
  final int? progressCount;
  final int? progressTotal;
  final int? attachCount;
  final void Function()? onClick;

  const FolderCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.desc,
    this.color = const Color.fromRGBO(108, 93, 211, 1),
    this.progressCount,
    this.progressTotal,
    this.attachCount,
    this.onClick,
  });

  @override
  State<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends State<FolderCard> {
  @override
  Widget build(BuildContext context) {
    return MouseRegionBuilder(builder: (context, entered) {
      return GestureDetector(
        onTap: () {
          widget.onClick?.call();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 0, top: 0),
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(143, 149, 178, 0.15),
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 7,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    color: widget.color),
              ),
              Expanded(
                  child: Container(
                //   width: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: widget.color.withAlpha(25),
                          ),
                          child: Center(
                            child: Text(
                              widget.title
                                  .substring(0, min(widget.title.length, 10)),
                              style: TextStyle(
                                color: widget.color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (entered)
                          GestureDetector(
                            onTap: () {
                              showSelectedDialog(context, '提示', '确定删除么?');
                            },
                            child: const Icon(
                              Icons.more_horiz,
                              size: 16,
                              color: Color(0xFF8F95B2),
                            ),
                          ),
                      ],
                    ).marginOnly(bottom: 8),
                    Text(
                      widget.subTitle,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0,
                        height: 1.43,
                      ),
                    ).marginOnly(bottom: 8),
                    Text(
                      widget.desc,
                      style: TextStyle(
                        fontSize: 12.px,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                        height: 1.33,
                        color: const Color.fromRGBO(143, 149, 178, 1),
                      ),
                      textAlign: TextAlign.left,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ).marginOnly(bottom: 12),
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
                        const SizedBox(
                          width: 12,
                        ),
                        if (widget.attachCount != null)
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 16,
                            color: Color.fromRGBO(143, 149, 178, 1),
                          ),
                        if (widget.attachCount != null)
                          Text(
                            '${widget.attachCount}',
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
                ).marginOnly(left: 6, top: 10, right: 10, bottom: 6),
              ))
            ],
          ),
        ),
      );
    });
  }
}
