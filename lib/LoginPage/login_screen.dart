import 'package:cached_network_image/cached_network_image.dart';
import 'package:findjob_app/Services/global_method.dart';
import 'package:findjob_app/SignupPage/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

import '../ForgetPassword/forget_password_screen.dart';
import '../Services/global_variables.dart';

class Login extends StatefulWidget{
  const Login({super.key});


  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{

  late Animation<double> _animation;
  late AnimationController _animationController;


  final TextEditingController _emailTextController = TextEditingController(text: '');
  final TextEditingController _passTextController = TextEditingController(text: '');


  final FocusNode _passFocusNode = FocusNode();
  bool _isLoading = false;
  late bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
    ..addListener(() {
      setState(() {

      });
    })
    ..addStatusListener((animationStatus){
      if(animationStatus == AnimationStatus.completed)
        {
          _animationController.reset();
          _animationController.forward();
        }
    });
    _animationController.forward();
    super.initState();
  }

  void _submitFormOnLogin() async{
    final isValid = _loginFormKey.currentState!.validate();
    if(isValid){
      setState(() {
        _isLoading = true;
      });
      try{
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.trim().toLowerCase(),
            password: _passTextController.text.trim(),
        );
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }catch(error){
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        print('error occurred $error');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
              imageUrl: loginUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value,0),
          ),
          Container(
            color: Colors.black54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
              child: ListView(
                children: [
                  Padding(
                      padding:const EdgeInsets.only(left:  80,right: 80),
                    child: Image.asset('assets/images/login.png'),
                  ),
                  const SizedBox(height: 15,),
                  Form(
                    key: _loginFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailTextController,
                          validator: (value){
                            if(value!.isEmpty || !value.contains('@')){
                              return 'Hãy nhập vào email hợp lệ';
                            }
                            else {
                              return null;
                            }
                          },
                          style: const TextStyle(
                            color: Colors.white
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            )
                          ),
                        ),
                        const SizedBox(height: 5,),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode:  _passFocusNode,
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passTextController,
                          obscureText: !_obscureText, //change it dynamically
                          validator: (value){
                            if(value!.isEmpty || value.length < 7){
                              return "Hãy nhập mật khẩu hợp lệ";
                            }
                            else{
                              return null;
                            }
                          },
                          style: const TextStyle(
                              color: Colors.white
                          ),
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                              color: Colors.white,
                              ),
                            ),
                              hintText: 'Mật khẩu',
                              hintStyle: const TextStyle(color: Colors.white),
                              enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()));
                            },
                            child: const Text(
                              'Quên Mật Khẩu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        MaterialButton
                          (
                            onPressed: _submitFormOnLogin,
                          color: Colors.cyan,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Đăng Nhập',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40,),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children:[
                                TextSpan(
                                  text: 'Không có tài khoản?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                TextSpan(text: '    '),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.push(context,MaterialPageRoute(builder: (context) => Signup())),
                                  text: 'Đăng Ký',
                                  style: TextStyle(
                                    color: Colors.cyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize:16
                                  )
                                ),
                              ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}