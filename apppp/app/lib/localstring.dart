// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
//
// class LocaleString extends Translations {
//   @override
//   // TODO: implement keys
//   Map<String, Map<String, String>> get keys => {
//     // ENGLISH LANGUAGE
//     'en_US': {
//       'pims': 'PIMS',
//       'message': 'Punjab Irrigation Support Management System',
//       'title': 'Login',
//       'select': 'Select Role',
//       'email':'E-mail/Mobile No./User ID',
//       'emailvalidate':'Email/Mobile No./User ID cannot be empty',
//       'pass':'Password',
//       'passwordvalidate':'Password cannot be empty',
//       'sign':'Sign In',
//       'forget':'Forget Password',
//       'account':'Don\'t have an account?',
//       'sign up':'Sign Up',
//       'changelang': 'Change Language'
//     },
//
//     // PUNJABI LANGUAGE
//     'pa_IN': {
//       'pims': 'ਪਿਸਮੀਸ',
//       'message': 'ਪੰਜਾਬ ਸਿੰਚਾਈ ਸਹਾਇਤਾ ਪ੍ਰਬੰਧਨ ਪ੍ਰਣਾਲੀ',
//       'title': 'ਲਾਗਇਨ',
//       'select': 'ਰੋਲ ਚੁਣੋ',
//       'sign up':'ਸਾਇਨ ਅੱਪ',
//       'email':'ਈ-ਮੇਲ/ਮੋਬਾਇਲ ਨੰਬਰ/ਯੂਜ਼ਰ ਆਈਡੀ',
//   'emailvalidate':'ਈ-ਮੇਲ/ਮੋਬਾਇਲ ਨੰਬਰ/ਯੂਜ਼ਰ ਆਈਡੀ ਖਾਲੀ ਨਹੀਂ ਹੋ ਸਕਦਾ',
//   'pass':'ਪਾਸਵਰਡ',
//   'passwordvalidate':'ਪਾਸਵਰਡ ਖਾਲੀ ਨਹੀਂ ਹੋ ਸਕਦਾ',
//   'sign':'ਸਾਇਨ ਇਨ',
//   'forget':'ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ',
//   'account':'ਖਾਤਾ ਨਹੀਂ ਹੈ?',
//       'changelang': 'ਭਾਸ਼ਾ ਬਦਲੋ'
//     }
//   };
//
//   // static LocaleString of(BuildContext context) =>
//   //     Localizations.of<LocaleString>(context, LocaleString)!;
//   //
//   // String translate(String key) => keys[Get.locale!.toString()]![key]!;
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// //
// // class HomePage extends StatelessWidget {
// //
// //   final List locale =[
// //     {'name':'ENGLISH','locale': Locale('en','US')},
// //     {'name':'ಕನ್ನಡ','locale': Locale('kn','IN')},
// //     {'name':'हिंदी','locale': Locale('hi','IN')},
// //   ];
// //
// //   updateLanguage(Locale locale){
// //     Get.back();
// //     Get.updateLocale(locale);
// //   }
// //
// //   buildLanguageDialog(BuildContext context){
// //     showDialog(context: context,
// //         builder: (builder){
// //           return AlertDialog(
// //             title: Text('Choose Your Language'),
// //             content: Container(
// //               width: double.maxFinite,
// //               child: ListView.separated(
// //                   shrinkWrap: true,
// //                   itemBuilder: (context,index){
// //                     return Padding(
// //                       padding: const EdgeInsets.all(8.0),
// //                       child: GestureDetector(child: Text(locale[index]['name']),onTap: (){
// //                         print(locale[index]['name']);
// //                         updateLanguage(locale[index]['locale']);
// //                       },),
// //                     );
// //                   }, separatorBuilder: (context,index){
// //                 return Divider(
// //                   color: Colors.blue,
// //                 );
// //               }, itemCount: locale.length
// //               ),
// //             ),
// //           );
// //         }
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //         appBar: AppBar(title: Text('title'.tr),),
// //         body: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text('hello'.tr,style: TextStyle(fontSize: 15),),
// //             SizedBox(height: 10,),
// //             Text('message'.tr,style: TextStyle(fontSize: 20),),
// //             SizedBox(height: 10,),
// //             Text('subscribe'.tr,style: TextStyle(fontSize: 20),),
// //
// //             ElevatedButton(onPressed: (){
// //               buildLanguageDialog(context);
// //             }, child: Text('changelang'.tr)),
// //           ],
// //         )
// //     );
// //   }
// // }