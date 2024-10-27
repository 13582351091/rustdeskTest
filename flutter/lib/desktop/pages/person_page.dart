import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../common.dart';
import '../../common/widgets/animated_rotation_widget.dart';
import '../../models/platform_model.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({Key? key}) : super(key: key);

  @override
  State<PersonPage> createState() => _PersonPageState();
}

const borderColor = Color(0xFF2F65BA);

class _PersonPageState extends State<PersonPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  RxBool refreshHover = false.obs;



  buildPersonPage(BuildContext context) {
    final textColor = Theme.of(context).textTheme.titleLarge?.color;
    final model = gFFI.serverModel;
    final TextEditingController _controller = TextEditingController(text: model.serverPasswd.text);
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //svg图片自适应占位大小
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                child: SvgPicture.asset(
                  'assets/linkDeskPersonPage.svg', // SVG 图片路径
                  fit: BoxFit.cover, // 设置图片适应方式
                ),
              ),
            ),
          ),
          //左对齐文字
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0), // 设置左边距
              child: Text(
                '设备控制ID & 设备一次性密码',
                style: TextStyle(
                  color: Color(0xFFFF6F00),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  fontSize: 20.0, // 设置文字大小
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ), //between text and text field
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true, // 设置为只读
                      initialValue: 'id: ${model.serverId.text}',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF6F1F1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: model.serverId.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('复制成功!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child:


        Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        Expanded(
                        child: TextFormField(
                          controller: model.serverPasswd,
                          readOnly: true, // 设置为只读
                          // initialValue: '密码: ${model.serverPasswd.text.obs}',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFF6F1F1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: model.serverPasswd.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('复制成功!')),
                        );
                      },
                    ),
                    AnimatedRotationWidget(
                      onPressed: () => bind.mainUpdateTemporaryPassword(),
                      child: Tooltip(
                        message: translate('Refresh Password'),
                        child: Obx(() => RotatedBox(
                            quarterTurns: 2,
                            child: Icon(
                              Icons.refresh,
                              color: refreshHover.value
                                  ? textColor
                                  : Color(0xFFDDDDDD),
                              size: 22,
                            ))),
                      ),
                      onHover: (value) => refreshHover.value = value,
                    ).marginOnly(right: 8, top: 4),
                  ],
                ),


            ),
          ),//between text field and text field


        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildPersonPage(context);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
