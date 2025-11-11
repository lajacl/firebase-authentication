import 'package:firebase_authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Auth Demo')),
      body: AuthenticationScreen(),
    );
  }
}

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool isLogin = true;

  void toggleScreen() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isLogin
                  ? EmailPasswordForm()
                  : RegisterEmailSection(goToLogin: toggleScreen),
              TextButton(
                onPressed: toggleScreen,
                child: Text(
                  isLogin
                      ? 'Need to sign up? Register HERE'
                      : 'Have an account? Login HERE',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterEmailSection extends StatefulWidget {
  final Function goToLogin;
  const RegisterEmailSection({super.key, required this.goToLogin});
  @override
  State<RegisterEmailSection> createState() => _RegisterEmailSectionState();
}

class _RegisterEmailSectionState extends State<RegisterEmailSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _success = false;
  bool _initialState = true;
  String? _userEmail = '';

  void _register() async {
    try {
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = _emailController.text;
          _initialState = false;
          widget.goToLogin();
        });
      } else {
        _success = false;
      }
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter some text';
              }
              if (!value.contains(RegExp(r'.+@.+\..+'))) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter some text';
              }
              if (value.trim().length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              _initialState
                  ? 'Please Register'
                  : _success
                  ? 'Successfully registered $_userEmail'
                  : 'Registration failed',
              style: TextStyle(color: _success ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class EmailPasswordForm extends StatefulWidget {
  const EmailPasswordForm({super.key});
  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _success = false;
  bool _initialState = true;
  String _userEmail = '';
  void _signInWithEmailAndPassword() async {
    final navigatorState = Navigator.of(context);
    try {
      User? user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        setState(() {
          _success = true;
          _userEmail = _emailController.text.trim();
          _initialState = false;
        });
        navigatorState.pushReplacement(
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } else {
        _success = false;
      }
    } catch (e) {
      setState(() {
        _success = false;
        _initialState = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text('Test sign in with email and password'),
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _signInWithEmailAndPassword();
                }
              },
              child: Text('Submit'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _initialState
                  ? 'Please sign in'
                  : _success
                  ? 'Successfully signed in $_userEmail'
                  : 'Sign in failed',
              style: TextStyle(color: _success ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _userEmail = '';

  void getUserEmail() {
    User? user = _authService.getCurrentUser();
    _userEmail = user?.email ?? '';
  }

  void signOut() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigatorState = Navigator.of(context);

    await _authService.signOut();
    messenger.showSnackBar(SnackBar(content: Text('Signed out successfully')));
    navigatorState.pushReplacement(
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              signOut();
            },
            child: Text('Sign Out'),
          ),
        ],
        actionsPadding: EdgeInsets.symmetric(horizontal: 24),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[Text(_userEmail)],
          ),
        ),
      ),
    );
  }
}
