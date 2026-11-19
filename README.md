# Textbook Exchange 旧书新知

校园二手教材交换应用，Flutter 期末项目。面向校园里的国际学生，界面中英双语、价格支持人民币和美元双币种，数据全部保存在本地，不依赖后端。

## 运行

```bash
flutter pub get
flutter run -d chrome
```

## 页面结构

| 页面 | 路由 | 关键点 |
| --- | --- | --- |
| 首页 Discover | `/`（Tab 1） | 搜索框、分类筛选、两列推荐网格 |
| 搜索结果 | `/list` | 语言/校区/价格筛选、排序、左滑收藏、长按预览并回传结果 |
| 详情 | `/detail` | Hero 封面转场、收藏弹跳动画、议价弹窗、模拟断网与错误重试 |
| 发布 | Tab 2 | Form 校验：书名必填、ISBN 13 位数字、价格大于 0 |
| 我的 | Tab 3 | 我的发布、我的收藏、交易记录 |
| 设置 | `/settings` | 中英文切换、CNY/USD 切换、清空本地数据 |

底部导航使用 `IndexedStack` 保持三个 Tab 的状态。

## 知识点对照

- 第 7 周：`ListView.builder`、两列 `SliverGrid`、命名路由、`ListPageArgs` / `DetailArgs` 强类型传参、长按预览 `showModalBottomSheet` 回传 `PreviewAction`、参数化组件 `BookRow` / `BookGridCard` / `BookCover`
- 第 8 周：左滑 `Dismissible` 手势、`Form` + `TextFormField` 校验、Provider 管理收藏和设置、页面内 `setState` 管理筛选状态
- 第 10 周：`shared_preferences` 本地数据存储——界面语言、货币、收藏、我发布的书写入本机，重启后保留；设置页的「本地数据存储」卡片说明选型理由
- 第 9 周：`AnimatedContainer` 收藏按钮、`AnimatedSize` 筛选面板与错误条、`AnimationController` + `TweenSequence` 弹跳、Hero 共享封面、页面淡入滑动转场、全局异常捕获、`flutter analyze` 清零

## 演示顺序

1. 首页搜索「算法」，点卡片进详情，看 Hero 封面和收藏弹跳
2. 返回首页，点「查看全部」进列表，展开筛选，选英文/东校区，左滑收藏，长按预览
3. 详情页右上角 Wi-Fi 图标切换到模拟断网，点「联系卖家」看错误条，再点重试
4. 发布页故意把 ISBN 填成 12 位，看到校验提示；补齐后发布，自动跳到「我的发布」
5. 设置页切换 English 和 USD，返回看界面与价格变化

## 目录

```
lib/
  main.dart              入口、Provider、路由表、全局异常条
  models/book.dart       Book 模型与四个枚举
  data/books.dart        36 本教材种子数据
  state/                 Catalog / Favorites / Settings 三个 ChangeNotifier
  l10n/l10n.dart         中英文案与枚举翻译
  pages/                 首页、列表、详情、发布、我的、设置、主壳
  widgets/               封面、网格卡片、列表行、信息标签
```

## 构建

```bash
flutter build apk --release
flutter build web --release
```

APK 输出在 `build/app/outputs/flutter-apk/app-release.apk`。

## AI 使用说明

界面代码在 TraeCode 辅助下完成，已逐页运行验证：`flutter analyze` 无问题，`flutter test` 通过，浏览器中逐页点击检查过筛选、收藏、表单校验和错误重试流程。
