import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import '../url_launcher.dart';


class CustomLinkPreviewWidget extends StatelessWidget {
  const CustomLinkPreviewWidget({
    super.key,
    required this.node,
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
  });

  final Node node;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String url;

  @override
  Widget build(BuildContext context) {
    final documentFontSize = context
            .read<EditorState>()
            .editorStyle
            .textStyleConfiguration
            .text
            .fontSize ??
        16.0;
    final (fontSize, width) = PlatformExtension.isDesktopOrWeb
        ? (documentFontSize, 180.0)
        : (documentFontSize - 2, 120.0);
    final Widget child = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(
          6.0,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6.0),
                  bottomLeft: Radius.circular(6.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: width,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 4.0,
                          right: 10.0,
                        ),
                        child: Text(
                          title!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSize - 4,
                          ),
                        ),
                      ),
                    Text(
                      url.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: fontSize - 4,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
      onTap: () => afLaunchUrlString(url),
      child: child,
    );
  }
}
