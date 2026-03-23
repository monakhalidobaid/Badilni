import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'welcome_screen.dart'; // تأكد من استيراد ملف شاشة الترحيب

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkIfSeen();
  }

  // دالة تتحقق من حالة المقدمة في SharedPreferences
  Future<void> _checkIfSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIntro = prefs.getBool('seenIntro') ?? false;
    if (seenIntro) {
      // إذا كان المستخدم قد شاهد المقدمة، يتم التنقل تلقائيًا إلى شاشة الترحيب
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      });
    } else {
      // في حال عدم مشاهدة المقدمة بعد، يتم إخفاء مؤشر التحميل لعرضها
      setState(() {
        _loading = false;
      });
    }
  }

  // دالة تُستدعى عند إكمال المقدمة أو عند الضغط على "تخطي"
  void _onIntroEnd() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenIntro', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return IntroductionScreen(
      globalBackgroundColor: Colors.white,
      pages: [
        PageViewModel(
          titleWidget: Text(
            'بادل واحصل على كتاب جديد\nمن كتاب قديم لديك',
            textAlign: TextAlign.center,
            style: GoogleFonts.changa(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          bodyWidget: const SizedBox.shrink(),
          image: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 0),
            child: Image.asset('assets/img/intro1.png'),
          ),
        ),
        PageViewModel(
          titleWidget: Text(
            'استعر كتابك الرقمي\nالآن وتمتع بتجربة فريدة',
            textAlign: TextAlign.center,
            style: GoogleFonts.changa(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          bodyWidget: const SizedBox.shrink(),
          image: Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 0),
            child: Image.asset('assets/img/intro2.png'),
          ),        ),
      ],
      onDone: _onIntroEnd,
      onSkip: _onIntroEnd,
      showSkipButton: true,
      skip: Text(
        'تخطي',
        style: GoogleFonts.changa(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.teal,
        ),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: Colors.teal,
        size: 25,
      ),
      done: Text(
        "إنهاء",
        style: GoogleFonts.changa(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      dotsDecorator: const DotsDecorator(
        activeColor: Colors.teal,
        size: Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      curve: Curves.easeInOut,
    );
  }
}
