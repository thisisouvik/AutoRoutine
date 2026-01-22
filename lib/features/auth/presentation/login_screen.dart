import 'package:autoroutine/features/auth/cubit/auth_cubit.dart';
import 'package:autoroutine/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    context.read<AuthCubit>().login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (BuildContext context, AuthState state) {
              final isLoading = state is AuthLoading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32,),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label:Text('Email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)
                      )
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      label: Text('Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)
                      )
                    ),
                  ),

                  const SizedBox(height: 24,),

                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading? null : _onLoginPressed,
                        child: isLoading 
                        ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        )
                        :const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)
                      ),
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: TextButton(onPressed: () {
                      //Registration Screen
                    }, child: const Text('Create New Account')),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
