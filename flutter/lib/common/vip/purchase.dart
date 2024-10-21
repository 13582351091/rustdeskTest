// TODO Implement this library.
import 'package:community_material_icon/community_material_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_hbb/common.dart';
import 'package:path_provider/path_provider.dart' as path_provider;//应用路径

//以上三个都为商品卡片服务 全平台支持

import 'device_info_service.dart'; //跨平台获取device info 生成invite code
import 'app_urls.dart'; //把carddetail类也放入


import 'package:device_info_plus/device_info_plus.dart';

import 'package:hive/hive.dart'; //修改数据库vip Status
import 'dart:convert'; //json修改default config中的filtering
import 'package:url_launcher/url_launcher.dart'; //外部浏览器打开afdian

import 'package:flutter_riverpod/flutter_riverpod.dart';//WidgetRef ref使用-备用
import '../../common.dart';
//商品卡片服务-因为ref调用太多不好继承,所以还是单独http.init下吧
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();

}


class _ProductCardState extends ConsumerState<ProductCard> with WidgetsBindingObserver {
  //WidgetsBindingObserver用来观察url_launcher结束,并且didChangeAppLifecycleState也才可以继承
  int _current = 0;
  dynamic _selectedIndex = {};

  CarouselController _carouselController = new CarouselController();
  TextEditingController _redeemCodeController =
  TextEditingController(); //兑换码输入框绑定

  List<CardDetail> _products = AppUrls.Plans;

  //需要用到getLocalEndTimeAndChangeVipStatusWithToast来对过期处理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("url_launcher has ended");
      // 生命周期改变的时候检测订单
      getLocalEndTimeAndChangeVipStatusWithToast();

    }
  }



  @override
  void initState() {
    super.initState();
    // 在这里进行初始化加载操作，例如加载数据等
    productInitAndGeneratePurchaseUrl();
    WidgetsBinding.instance!
        .addObserver(this); //增加观察点,用来判断url_launcher结束,然后进行订单查询
  }

  //这个函数的意义在于initState本身不能标记async,但是 productInit()需要await，所以只能单独写一个函数
  void productInitAndGeneratePurchaseUrl() async {
    await productInit(); // 等待加载商品卡片数据 //商品加载完才能给card赋值purchaseUrl
    generatePurchaseUrl(); // 修改卡片中的PurchaseUrl为deviceID以及(productInit中初始化后赋值得到信息)拼接成的url
  }

  //请求booruSama.json然后setState 商品card需要的值，这个放在init.state下面运行//这里即使开始homepage初始化了这里也要init
  //因为用户可能第一次初始化后退出，然后系统hive有，所以不会再init一遍，这时如果买就会有问题
  Future<void> productInit() async {

    Map<String, dynamic> response = appConfig;

    if (response != null) {

      final deviceId = await DeviceInfoService(plugin: DeviceInfoPlugin())
          .getDeviceId(); //获取设备id,set给appurls.deviceId保存,后面拼接purchaseUrl用

      await getPlan(response).then((plans) {
        setState(() {
          AppUrls.planId = response['planId'];
          AppUrls.skuId = response['skuId'];
          AppUrls.Plans = plans;
          _products = plans; //这个是构建用的,主要更新这个,appurls.plan是记录用
          AppUrls.redeem_strict_mode = response['redeem_strict_mode'];
          AppUrls.deviceId = deviceId ?? ""; //保存设备Id
          AppUrls.enableCustomBuy = response['enableCustomBuy'];//是否允许custom buy link
          AppUrls.customBuyLink = response['customBuyLink'];//自定义购买地址
        });
      });
    } else {
      // 处理获取的响应为空的情况
      print("获取card配置失败");
    }
  }

  Future<List<CardDetail>> getPlan(Map<String, dynamic> response) async {
    List<CardDetail> plans = [];
    if (response != null) {
      try {
        List<dynamic> jsonPlans = response['plans'];
        for (var jsonPlan in jsonPlans) {
          int price = jsonPlan['price'];
          String description = jsonPlan['description'];
          String title = jsonPlan['title'];
          CardDetail cardDetail = CardDetail(price, description, title);
          plans.add(cardDetail);
        }
      } catch (e) {
        print('Error while parsing plans: $e');
      }
    } else {
      print('Response is null');
    }
    return plans;
  }

  void generatePurchaseUrl() {
    for (CardDetail card in AppUrls.Plans) {
      if (AppUrls.enableCustomBuy){
        //如果允许自定义购买地址,那么从AppUrls.customBuyLink就是购买链接,否则使用planid和skuid拼接的作为购买地址
        String url = AppUrls.customBuyLink;//自定义购买地址,赋值给card(默认是全部的card)
        card.purchaseUrl = url;
      }
      else{
        String url = '${AppUrls.afdianBaseUrl}'
            '&plan_id=${AppUrls.planId}'
            '&sku=[{"sku_id":"${AppUrls.skuId}","count":${card.price}}]'
            '&custom_order_id=${AppUrls.deviceId}';
        card.purchaseUrl = url;
      };
    }
    setState(() {
      _products = AppUrls.Plans;
    });
  }

  //弹出使用兑换码的弹窗
  void showRedeemCodeDialog(TextEditingController controller) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController dialogTextController =
              controller; // 弹窗中的TextField

          return AlertDialog(
            title: Text('输入兑换码'),
            content: TextField(
              controller: dialogTextController,
              decoration: InputDecoration(
                hintText: '请输入兑换码',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭弹窗
                },
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () async {
                  String inputText =
                      dialogTextController.text; // 获取弹窗中TextField的文本内容
                  print('您输入的兑换码是: $inputText');
                  bool result =
                  await checkRedeemCode(inputText); //这个里面已经有严格模式的判断了
                  if (result) {
                    //默认兑换码+1个月的时间  保存在hive中 subscriptionBox中
                    if (await isRedeemCodeValid(inputText)) {
                      //如果兑换码可用 +1月(时间可变)然后加入usedRedeemCode 否则 toast不可用
                      addTime(AppUrls.secondForRedeemCode);
                      addInvalidRedeemCode(inputText);
                      showToast(translate('兑换成功\n'));

                      //兑换码有效 改变vipStatus为True
                      changeVip(true);
                    } else {
                      //已经使用过的兑换码
                      showToast(translate('此兑换码已经使用过\n'));


                    }
                    //默认兑换码+1个月的时间  保存在hive中 subscriptionBox中
                  }
                  print("判断兑换码结果是${result}");

                  Navigator.of(context).pop(); // 关闭弹窗
                },
                child: Text('确认'),
              ),
            ],
          );
        });
  }



  void saveEndTimeToLocal(int endTime) async {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);//Directory: 'C:\Users\17331\Documents'
    //sp在windows有点问题,用hive统一吧
    Box<int> subscriptionBox; //这个是import 'package:hive/hive.dart';模块的
    //初始化booruConfigBox
    subscriptionBox = await Hive.openBox<int>('subscriptionBox');
    subscriptionBox.put(AppUrls.hasEndTime, 1); //1代表true
    subscriptionBox.put(AppUrls.endTimeKey, endTime); //这里AppUrls.endTime被改变了,所以不能作为键,需要用单独的key
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showRedeemCodeDialog(_redeemCodeController);
        },
        child: Tooltip(
          message: '使用兑换码', // 要显示的文字内容
          child: Icon(Icons.arrow_forward_ios),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // backgroundColor: Colors.white,
        title: Text(
          '@会员购买',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: 450.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.70,
                enlargeCenterPage: true,
                pageSnapping: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            items: _products.map((movie) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      print("当前商品的url是");
                      print(movie.purchaseUrl ?? "");
                      launchUrl(Uri.parse(movie.purchaseUrl)); //打开afdian进行付费

                      setState(() {
                        if (_selectedIndex == movie) {
                          _selectedIndex = {};
                        } else {
                          _selectedIndex = movie;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: _selectedIndex == movie
                              ? Border.all(
                              color: Colors.blue.shade500, width: 3)
                              : null,
                          boxShadow: _selectedIndex == movie
                              ? [
                            BoxShadow(
                                color: Colors.blue.shade100,
                                blurRadius: 30,
                                offset: Offset(0, 10))
                          ]
                              : [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 5))
                          ]),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 3,
                              margin: EdgeInsets.only(top: 10),
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                  CommunityMaterialIcons.wallet_giftcard,
                                  color: Colors.grey,
                                  size: 35), // 让movie.icon占据剩余空间
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              movie.title ?? "购买会员",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              movie.description ?? "",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                showRedeemCodeDialog(_redeemCodeController);
                              },
                              child: Text('使用兑换码'),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList()),
      ),
    );
  }



  Future<bool> checkRedeemCode(String code) {

    //如果非严格模式,但是上一次已经使用了
    if (code == AppUrls.lastRedeemCode) {
      return Future.value(false);
    }
    if ((code.length >= 13 && code.length <= 16) || code.length > 20) {
      //13-16位或者大于30位有效
      return Future.value(true);
    }
    return Future.value(false); //默认返回false,比如长度判断失败
  }
} //class product


//查看本地保存vip状态,如果第一次打开没有本地保存那么创建并保存为false
Future<bool> checkVip() async {
  //存储box路径在app路径
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);//Directory: 'C:\Users\17331\Documents'

  Box<bool> vipBox;

  if (await Hive.boxExists('vip')) {
    vipBox = await Hive.openBox<bool>('vip');
  } else {
    vipBox = await Hive.openBox<bool>('vip');
    await vipBox.put('isVip', false); // 默认保存为false
  }
  // 获取或保存VIP状态
  bool isVip = vipBox.get('isVip', defaultValue: false)!;
  return isVip;
}


//兑换码成功后修改safe mode 0->none  1->..  2->aggressive filter //注意，这个只对default生成的booru生效，自己加的不行
void changeVip(bool vipStatus) async {
    //存储box路径在app路径
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);//Directory: 'C:\Users\17331\Documents'
    Box<bool> vipBox;
    vipBox = await Hive.openBox<bool>('vip');
    // 已经存在那么更新为新的 不存在那么创建并

    // 更新值
    vipBox.put('isVip',vipStatus);
    print("成功更新"); //实验成功-测试的时候会显示进程占用，应该只有程序自己改才行
  }


void getLocalEndTimeAndChangeVipStatusWithToast() async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);//Directory: 'C:\Users\17331\Documents'
  //sp在windows有点问题,用hive统一吧
  Box<int> subscriptionBox; //这个是import 'package:hive/hive.dart';模块的
  //初始化booruConfigBox
  subscriptionBox = await Hive.openBox<int>('subscriptionBox');
  int? hasTime = subscriptionBox.get(AppUrls.hasEndTime);
  int? endTime = subscriptionBox.get(AppUrls.endTimeKey);
  DateTime currentTime = DateTime.now(); //当前时间
  print(
      '本地endtime为 ${endTime != null ? DateTime.fromMillisecondsSinceEpoch(endTime! * 1000).toString() : 'null'}');

  if (hasTime != null &&
      hasTime != 0 &&
      endTime != null &&
      endTime > currentTime.millisecondsSinceEpoch / 1000) {
    print(
        '检测到您的上一次订单截止时间为 ${DateTime.fromMillisecondsSinceEpoch(endTime! * 1000).toString()}');

    changeVip(true);
  } else {
    changeVip(false);
    print("未检测出本地保存订单信息或者会员过期");
  }
}

//默认兑换码+1个月的时间  保存在hive中 subscriptionBox中
void addTime(int secondsToAdd) async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);//Directory: 'C:\Users\17331\Documents'
  Box<int> subscriptionBox;
  DateTime now = DateTime.now();

  subscriptionBox = await Hive.openBox<int>('subscriptionBox');

  int? currentEndTime = subscriptionBox.get(AppUrls.endTimeKey, defaultValue: now.millisecondsSinceEpoch ~/ 1000);

  if (currentEndTime != null) {
    // 如果本地有截止时间:
    int currentEnd = currentEndTime!;

    DateTime currentEndDateTime = DateTime.fromMillisecondsSinceEpoch(currentEnd * 1000);
    DateTime newEndTime;

    if (currentEndDateTime.isAfter(DateTime.now())) {
      // hive记录截止时间晚于当前时间-> (未到期就续费)->按照截止时间增加1月
      newEndTime = currentEndDateTime.add(Duration(seconds: secondsToAdd)); // 增加secondstoadd时间,默认是30天（1个月）
    } else {
      // hive记录截止时间早于当前时间-> (到期后过了一阵子续费) ->按照当前时间加1月
      newEndTime = DateTime.now().add(Duration(seconds: secondsToAdd)); // 增加secondstoadd时间,默认是30天（1个月）
    }

    int newEndTimeInt = newEndTime.millisecondsSinceEpoch ~/ 1000;

    subscriptionBox.put(AppUrls.hasEndTime, 1);
    subscriptionBox.put(AppUrls.endTimeKey, newEndTimeInt);


    showToast(translate("截止时间 ${newEndTime.toString()}"));

  }

  else{
    //本地没有截止时间那么用当前时间算
    DateTime endTime = now.add(Duration(seconds: secondsToAdd));
    int endTimeInt = endTime.millisecondsSinceEpoch ~/ 1000; // 转换为秒数;
    subscriptionBox = await Hive.openBox<int>('subscriptionBox');
    subscriptionBox.put(AppUrls.hasEndTime, 1); //1代表true
    subscriptionBox.put(AppUrls.endTimeKey, endTimeInt); //endtime也是int

    showToast(translate("截止时间${DateTime.fromMillisecondsSinceEpoch(endTimeInt! * 1000).toString()}"));


  }
}

//本地记录废掉的兑换码
void addInvalidRedeemCode(String code) async {
  Box<String> usedRedeemCodeBox;
  usedRedeemCodeBox = await Hive.openBox<String>('usedRedeemCode');
  usedRedeemCodeBox.add(code);
}

//根据本地记录判断兑换码时候可用
Future<bool> isRedeemCodeValid(String code) async {
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);//Directory: 'C:\Users\17331\Documents'
  Box<String> usedRedeemCodeBox;
  usedRedeemCodeBox = await Hive.openBox<String>('usedRedeemCode');
  Iterable<dynamic> keys = usedRedeemCodeBox.keys;
  bool containsValue = keys.any((key) => usedRedeemCodeBox.get(key) == code);//轮询key来看有没有value中有code
  if (containsValue) {
    return Future.value(false); // 如果code存在于usedRedeemCodeBox中，说明使用过,返回false,表示不可用
  } else {
    return Future.value(true); // 如果code不存在于usedRedeemCodeBox中，返回false
  }
}
