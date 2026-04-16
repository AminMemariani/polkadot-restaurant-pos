import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_utils.dart';

/// Semantic icons that resolve to [CupertinoIcons] on iOS and macOS and to
/// Material [Icons] on every other platform.
///
/// Use these getters in place of `Icons.*` so the app feels native on Apple
/// platforms without forking every call site.
///
/// For icons with no good Cupertino analog (e.g. room service), the Material
/// icon is used on both platforms — `cupertino_icons` ships only a subset of
/// what Material provides.
class AppIcons {
  AppIcons._();

  static IconData _pick(IconData material, IconData cupertino) =>
      PlatformUtils.isApple ? cupertino : material;

  // General actions
  static IconData get add => _pick(Icons.add, CupertinoIcons.add);
  static IconData get addRounded =>
      _pick(Icons.add_rounded, CupertinoIcons.add);
  static IconData get remove => _pick(Icons.remove, CupertinoIcons.minus);
  static IconData get clear => _pick(Icons.clear, CupertinoIcons.clear);
  static IconData get clearAllRounded =>
      _pick(Icons.clear_all_rounded, CupertinoIcons.clear);
  static IconData get closeRounded =>
      _pick(Icons.close_rounded, CupertinoIcons.xmark);
  static IconData get cancelOutlined =>
      _pick(Icons.cancel_outlined, CupertinoIcons.xmark_circle);
  static IconData get check => _pick(Icons.check, CupertinoIcons.checkmark);
  static IconData get done => _pick(Icons.done, CupertinoIcons.checkmark);
  static IconData get checkCircle =>
      _pick(Icons.check_circle, CupertinoIcons.checkmark_circle);
  static IconData get checkCircleRounded =>
      _pick(Icons.check_circle_rounded, CupertinoIcons.checkmark_circle_fill);
  static IconData get editRounded =>
      _pick(Icons.edit_rounded, CupertinoIcons.pencil);
  static IconData get deleteOutline =>
      _pick(Icons.delete_outline, CupertinoIcons.delete);
  static IconData get deleteRounded =>
      _pick(Icons.delete_rounded, CupertinoIcons.delete_solid);
  static IconData get deleteForeverOutlined =>
      _pick(Icons.delete_forever_outlined, CupertinoIcons.delete_solid);
  static IconData get refresh =>
      _pick(Icons.refresh, CupertinoIcons.arrow_clockwise);
  static IconData get refreshRounded =>
      _pick(Icons.refresh_rounded, CupertinoIcons.arrow_clockwise);
  static IconData get saveRounded =>
      _pick(Icons.save_rounded, CupertinoIcons.checkmark_circle);
  static IconData get search => _pick(Icons.search, CupertinoIcons.search);
  static IconData get downloadRounded =>
      _pick(Icons.download_rounded, CupertinoIcons.arrow_down_doc);
  static IconData get linkRounded =>
      _pick(Icons.link_rounded, CupertinoIcons.link);
  static IconData get moreVertRounded =>
      _pick(Icons.more_vert_rounded, CupertinoIcons.ellipsis_vertical);
  static IconData get arrowBackRounded =>
      _pick(Icons.arrow_back_rounded, CupertinoIcons.back);
  static IconData get tag => _pick(Icons.tag, CupertinoIcons.tag);

  // Navigation / structure
  static IconData get homeRounded =>
      _pick(Icons.home_rounded, CupertinoIcons.house_fill);
  static IconData get settingsRounded =>
      _pick(Icons.settings_rounded, CupertinoIcons.settings);
  static IconData get gridViewRounded =>
      _pick(Icons.grid_view_rounded, CupertinoIcons.square_grid_2x2);
  static IconData get viewListRounded =>
      _pick(Icons.view_list_rounded, CupertinoIcons.list_bullet);

  // Theme
  static IconData get darkMode => _pick(Icons.dark_mode, CupertinoIcons.moon);
  static IconData get lightMode =>
      _pick(Icons.light_mode, CupertinoIcons.sun_max);

  // Commerce
  static IconData get shoppingCartOutlined =>
      _pick(Icons.shopping_cart_outlined, CupertinoIcons.cart);
  static IconData get shoppingCartRounded =>
      _pick(Icons.shopping_cart_rounded, CupertinoIcons.cart_fill);
  static IconData get addShoppingCart =>
      _pick(Icons.add_shopping_cart, CupertinoIcons.cart_badge_plus);
  static IconData get addShoppingCartRounded =>
      _pick(Icons.add_shopping_cart_rounded, CupertinoIcons.cart_badge_plus);
  static IconData get creditCard =>
      _pick(Icons.credit_card, CupertinoIcons.creditcard);
  static IconData get payment =>
      _pick(Icons.payment, CupertinoIcons.creditcard);
  static IconData get paymentRounded =>
      _pick(Icons.payment_rounded, CupertinoIcons.creditcard);
  static IconData get payments =>
      _pick(Icons.payments, CupertinoIcons.money_dollar_circle);
  static IconData get attachMoney =>
      _pick(Icons.attach_money, CupertinoIcons.money_dollar);
  static IconData get attachMoneyRounded =>
      _pick(Icons.attach_money_rounded, CupertinoIcons.money_dollar);
  static IconData get accountBalanceWallet =>
      _pick(Icons.account_balance_wallet, CupertinoIcons.creditcard);

  // Analytics / data
  static IconData get analyticsRounded =>
      _pick(Icons.analytics_rounded, CupertinoIcons.chart_bar_square);
  static IconData get barChartRounded =>
      _pick(Icons.bar_chart_rounded, CupertinoIcons.chart_bar);
  static IconData get showChartRounded =>
      _pick(Icons.show_chart_rounded, CupertinoIcons.chart_bar);
  static IconData get trendingUpRounded =>
      _pick(Icons.trending_up_rounded, CupertinoIcons.arrow_up_right);
  static IconData get calculateRounded =>
      _pick(Icons.calculate_rounded, CupertinoIcons.function);
  static IconData get dateRangeRounded =>
      _pick(Icons.date_range_rounded, CupertinoIcons.calendar);
  static IconData get storageRounded =>
      _pick(Icons.storage_rounded, CupertinoIcons.cube_box);

  // Receipts / inventory
  static IconData get receiptLongOutlined =>
      _pick(Icons.receipt_long_outlined, CupertinoIcons.doc_text);
  static IconData get receiptLongRounded =>
      _pick(Icons.receipt_long_rounded, CupertinoIcons.doc_text_fill);
  static IconData get inventory2Outlined =>
      _pick(Icons.inventory_2_outlined, CupertinoIcons.cube_box);
  static IconData get inventory2Rounded =>
      _pick(Icons.inventory_2_rounded, CupertinoIcons.cube_box_fill);

  // Info / status
  static IconData get errorOutline =>
      _pick(Icons.error_outline, CupertinoIcons.exclamationmark_circle);
  static IconData get errorOutlineRounded =>
      _pick(Icons.error_outline_rounded, CupertinoIcons.exclamationmark_circle);
  static IconData get infoOutlineRounded =>
      _pick(Icons.info_outline_rounded, CupertinoIcons.info_circle);
  static IconData get starRounded =>
      _pick(Icons.star_rounded, CupertinoIcons.star_fill);
  static IconData get radioButtonChecked =>
      _pick(Icons.radio_button_checked, CupertinoIcons.smallcircle_circle_fill);
  static IconData get radioButtonUnchecked =>
      _pick(Icons.radio_button_unchecked, CupertinoIcons.circle);

  // Media
  static IconData get cameraAltOutlined =>
      _pick(Icons.camera_alt_outlined, CupertinoIcons.camera);
  static IconData get photoLibraryOutlined =>
      _pick(Icons.photo_library_outlined, CupertinoIcons.photo_on_rectangle);
  static IconData get imageOutlined =>
      _pick(Icons.image_outlined, CupertinoIcons.photo);

  // Domain icons without Cupertino equivalents — fall back to Material.
  static IconData get restaurant => Icons.restaurant;
  static IconData get roomServiceRounded => Icons.room_service_rounded;
}
