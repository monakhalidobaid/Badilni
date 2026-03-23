import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../widgets/custom_appbar.dart';
// تأكد من استيراد Supabase

class EbookReader extends StatefulWidget {
  final String pdf_url;
  final String title;

  const EbookReader({super.key, required this.pdf_url, required this.title});


  @override
  State<EbookReader> createState() => _EbookReaderState();
}

class _EbookReaderState extends State<EbookReader> {
  late String pdfUrl = 'https://flevnooqayosayzqbddt.supabase.co/storage/v1/object/public/image/PDF_1743021348323.pdf'; // قم بتحديد القيمة الافتراضية هنا

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: widget.title,
          centerTitle: true
      ),      body // عرض مؤشر التحميل إذا لم يتم تحميل الرابط
          : SfPdfViewer.network(widget.pdf_url
      , key: _pdfViewerKey),
    );
  }
}
