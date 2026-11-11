import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/validators.dart';

/// Mahalle esnafı/işletme kayıt ekranı.
class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedCategory = 'Market & Bakkal';
  final List<String> _categories = [
    'Market & Bakkal',
    'Manav',
    'Kasap',
    'Fırın & Unlu Mamül',
    'Şarküteri',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterBusinessRequested(
              email: _emailController.text,
              password: _passwordController.text,
              fullName: _fullNameController.text,
              storeName: _storeNameController.text,
              category: _selectedCategory,
              phone: _phoneController.text,
              address: _addressController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletme Kaydı'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pop(context);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'İşletmenizi Dijital Pazara Taşıyın',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gültepe Mahallesi sakinlerine ürünlerinizi tek platformdan ulaştırın.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _storeNameController,
                      label: 'İşletme / Dükkan Adı',
                      hint: 'Örn: Gültepe Şarküteri',
                      prefixIcon: const Icon(Icons.storefront_outlined),
                      validator: (v) => Validators.validateRequired(v, 'İşletme Adı'),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İşletme Kategorisi',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedCategory,
                              items: _categories
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedCategory = v);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _fullNameController,
                      label: 'Yetkili Ad Soyad',
                      hint: 'Örn: Mehmet Gül',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) => Validators.validateRequired(v, 'Yetkili Adı'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: 'İşletme E-posta Adresi',
                      hint: 'esnaf@mahallem.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneController,
                      label: 'İşletme Telefon Numarası',
                      hint: '0212 456 78 90',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _addressController,
                      label: 'Dükkan Açık Adresi (Gültepe Mah.)',
                      hint: 'Gültepe Mah. Huzur Meydanı No: 12',
                      maxLines: 2,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (v) => Validators.validateRequired(v, 'Açık Adres'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Giriş Şifresi',
                      hint: 'En az 6 karakter',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'İşletme Hesabı Oluştur',
                      type: AppButtonType.primary,
                      onPressed: _submit,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

