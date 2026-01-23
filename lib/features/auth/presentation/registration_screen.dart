import 'package:autoroutine/features/auth/cubit/auth_cubit.dart';
import 'package:autoroutine/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _namecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();

  @override
  void dispose() {
    _namecontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    final name = _namecontroller.text.trim();
    final email = _emailcontroller.text.trim();
    final password = _passwordcontroller.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required ')));
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be greater than 6 characters'),
        ),
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : Center(child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold),))),
      body:
        Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },

            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                
                  const SizedBox(height: 50),

                  TextField(
                    controller: _namecontroller,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text("Name", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  ),

                  const SizedBox(height: 14),  

                  TextField(
                    controller: _emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      label: Text("Email", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                    ),
                  ),

                  const SizedBox(height: 14),  

                  TextField(
                    controller: _passwordcontroller,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      label: Text("Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 14,),
                  
                  SizedBox(
                    width: 250,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onRegisterPressed,
                      child: isLoading 
                      ? CircularProgressIndicator(
                        backgroundColor: const Color.fromARGB(255, 226, 216, 216),
                        strokeWidth: 2,
                      )
                      : Center(child: const Text('Register', style: TextStyle(fontSize: 20),))
                      ),
                  ),

                ],
              );
            },
          ),
        ),
    );
  }
}
