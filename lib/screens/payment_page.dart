import 'package:badilni_v1/screens/home_screen.dart';
import 'package:badilni_v1/screens/my_library.dart';
import 'package:badilni_v1/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/borrowed_books_provider.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, String> bookData; // استقبال بيانات الكتاب

  const PaymentPage({Key? key, required this.bookData}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers للحقول
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("بيانات الكتاب: ${widget.bookData}");
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryDateController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      print("بدأت عملية الدفع");

      // محاكاة تأخير عملية الدفع
      await Future.delayed(const Duration(seconds: 2));

      // الحصول على المستخدم الحالي
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى تسجيل الدخول أولاً")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      String userID = user.uid;
      print("المستخدم مسجل الدخول: $userID");

      final DatabaseReference borrowRef =
      FirebaseDatabase.instance.ref().child("borrowRecords");

      // تحقق مما إذا كانت العقدة موجودة أم لا
      final DatabaseEvent event = await borrowRef.once();
      print("قيمة event.snapshot.exists: ${event.snapshot.exists}");

      // إذا كانت العقدة غير موجودة، نقوم بإنشاء أول سجل استعارة مباشرةً
      if (!event.snapshot.exists) {
        DateTime startDate = DateTime.now();
        DateTime endDate = startDate.add(const Duration(days: 30));
        print("إنشاء أول سجل استعارة");

        await borrowRef.push().set({
          'userID': userID,
          'book_id': widget.bookData['book_id'] ?? 'معرف غير معروف',
          'title': widget.bookData['title'] ?? 'عنوان غير معروف',
          'author': widget.bookData['author'] ?? 'مؤلف غير معروف',
          'coverImage': widget.bookData['coverImage'] ?? 'صورة غير معروف',
          'pdf_url': widget.bookData['pdf_url'] ?? 'كتاب غير معروف',
          'price': widget.bookData['price'] ?? 'سعر غير معروف',

          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'paymentInfo': {
            'paymentID': '${DateTime.now().millisecondsSinceEpoch}',
            'status': 'success',
            'cardNumber': _cardNumberController.text.length >= 4
                ? '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}'
                : '',
            'paymentDate': startDate.toIso8601String(),
          },
        });

        // إضافة الكتاب إلى مكتبة المستخدم باستخدام Provider
        widget.bookData['userID'] = userID;
        final borrowedBooksProvider =
        Provider.of<BorrowedBooksProvider>(context, listen: false);
        borrowedBooksProvider.addBorrowedBook(widget.bookData);

        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تمت عملية الدفع بنجاح وإضافة الكتاب إلى مكتبتك"),
            duration: Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyLibrary()),
        );
      } else {
        print("العقدة موجودة، الانتقال للفروع الأخرى");

        // 1) التحقق من أن المستخدم لا يملك أي استعارة حالية لم تنتهِ بعد
        final userBorrowsSnapshot = await borrowRef
            .orderByChild("userID")
            .equalTo(userID)
            .get();

        bool hasActiveBorrow = false;
        if (userBorrowsSnapshot.exists) {

          for (var child in userBorrowsSnapshot.children) {
            final data = Map<String, dynamic>.from(child.value as Map);
            DateTime endDate = DateTime.parse(data['endDate']);
            if (DateTime.now().isBefore(endDate)) {
              print("-------------------------------$hasActiveBorrow");

              hasActiveBorrow = true;
              print("وجد استعارة نشطة للمستخدم");
              print("-------------------------------$hasActiveBorrow");

              break;
            }
          }
        }
        if (hasActiveBorrow) {
          print("-------------------------------$hasActiveBorrow");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("لا يمكنك استعارة كتاب آخر قبل انتهاء استعارتك الحالية"),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // 2) التحقق من أن المستخدم لم يقم باستعارة هذا الكتاب من قبل وما زالت استعارة الكتاب سارية
        final sameBookSnapshot = await borrowRef
            .orderByChild("book_id")
            .equalTo(widget.bookData['book_id'])
            .get();

        bool userAlreadyBorrowedThisBook = false;
        if (sameBookSnapshot.exists) {
          print("ننننننننننننننننننننننننننننننننننننننننننننننننننننننننن");

          for (var child in sameBookSnapshot.children) {
            final data = Map<String, dynamic>.from(child.value as Map);
            DateTime endDate = DateTime.parse(data['endDate']);
            if (data['userID'] == userID && DateTime.now().isBefore(endDate)) {
              userAlreadyBorrowedThisBook = true;
              print("المستخدم استعار هذا الكتاب سابقاً وما زالت استعارة الكتاب سارية");
              break;
            }
          }
        }
        if (userAlreadyBorrowedThisBook) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("لقد استعرته سابقًا ولم تنتهِ فترة الاستعارة بعد"),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // 3) التحقق من أن الكتاب غير مستعار حاليًا من قبل مستخدم آخر
        bool bookIsBorrowedBySomeoneElse = false;
        if (sameBookSnapshot.exists) {
          for (var child in sameBookSnapshot.children) {
            final data = Map<String, dynamic>.from(child.value as Map);
            DateTime endDate = DateTime.parse(data['endDate']);
            print("فحص سجل: userID=${data['userID']}, endDate=$endDate, حالياً: ${DateTime.now()}");
            if (data['userID'] != userID && DateTime.now().isBefore(endDate)) {
              bookIsBorrowedBySomeoneElse = true;
              print("الكتاب مستعار من قبل مستخدم آخر");
              break;
            }
          }
        }

        if (bookIsBorrowedBySomeoneElse) {
          print("***********************************$bookIsBorrowedBySomeoneElse");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("عذرًا، هذا الكتاب مستعار حاليًا من مستخدم آخر"),
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // إذا لم تكن هناك أي مشاكل في الشروط السابقة، ننفذ الكود التالي:
        DateTime startDate = DateTime.now();
        DateTime endDate = startDate.add(const Duration(days: 30));
        print("إنشاء سجل استعارة جديد في الفرع else");

        await borrowRef.push().set({
          'userID': userID,
          'book_id': widget.bookData['book_id'] ?? 'معرف غير معروف',
          'title': widget.bookData['title'] ?? 'عنوان غير معروف',
          'author': widget.bookData['author'] ?? 'مؤلف غير معروف',
          'coverImage': widget.bookData['coverImage'] ?? 'صورة غير معروف',
          'pdf_url': widget.bookData['pdf_url'] ?? 'كتاب غير معروف',
          'price': widget.bookData['price'] ?? 'سعر غير معروف',

          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'paymentInfo': {
            'paymentID': '${DateTime.now().millisecondsSinceEpoch}',
            'status': 'success',
            'cardNumber': _cardNumberController.text.length >= 4
                ? '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}'
                : '',
            'paymentDate': startDate.toIso8601String(),
          },
        });

        // تحديث بيانات الكتاب مع userID قبل إضافته إلى المكتبة
        widget.bookData['userID'] = userID;
        final borrowedBooksProvider =
        Provider.of<BorrowedBooksProvider>(context, listen: false);
        borrowedBooksProvider.addBorrowedBook(widget.bookData);

        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تمت عملية الدفع بنجاح وإضافة الكتاب إلى مكتبتك"),
            duration: Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyLibrary()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان أن المحتوى من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "عملية الدفع", // عنوان الـ AppBar
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 13, 15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صف شعار البطاقة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/img/card.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'بطاقة الائتمان',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  // صف شعارات البطاقات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 140),
                      Image.asset(
                        'assets/img/paypal.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/img/visa.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/img/mastercard.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/img/amex.png',
                        width: 40,
                        height: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // حقل رقم البطاقة
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'رقم البطاقة',
                      hintText: 'يرجى إدخال رقم البطاقة',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم البطاقة';
                      }
                      if (!RegExp(r'^\d{15,16}$').hasMatch(value)) {
                        return 'يجب أن يحتوي رقم البطاقة على 15 أو 16 رقمًا فقط';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // حقل CVV
                  TextFormField(
                    controller: _cvvController,
                    decoration: const InputDecoration(
                      labelText: 'الرمز CVV',
                      hintText: 'أدخل الرمز',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رمز CVV';
                      }
                      if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
                        return 'يجب أن يحتوي رمز CVV على 3 أو 4 أرقام';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // حقل تاريخ الانتهاء
                  TextFormField(
                    controller: _expiryDateController,
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الانتهاء (الشهر/السنة)',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال تاريخ الانتهاء';
                      }
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                        return 'صيغة التاريخ غير صحيحة، يرجى إدخالها بالشكل MM/YY';
                      }
                      final parts = value.split('/');
                      final month = int.tryParse(parts[0]);
                      final year = int.tryParse(parts[1]);
                      if (month == null || year == null) {
                        return 'تاريخ غير صحيح';
                      }
                      final now = DateTime.now();
                      final currentTwoDigitYear = now.year % 100;
                      final currentMonth = now.month;
                      if (year < currentTwoDigitYear ||
                          (year == currentTwoDigitYear && month < currentMonth)) {
                        return 'تاريخ الانتهاء منتهي ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // حقل الاسم على البطاقة
                  TextFormField(
                    controller: _cardNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم على البطاقة',
                      hintText: 'أدخل الاسم كما هو مطبوع',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  // زر الدفع
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xC8B7F3EC),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _isLoading ? null : _processPayment,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                        'دفع',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
