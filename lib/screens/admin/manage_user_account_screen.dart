import 'package:badilni_v1/widgets/custom_search_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data_models/admin.dart';
import '../../data_models/reader.dart';
import '../../style/styled_text.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_appbar.dart';

class ManageUserAccountScreen extends StatefulWidget {
  const ManageUserAccountScreen({super.key});

  @override
  ManageUserAccountScreenState createState() => ManageUserAccountScreenState();
}

class ManageUserAccountScreenState extends State<ManageUserAccountScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Reader> readers = [];
  List<Reader> filteredReaders = [];
  late Admin currentAdmin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentAdmin = Admin(
      uid: '3aVI843uvzddgF4lVG9wyGZTMKw2',
      email: 'Jiikop55@gmail.com',
      username: 'Ad5mona',
    );
    fetchReadersData();
  }

  Future<void> fetchReadersData() async {
    setState(() {
      _isLoading = true;
    });
    readers = await currentAdmin.fetchReaders();
    setState(() {
      filteredReaders = List.from(readers);
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReaders = List.from(readers);
      } else {
        filteredReaders = readers.where((reader) {
          final usernameLower = reader.username.toLowerCase();
          final emailLower = reader.email.toLowerCase();
          final searchLower = query.toLowerCase();
          return usernameLower.contains(searchLower) ||
              emailLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _confirmDelete(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'تأكيد إيقاف التفعيل',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          content: const Text(
            'هل تريد إيقاف تفعيل هذا الحساب؟',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 11.0,
                      horizontal: 28.0,
                    ),
                    minimumSize: Size.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const BodySmall('إلغاء'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    textStyle: const TextStyle(fontSize: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 11.0,
                      horizontal: 28.0,
                    ),
                    minimumSize: Size.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    // استدعاء دالة حذف الريدر
                    await currentAdmin.deleteReaderAccount(filteredReaders[index].uid);

                    // تحديث الحالة لحذف الريدر من القائمتين
                    setState(() {
                      readers.removeWhere(
                              (user) => user.uid == filteredReaders[index].uid);
                      filteredReaders.removeAt(index);
                    });

                    Navigator.of(context).pop();
                  },
                  child: const BodySmall('موافق'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "إدارة المستخدمين",
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomSearchField(
                  controller: _searchController,
                  onSearch: _onSearch,
                  onClear: () => _onSearch(""),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredReaders.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filteredReaders[index].username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                filteredReaders[index].email,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          leading: const Icon(Icons.person),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 12.0,
                              ),
                              minimumSize: Size.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () async {
                              await _confirmDelete(index);
                            },
                            child: Text(
                              'إيقاف الحساب',
                              style: GoogleFonts.aBeeZee(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
