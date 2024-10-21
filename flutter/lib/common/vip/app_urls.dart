// TODO Implement this library.
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppUrls {
  //config��ȡurl,Ĭ����uu.pixiv.digital
  static String configUrl ="https://app.pixivs.cn";
  static String configPath = "/iizhi.json";
  static String afdianBaseUrl = "https://afdian.net/order/create?product_type=1";
  //����Ϊ��һ���������ͬʱ�õ�host�� product card������,��������ʣ�����������Ϊ����
  static String planId = "";
  static String skuId = "";
  static List<CardDetail> Plans = [];
  static bool redeem_strict_mode = false;//Ĭ�ϲ��ϸ�һ���ģʽ
  static String deviceId = "";
  static String lastRedeemCode = "";//��һ�ε�����ɹ��Ķһ���,�Է��������ضһ�ҳ������,��ʱ�͵�����ʱ��
  static String order_service_url = "";//order_service_url�����ַ��afdian��ȡ����ʱ��Ϊhook��ַд��vercel���ݿ�,Ȼ�����ύdeviceId�����ݿ��ȡ��ֹʱ��
  static String checkOrder = "http://hook.pixiv.digital/checkOrder";

  static int booruConfigs = 132304;
  static int endTime = 0; //�����subscriptionBox hive box���汣��   hasEndTime endTime �������Ƿ��н�ֹʱ��,��ֹʱ������(int)
  static int endTimeKey = 0;//�����Ϊkey��ѯendtime,������һ������Ϊ��Ҫ��ʱ��endTime�����ֹʱ����е���
  static int hasEndTime = 1;// hasEndTime endTime �������Ƿ��н�ֹʱ��,��ֹʱ������(int)
  static int secondForRedeemCode =2592000 ;//->��Ӧ�һ���ӵ�������
  static bool enableCustomBuy = false;//�Ƿ�����custom buy link
  static String customBuyLink =  "";//�Զ��幺���ַ

  static String annasFastDownloadUrl =  'https://annas.yingwu.lol/dyn/api/fast_download.json';//annas archive get fast link base url
  static String annas_key = '';//annas archive key

}




class CardDetail {
  int price;
  Icon icon = Icon(CommunityMaterialIcons.wallet_giftcard,
      color: Colors.grey, size: 35); //��ƷͼƬû��Ҫ��ֵ,��Ĭ�ϵ���Ʒ��ͼƬ����
  String description; //��Ʒ����
  String title; //
  String purchaseUrl='';//����Ҫ��ֵ,ͨ��skuid planid purchaseLinkBase ��price�Լ�deviceId����//���ﶨ�崿��Ϊ�˷��������Ƭ�Ե���

  CardDetail(this.price, this.description, this.title);
}

Map<String,dynamic> appConfig = {
  "planId": "ef3c43c6daa411ee965e5254001e7c00",
  "skuId": "ef440afcdaa411ee9e165254001e7c00",
  "enableCustomBuy":true,
  "customBuyLink":"https://afdian.com/item/d7e483e8314611efbe0952540025c377",
  "updateLink":"http://pixiv.wiki",
  "lastVersion":"1.0.0",
  "ad":[
    {
      "adPicUrl":"https://img.alicdn.com/imgextra/i1/2215461207111/O1CN01LTiPrs22OtMshGaJ1_!!2215461207111.png",
      "adLink":"https://sdn.bitvpn.us",
      "adTitle":"BitVPN",
      "adContent":"A truly decentralized VPN service"
    }
  ],
  "guestAdDisplayCount" : 15,
  "vipAdDisplayCount": 30,
  "enableAds": true,
  "plans": [
    {
      "price": 6,
      "description": "点击跳转爱发电,下单后点击爱发电自动消息回复获取兑换码,兑换码框输入后重启应用解锁vip权益。",
      "title": "会员解锁套餐",
      "duration_seconds": 2592000
    }
  ],
  "redeem_strict_mode": false,
  "order_service_url":"https://hook.pixiv.digital/uu",
};