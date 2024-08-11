import 'package:flutter/material.dart';

class FolderInfoCard extends StatelessWidget {
  final String title;
  final String prompt;
  final double progress;

  const FolderInfoCard(
      {super.key,
      required this.title,
      required this.prompt,
      required this.progress});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      constraints: const BoxConstraints(
        minWidth: 150,
        maxWidth: 230,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.1,
              color: Color(0xFF171725),
            ),
          ),

          //添加一个container，margin为20px,背景色为FF974A，26px的高度，5px的圆角
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 24,
            padding: const EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: const Color(0x2FFF974A),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timelapse,
                  color: Color(0xAFFF974A),
                  size: 16,
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  prompt,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w100,
                    fontSize: 13,
                    letterSpacing: 0.1,
                    color: Color(0xFFFF974A),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.2,
                letterSpacing: 0.1,
                color: Color(0xFF696974),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          LinearProgressIndicator(
            minHeight: 4,
            value: progress,
            backgroundColor: const Color(0xffE2E2EA),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff3DD598)),
          ),
        ],
      ),
    );
  }
}
