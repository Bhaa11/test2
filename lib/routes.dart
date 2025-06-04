import 'package:ecommercecourse/core/constant/routes.dart';
import 'package:ecommercecourse/core/middleware/mymiddleware.dart';
import 'package:ecommercecourse/test_view.dart';
import 'package:ecommercecourse/view/screen/addproduct.dart';
import 'package:ecommercecourse/view/screen/categories/add.dart';
import 'package:ecommercecourse/view/screen/categories/edit.dart';
import 'package:ecommercecourse/view/screen/categories/view.dart';
import 'package:ecommercecourse/view/screen/address/add.dart';
import 'package:ecommercecourse/view/screen/address/adddetails.dart';
import 'package:ecommercecourse/view/screen/address/view.dart';
import 'package:ecommercecourse/view/screen/auth/forgetpassword/forgetpassword.dart';
import 'package:ecommercecourse/view/screen/auth/login.dart';
import 'package:ecommercecourse/view/screen/auth/forgetpassword/resetpassword.dart';
import 'package:ecommercecourse/view/screen/auth/signup.dart';
import 'package:ecommercecourse/view/screen/auth/forgetpassword/success_resetpassword.dart';
import 'package:ecommercecourse/view/screen/auth/success_signup.dart';
import 'package:ecommercecourse/view/screen/auth/forgetpassword/verifycode.dart';
import 'package:ecommercecourse/view/screen/auth/verifycodesignup.dart';
import 'package:ecommercecourse/view/screen/cart.dart';
import 'package:ecommercecourse/view/screen/checkout.dart';
import 'package:ecommercecourse/view/screen/homescreen.dart';
import 'package:ecommercecourse/view/screen/items.dart';
import 'package:ecommercecourse/view/screen/items_seller/add/add.dart';
import 'package:ecommercecourse/view/screen/items_seller/edit.dart';
import 'package:ecommercecourse/view/screen/items_seller/view.dart';
import 'package:ecommercecourse/view/screen/language.dart';
import 'package:ecommercecourse/view/screen/myfavorite.dart';
import 'package:ecommercecourse/view/screen/notification.dart';
import 'package:ecommercecourse/view/screen/offfers.dart';
import 'package:ecommercecourse/view/screen/onboarding.dart';
import 'package:ecommercecourse/view/screen/orders/archive.dart';
import 'package:ecommercecourse/view/screen/orders/details.dart';
import 'package:ecommercecourse/view/screen/orders/pending.dart';
import 'package:ecommercecourse/view/screen/orders_seller/accepted.dart';
import 'package:ecommercecourse/view/screen/orders_seller/screen.dart';
import 'package:ecommercecourse/view/screen/ordersall.dart';
import 'package:ecommercecourse/view/screen/orderssellerall.dart';
import 'package:ecommercecourse/view/screen/productdetails.dart';
import 'package:ecommercecourse/view/screen/sellerdetails.dart';
import 'package:ecommercecourse/view/screen/sidesettings.dart';
import 'package:ecommercecourse/view/screen/wallet.dart';
import 'package:get/get.dart';

import 'core/services/services.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(
      name: "/", page: () => const Language(), middlewares: [MyMiddleWare()]),
  // GetPage(name: "/", page: () =>   TestView()),
  GetPage(name: AppRoute.cart, page: () => const Cart()),
//  Auth
  GetPage(name: AppRoute.login, page: () => const Login()),
  GetPage(name: AppRoute.signUp, page: () => const SignUp()),
  GetPage(name: AppRoute.forgetPassword, page: () => const ForgetPassword()),
  GetPage(name: AppRoute.verfiyCode, page: () => const VerfiyCode()),
  GetPage(name: AppRoute.resetPassword, page: () => const ResetPassword()),
  GetPage(
      name: AppRoute.successResetpassword,
      page: () => const SuccessResetPassword()),
  GetPage(name: AppRoute.successSignUp, page: () => const SuccessSignUp()),
  GetPage(name: AppRoute.onBoarding, page: () => const OnBoarding()),
  GetPage(
      name: AppRoute.verfiyCodeSignUp, page: () => const VerfiyCodeSignUp()),
  //
  GetPage(name: AppRoute.homepage, page: () => const HomeScreen()),
  GetPage(name: AppRoute.items, page: () => const Items()),
  GetPage(name: AppRoute.productdetails, page: () => const ProductDetails()),
  GetPage(name: AppRoute.myfavroite, page: () => const MyFavorite()),
  //
  GetPage(name: AppRoute.addressview, page: () => const AddressView()),
  GetPage(name: AppRoute.addressadd, page: () => const AddressAdd()),
  GetPage(name: AppRoute.checkout, page: () => const Checkout()),
  GetPage(name: AppRoute.orderspending, page: () => const OrdersPending(orderType: "0")),
  GetPage(name: AppRoute.ordersarchive, page: () => const OrdersArchiveView()),
  GetPage(name: AppRoute.ordersdetails, page: () => const OrdersDetails()),
  //GetPage(name: AppRoute.offers, page: () => const OffersView()),
  GetPage(name: AppRoute.addressadddetails, page: () => const AddressAddDetails()),
  GetPage(name: AppRoute.ordersall, page: () => const OrdersAll()),
  GetPage(name: AppRoute.sidesettings, page: () =>  SideSettings()),
  GetPage(name: AppRoute.itemsview, page: () => const ItemsView()),
  GetPage(name: AppRoute.itemsadd, page: () => const ItemsAdd()),
  GetPage(name: AppRoute.itemsedit, page: () => const ItemsEdit()),
  GetPage(name: AppRoute.addproduct, page: () => const AddProduct()),

  // Categorys- seller
  GetPage(name: AppRoute.categoriesview, page: () => const CategoriesView()),
  GetPage(name: AppRoute.categoriesadd, page: () => const CategoriesAdd()),
  GetPage(name: AppRoute.categoriesedit, page: () => const CategoriesEdit()),
  // Orders-seller
  GetPage(name: AppRoute.ordershome, page: () => const OrdersSellerScreen()),
  GetPage(name: AppRoute.notificationview, page: () => const NotificationView()),
  GetPage(name: AppRoute.sellersetails, page: () => const SellerDetailsView()),
  GetPage(
      name: AppRoute.mywallet,
      page: () {
        MyServices myServices = Get.find();
        String? userId = myServices.sharedPreferences.getString("id");
        return MyWallet(userId: int.parse(userId ?? "0"));
      }
  ),

];
