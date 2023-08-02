import 'package:flutter/material.dart';
import 'package:meet_up/profile/components/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meet_up/utils/enum.dart';
import 'package:meet_up/utils/themes.dart';
import '../../language/appLocalizations.dart';
import '../../modules/login/change_password.dart';
import '../../resources/auth_methods.dart';
import '../../utils/text_styles.dart';
import '../../widgets/common_button.dart';
import 'package:meet_up/providers/theme_provider.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool switch1 = false;
  bool _darkMode = false;

  String dropdownvalue = 'Arabic';
  String? _selectedLanguage;

  // List of items in our dropdown menu
  final List<String> _languages = ['English', 'Arabic'];
  @override
  void initState() {
    super.initState();
    getSelectedPref();
    getSelectedTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          left: 16,
          top: 20,
          right: 16,
        ),
        child: ListView(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Color(0xFF4FBE9F),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  AppLocalizations(context).of("account"),
                  style: TextStyles(context).getRegularStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),
            ListTile(
              title: Text(
                AppLocalizations(context).of("my_account"),
                style: TextStyles(context).getRegularStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              leading: const Icon(
                Icons.person,
              ),
              trailing: const Icon(Icons.arrow_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              ),
            ),
            ListTile(
              title: Text(
                AppLocalizations(context).of("change_password"),
                style: TextStyles(context).getRegularStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              leading: const Icon(
                Icons.lock,
              ),
              trailing: const Icon(Icons.arrow_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangepasswordScreen()),
              ),
            ),
            ListTile(
              title: Text(
                AppLocalizations(context).of("delete_account"),
                style: TextStyles(context).getRegularStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              leading: const Icon(
                Icons.delete,
              ),
              trailing: const Icon(Icons.arrow_right),
              onTap: () => AuthMethods().showMyDialogDelete(context: context),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                const Icon(
                  Icons.settings,
                  color: Color(0xFF4FBE9F),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  AppLocalizations(context).of("pref"),
                  style: TextStyles(context).getRegularStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),
            ListTile(
              title: Text(
                AppLocalizations(context).of("ch_lan"),
                style: TextStyles(context).getRegularStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              leading: const Icon(
                Icons.language,
              ),
              trailing: DropdownButton(
                value: _selectedLanguage,
                onChanged: (newValue) async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  pref.setInt("Languagetype", (newValue == 'Arabic' ? 1 : 0));
                  setState(() {
                    _selectedLanguage = newValue as String?;
                    AuthMethods().showMyDialogRestart(context: context);
                    LanguageType.values[newValue == 'Arabic' ? 1 : 0];
                  });
                },
                hint: Text(
                  'Language',
                  style: TextStyles(context).getRegularStyle().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                alignment: AlignmentDirectional.center,
                items: _languages.map((lang) {
                  return DropdownMenuItem(
                    child: Text(lang),
                    value: lang,
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(
                AppLocalizations(context).of("dark"),
                style: TextStyles(context).getRegularStyle().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              leading: const Icon(
                Icons.dark_mode,
              ),
              trailing: Switch(
                activeColor: Colors.teal,
                value: _darkMode,
                onChanged: (val) async {
                  SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  pref.setInt("ThemeModeType", (val ? 1 : 0));
                  setState(() {
                    ThemeModeType.values[val ? 1 : 0];
                    setDarkMode(ThemeModeType.values[val ? 1 : 0], context);
                    _darkMode = val;
                  });
                },
              ),
            ),
            CommonButton(
              padding: const EdgeInsets.all(80),
              buttonText: AppLocalizations(context).of("log_out"),
              onTap: () {
                AuthMethods().showMyDialogLogOut(context: context);
              },
            ),
          ],
        ),
      ),
    );
  }

  getSelectedPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = _languages[pref.getInt('Languagetype') as int];

      _darkMode = pref.getInt('ThemeModeType') == 1 ? true : false;
    });
  }

  getSelectedTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = pref.getInt('ThemeModeType') == 1 ? true : false;
    });
  }

  void setDarkMode(ThemeModeType val, BuildContext context) {
    context.read<ThemeProvider>().updateThemeMode(val);
  }

  void setLanguage(LanguageType newValue, BuildContext context) {
    context.read<ThemeProvider>().updateLanguage((newValue));
  }
}
