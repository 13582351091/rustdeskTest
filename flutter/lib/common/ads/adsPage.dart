import 'package:animate_do/animate_do.dart';
import 'helpers/ColorsSys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';//适配windows PageView鼠标滑动
import 'package:cached_network_image/cached_network_image.dart';//缓存播放过的广告图片
import 'package:url_launcher/url_launcher.dart'; //外部浏览器打开广告地址
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vip/app_urls.dart';
import '../../common.dart';

class HomePage extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> adList;

  String? id;//连接id

  final bool? isFileTransfer;
  final bool? isTcpTunneling;
  final bool? isRDP ;
  final bool? forceRelay ;
  final String? password;
  final bool? isSharedPassword;


  HomePage({
    required this.adList,
    this.id,
    this.isFileTransfer,
    this.isTcpTunneling,
    this.isRDP,
    this.forceRelay,
    this.password,
    this.isSharedPassword

  }); //传入adList进行初始化

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    _pageController = PageController(
        initialPage: 0
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return
      Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                // 添加跳转逻辑，比如跳转到下一个页面
                // 可以使用Navigator来实现页面跳转

                print("点击了按钮skip");
                connect_direct(context,widget.id!,isFileTransfer:widget.isFileTransfer!,
                    isTcpTunneling:widget.isTcpTunneling! ,
                    isRDP:widget.isRDP!,
                    forceRelay:widget.forceRelay!,
                    password:widget.password,
                    isSharedPassword:widget.isSharedPassword);


              },
              icon: Icon(Icons.arrow_forward), // 设置跳转按钮的图标
              color: ColorSys.gray, // 按钮颜色
            ),
          ],

        ),
        body:
        Stack
          (
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            PageView(
              scrollBehavior: MyBehavior(),
              onPageChanged: (int page) {
                setState(() {
                  currentIndex = page;
                });
              },
              controller: _pageController,
              children:
              getAdWidgetList(widget.adList), //通过函数获取要显示的ad widget list

            ),
            Container(
              margin: EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildIndicator(),
              ),
            )
          ],
        ),

      );
  }

  Widget makePage({image, title, content, link, reverse = false}) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 50, right: 50, bottom: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !reverse
                ? Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse(link));//打开广告所在的link
                  },
                  child: FadeInUp(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: CachedNetworkImage(

                        imageUrl: image,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            )
                : SizedBox(),
            FadeInUp(
              duration: Duration(milliseconds: 900),
              child: Text(
                title,
                style: TextStyle(
                  color: ColorSys.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            FadeInUp(
              duration: Duration(milliseconds: 1200),
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorSys.gray,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            reverse
                ? Column(
              children: <Widget>[
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CachedNetworkImage(
                    imageUrl: image,
                  ),
                ),
              ],
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }


  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 30 : 6,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          color: ColorSys.secoundry,
          borderRadius: BorderRadius.circular(5)
      ),
    );
  }

  List<Widget> _buildIndicator() {
    //广告进度条个数
    List<Widget> indicators = [];
    int adListLength =widget.adList.length ;
    for (int i = 0; i<adListLength; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }

    return indicators;
  }

  List<Widget> getAdWidgetList(List<Map<String, dynamic>> adList){

    List<Widget> widgetList = adList.map((item) {
      return makePage(
          image: item['adPicUrl'] ?? '',
          title: item['adTitle'] ?? '',
          content: item['adContent']??'',
          link: item['adLink']??''
      );
    }).toList();
    //这里打乱顺序后返回
    widgetList.shuffle();
    return widgetList;
  }


}//class adPage


//适配windows PageView鼠标滑动
class MyBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}



List<Map<String, dynamic>> getAdList(BuildContext context ) {
  Map<String, dynamic> response = appConfig;
  final List<Map<String, dynamic>> adList = (response['ad'] as List<dynamic>).cast<Map<String, dynamic>>();//获取ads内容
  return adList;
}


void showAdsPage(BuildContext context,String?id,bool? isFileTransfer ,
  bool? isTcpTunneling ,
  bool? isRDP ,
  bool? forceRelay ,
  String? password,
  bool? isSharedPassword) async{

  List<Map<String, dynamic>> adList = getAdList(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return HomePage(
        adList: adList,//初始化adList
        id:id,
        isFileTransfer: isFileTransfer, // 传递isFileTransfer参数值
        isTcpTunneling: isTcpTunneling, // 传递isTcpTunneling参数值
        isRDP: isRDP, // 传递isRDP参数值
        forceRelay: forceRelay, // 传递forceRelay参数值
        password: password, // 传递password参数值
        isSharedPassword: isSharedPassword, // 传递isSharedPassword参数值
      );
    },
  );

}