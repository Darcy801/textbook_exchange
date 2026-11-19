import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../state/settings_model.dart';

class L10n {
  const L10n(this.english);

  final bool english;

  static L10n of(BuildContext context) =>
      L10n(context.watch<SettingsModel>().english);

  static L10n read(BuildContext context) =>
      L10n(context.read<SettingsModel>().english);

  String t(String zh, String en) => english ? en : zh;

  String get appTitle => t('旧书新知', 'Textbook Exchange');

  String get heroTitle => t('让教材继续流动', 'Keep textbooks in circulation');

  String get tagline => t(
    '校园二手教材 · 中英双语 · 双币种',
    'Campus used books · Bilingual · Two currencies',
  );

  String get home => t('首页', 'Discover');

  String get publish => t('发布', 'Sell');

  String get mine => t('我的', 'Me');

  String get settings => t('设置', 'Settings');

  String get searchHint => t('搜书名或 ISBN', 'Search title or ISBN');

  String get all => t('全部', 'All');

  String get recommended => t('为你推荐', 'Recommended');

  String get seeAll => t('查看全部', 'See all');

  String listings(int count) => t('$count 件在售', '$count listings');

  String get noResult => t('没有符合条件的书', 'No matching books');

  String get noResultHint =>
      t('换个关键词，或者放宽筛选条件', 'Try another keyword or loosen the filters');

  String get language => t('语言', 'Language');

  String get campus => t('校区', 'Campus');

  String get sort => t('排序', 'Sort');

  String get newest => t('最新发布', 'Newest first');

  String get lowestPrice => t('价格从低到高', 'Lowest price first');

  String get anyLanguage => t('不限语言', 'Any language');

  String get anyCampus => t('不限校区', 'Any campus');

  String get priceRange => t('价格区间', 'Price range');

  String get filters => t('筛选', 'Filters');

  String get isbn => t('ISBN', 'ISBN');

  String get condition => t('成色', 'Condition');

  String get seller => t('卖家', 'Seller');

  String get contact => t('联系方式', 'Contact');

  String get favorite => t('收藏', 'Save');

  String get favorited => t('已收藏', 'Saved');

  String get contactSeller => t('联系卖家', 'Contact seller');

  String get negotiate => t('议价', 'Make an offer');

  String get simulateOffline => t('模拟断网', 'Simulate offline');

  String get offlineHint => t(
    '已开启模拟断网，点「联系卖家」可看到错误提示',
    'Offline mode is on. Tap "Contact seller" to see the error state.',
  );

  String get onlineHint => t(
    '提示：右上角 Wi-Fi 图标可切换模拟断网，用于演示异常处理',
    'Tip: toggle the Wi-Fi icon to simulate offline mode and demo error handling.',
  );

  String get networkError =>
      t('网络连接失败，请检查网络后重试', 'Network failed. Check your connection and retry.');

  String get retry => t('重试', 'Retry');

  String get loading => t('加载中…', 'Loading…');

  String get preview => t('快速预览', 'Quick preview');

  String get openDetail => t('查看详情', 'Open details');

  String get close => t('关闭', 'Close');

  String get bookTitle => t('书名', 'Title');

  String get bookTitleEn => t('英文书名（可选）', 'English title (optional)');

  String get priceCnyLabel => t('价格（元）', 'Price (CNY)');

  String get sellerName => t('卖家称呼', 'Seller name');

  String get submit => t('发布到市场', 'Publish');

  String get reset => t('重置', 'Reset');

  String get required => t('必填', 'Required');

  String get isbnInvalid => t('ISBN 必须是 13 位数字', 'ISBN must be 13 digits');

  String get priceInvalid => t('价格必须大于 0', 'Price must be greater than 0');

  String get publishSuccess =>
      t('发布成功，已出现在「我的发布」', 'Published. It is now under My listings.');

  String get myListings => t('我的发布', 'My listings');

  String get myFavorites => t('我的收藏', 'Saved books');

  String get trades => t('交易记录', 'Trades');

  String get onSale => t('在售', 'On sale');

  String get sold => t('已售出', 'Sold');

  String get emptyListings => t('还没有发布过书', 'No listings yet');

  String get emptyFavorites => t(
    '左滑列表，或在详情页点收藏',
    'Swipe left in the list, or tap Save on a detail page',
  );

  String get interfaceLanguage => t('界面语言', 'Interface language');

  String get currency => t('货币', 'Currency');

  String get clearData => t('清空本地数据', 'Clear local data');

  String get clearDataHint => t(
    '清除收藏和发布记录，恢复默认语言与货币',
    'Clears favorites and listings, and resets language and currency',
  );

  String get clear => t('清空', 'Clear');

  String get cancel => t('取消', 'Cancel');

  String get confirm => t('确定', 'Confirm');

  String get cleared => t('已恢复初始数据', 'Local data cleared');

  String get clearConfirm =>
      t('确定要清空收藏和我发布的书吗？', 'Clear your saved books and listings?');

  String get offerTitle => t('向卖家出价', 'Make an offer');

  String get offerHint => t('输入你的价格', 'Enter your price');

  String get send => t('发送', 'Send');

  String get offerSent =>
      t('出价已发送，等待卖家回复', 'Offer sent. Waiting for the seller.');

  String get about => t('关于', 'About');

  String get aboutBody => t(
    '课程期末项目 · Flutter 实现\n本地数据，无需后端',
    'Final course project · Flutter\nLocal data, no backend',
  );

  String get version => t('版本 1.0.0', 'Version 1.0.0');

  String get profileName => t('校园书友', 'Campus reader');

  String get profileRole =>
      t('让每一本书找到下一位主人', 'Every book deserves a next reader');

  String get statOnSale => t('在售', 'On sale');

  String get statFavorites => t('收藏', 'Saved');

  String get tradesEmpty => t('还没有交易记录', 'No trades yet');

  String get tradeDone => t('已完成', 'Completed');

  String get publishIntro => t(
    'ISBN 需 13 位数字，价格需大于 0，校验通过才能发布',
    'ISBN must be 13 digits and price above 0. Validation must pass before publishing.',
  );

  String get localData => t('本地数据存储', 'Local storage');

  String get localDataBody => t(
    '设置、收藏和我发布的书都保存在本机，使用 shared_preferences 键值存储。数据量小、整体读写、不涉及敏感信息，符合第 10 课的选型三问；重启应用后仍然保留。',
    'Settings, saved books and my listings are stored on this device with shared_preferences: small key-value data, no sensitive fields. Everything survives an app restart.',
  );

  String storageStats(int listings, int saved) => t(
    '已保存 $listings 本发布 · $saved 个收藏',
    '$listings listings · $saved saved books',
  );

  String get favoriteRemoved => t('已取消收藏', 'Removed from saved');

  String get swipeTip =>
      t('左滑收藏 · 长按快速预览', 'Swipe left to save · Long press to preview');

  String get fillExample => t('例如：高等数学（第七版）', 'e.g. Advanced Mathematics');

  String category(BookCategory value) => switch (value) {
    BookCategory.textbook => t('教材', 'Textbook'),
    BookCategory.notes => t('笔记', 'Notes'),
    BookCategory.stationery => t('文具', 'Stationery'),
  };

  String conditionName(BookCondition value) => switch (value) {
    BookCondition.likeNew => t('几乎全新', 'Like new'),
    BookCondition.good => t('成色良好', 'Good'),
    BookCondition.fair => t('有使用痕迹', 'Fair'),
  };

  String bookLanguage(BookLanguage value) => switch (value) {
    BookLanguage.chinese => t('中文', 'Chinese'),
    BookLanguage.english => t('英文', 'English'),
  };

  String campusName(Campus value) => switch (value) {
    Campus.main => t('主校区', 'Main campus'),
    Campus.east => t('东校区', 'East campus'),
    Campus.west => t('西校区', 'West campus'),
  };
}
