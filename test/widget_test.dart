// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:vrum/main.dart';
// import 'package:vrum/providers/auth_provider.dart';
// import 'package:vrum/services/api_client.dart';

// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences.setMockInitialValues(const {});

//   testWidgets(
//     'Auth screen switches between login and registration',
//     (WidgetTester tester) async {
//       final apiClient = ApiClient();

//       await tester.pumpWidget(
//         MultiProvider(
//           providers: [
//             Provider<ApiClient>.value(value: apiClient),
//             ChangeNotifierProvider<AuthProvider>(
//               create: (_) => AuthProvider(client: apiClient),
//             ),
//           ],
//           child: const BikeApp(),
//         ),
//       );

//     // Verify that our counter starts at 0.
//       expect(find.text('Авторизация'), findsOneWidget);
//       expect(
//         find.widgetWithText(TextFormField, 'Пароль'),
//         findsOneWidget,
//       );
//       expect(
//         find.widgetWithText(TextFormField, 'Повторите пароль'),
//         findsNothing,
//       );

//     // Tap the '+' icon and trigger a frame.
//       await tester.tap(find.text('Зарегистрироваться'));
//       await tester.pumpAndSettle();

//       expect(find.text('Регистрация'), findsOneWidget);
//       expect(
//         find.widgetWithText(TextFormField, 'Повторите пароль'),
//         findsOneWidget,
//       );
//     },
//   );
// }
