class AppLink {

static const String server = "https://lightsalmon-owl-235921.hostingersite.com/ecommerce";

static const String imageststatic = "https://lightsalmon-owl-235921.hostingersite.com/ecommerce/upload";
//========================== Image ============================
  static const String imagestCategories = "$imageststatic/categories";
  static const String imagestItems = "$imageststatic/items";
  static const String imagestUsers = "$imageststatic/users";
// =============================================================
//
  static const String test = "$server/test.php";

  static const String notification = "$server/notification.php";

// ================================= Auth ========================== //

  static const String signUp = "$server/auth/signup.php";
  static const String login = "$server/auth/login.php";
  static const String verifycodessignup = "$server/auth/verfiycode.php";
  static const String resend = "$server/auth/resend.php";

// ================================= ForgetPassword ========================== //

  static const String checkEmail = "$server/forgetpassword/checkemail.php";
  static const String resetPassword =
      "$server/forgetpassword/resetpassword.php";
  static const String verifycodeforgetpassword =
      "$server/forgetpassword/verifycode.php";

// Home

  static const String homepage = "$server/home.php";
// items
  static const String items = "$server/items/items.php";
  static const String searchitems = "$server/items/search.php";

// Favorite

  static const String favoriteAdd = "$server/favorite/add.php";
  static const String favoriteRemove = "$server/favorite/remove.php";
  static const String favoriteView = "$server/favorite/view.php";
  static const String deletefromfavroite =
      "$server/favorite/deletefromfavroite.php";

  // Cart
  static const String cartview = "$server/cart/view.php";
  static const String cartadd = "$server/cart/add.php";
  static const String cartdelete = "$server/cart/delete.php";
  static const String cartgetcountitems = "$server/cart/getcountitems.php";

  // Address

  static const String addressView = "$server/address/view.php";
  static const String addressAdd = "$server/address/add.php";
  static const String addressEdit = "$server/address/edit.php";
  static const String addressDelete = "$server/address/delete.php";

  // Coupon

  static const String checkcoupon  = "$server/coupon/checkcoupon.php";

  // Checkout

  static const String checkout  = "$server/orders/checkout.php";

  static const String pendingorders  = "$server/orders/pending.php";
  static const String ordersarchive  = "$server/orders/archive.php";
  static const String ordersdetails  = "$server/orders/details.php";
  static const String ordersdelete  = "$server/orders/delete.php";
  //
  static const String offers  = "$server/offers.php";
  static const String rating  = "$server/rating.php";

  // Items - Seller
  static const String itemsview    = "$server/admin/items/view.php";
  static const String citemsadd    = "$server/admin/items/add.php";
  static const String itemsedit    = "$server/admin/items/edit.php";
  static const String itemsdelete  = "$server/admin/items/delete.php";

  // Categorys _ Seller
  static const String categoriesview    = "$server/admin/categories/view.php";
  static const String categoriesadd     = "$server/admin/categories/add.php";
  static const String categoriesedit    = "$server/admin/categories/edit.php";
  static const String categoriesdelete  = "$server/admin/categories/delete.php";

  // Orders - Seller

  static const String approveOrder        = "$server/admin/orders/approve.php";
  static const String prepare             = "$server/admin/orders/prepare.php";

  static const String viewarchiveOrders   = "$server/admin/orders/archive.php";
  static const String viewpendingOrders   = "$server/admin/orders/viewpendiing.php";
  static const String viewacceptedOrders  = "$server/admin/orders/viewaccepted.php";
  static const String detailsOrders       = "$server/admin/orders/details.php";

  // Wallet
  static const String walletGet = "$server/wallet/get_wallet.php";
  static const String walletDeposit = "$server/wallet/deposit.php";
  static const String walletWithdraw = "$server/wallet/withdraw.php";
  static const String walletTransactions = "$server/wallet/transactions.php";

  //ratings seller
  static const String sellerRatingsView = "$server/admin/ratings/view.php";
  static const String sellerRating = "$server/admin/ratings/add.php";
  static const String viewSellerRating = "$server/admin/ratings/view.php";

  //PageProfile
  static const String getUserProfile = "$server/profilepage/view.php";
  static const String updateProfile = "$server/profilepage/edit.php";



  static const String updateProfileImage = "$server/profile/update_profile_image.php";
  static const String deleteProfileImage = "$server/profile/delete_profile_image.php";

}