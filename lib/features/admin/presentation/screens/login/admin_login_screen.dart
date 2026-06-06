import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/assets.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/auth/auth_state.dart';
import 'package:tahsel_dashboard/routes/app_routes.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/text_fields/auth_custom_text_field.dart';
// AuthTextFormField is defined in auth_custom_text_field.dart
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.adminShell);
          } else if (state is AuthError) {
            showfailureToast(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset(Assets.imagesAppLogo, width: 100.w),
                      SizedBox(height: 24.h),
                      TextWidget(
                        'admin_login_title'.tr(),
                        style: TextStyles.appbartext(),
                      ),
                      SizedBox(height: 8.h),
                      TextWidget(
                        'admin_login_subtitle'.tr(),
                        style: TextStyles.font14Weight400RightAligned().copyWith(
                          color: AppColors.subTitleColor,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      AuthTextFormField(
                        label: 'email_address'.tr(),
                        controller: _emailController,
                        hintText: 'email_address'.tr(),
                        textInputType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'validation_email_required'.tr() : null,
                      ),
                      SizedBox(height: 16.h),
                      AuthTextFormField(
                        label: 'password'.tr(),
                        controller: _passwordController,
                        hintText: 'password'.tr(),
                        textInputType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'validation_password_required'.tr() : null,
                      ),
                      SizedBox(height: 24.h),
                      CustomButton(
                        text: 'login'.tr(),
                        isLoading: isLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
