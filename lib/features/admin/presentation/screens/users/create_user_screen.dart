import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/constants/admin_constants.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/services/currency/domain/entities/currency_entity.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/app_strings.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/currency_selection_bottom_sheet.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/custom_days_dialog.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/text_fields/auth_custom_text_field.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  static Future<bool?> push(BuildContext context) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateUserScreen()),
    );
  }

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _crnController = TextEditingController();
  final _vatController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;
  String _userType = 'cafe';
  String _platformType = 'mobile';
  int _subscriptionDays = 30;
  CurrencyEntity _selectedCurrency = CurrencyEntity.defaultCurrency;
  bool _isVip = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _projectNameController.dispose();
    _crnController.dispose();
    _vatController.dispose();
    _taxRateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double? parsedTaxRate = _taxRateController.text.trim().isNotEmpty
          ? double.tryParse(_taxRateController.text.trim())
          : null;

      final createUserUseCase = sl<CreateUserUseCase>();
      final result = await createUserUseCase(
        CreateUserParams(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          projectName: _projectNameController.text.trim(),
          subscriptionDays: _subscriptionDays,
          userType: _userType,
          platformType: _platformType,
          isVip: _isVip,
          crn: _crnController.text.trim(),
          vat: _vatController.text.trim(),
          taxRate: parsedTaxRate,
          address: _addressController.text.trim(),
          currency: _selectedCurrency.toMap(),
        ),
      );

      result.fold(
        (failure) {
          showfailureToast(failure.message);
        },
        (_) {
          showSuccessToast('admin_user_created'.tr());
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      showfailureToast(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: AppColors.scafoldBackGround,
      appBar: CustomAppBar(
        centerTitle: 'admin_create_user'.tr(),
        leadingIcon: const Icon(Icons.arrow_back_ios_new_rounded),
        onLeadingTap: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 16.w,
                vertical: 16.h,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderBanner(),
                    SizedBox(height: 16.h),
                    _buildAccountAccessSection(),
                    SizedBox(height: 16.h),
                    _buildPlatformAndSubscriptionSection(),
                    SizedBox(height: 16.h),
                    _buildCommercialAndTaxSection(),
                    SizedBox(height: 24.h),
                    _buildActionButtons(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              size: 28.sp,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  'إنشاء حساب تاجر / منشأة جديد',
                  style: TextStyles.font16WeightBoldText(),
                ),
                SizedBox(height: 4.h),
                TextWidget(
                  'قم بإدخال بيانات الحساب ومعلومات المنشأة والاشتراك لإنشاء حساب مالك جديد.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.subTitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountAccessSection() {
    return _buildCardWrapper(
      title: 'بيانات الحساب وتسجيل الدخول',
      icon: Icons.lock_person_outlined,
      children: [
        AuthTextFormField(
          label: 'admin_full_name'.tr(),
          controller: _nameController,
          hintText: 'مثال: محمد أحمد علي',
          textInputType: TextInputType.name,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'admin_name_required'.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: 'email_address'.tr(),
          controller: _emailController,
          hintText: 'example@domain.com',
          textInputType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'admin_email_required'.tr();
            }
            if (!v.contains('@') || !v.contains('.')) {
              return 'admin_invalid_email'.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: 'password'.tr(),
          controller: _passwordController,
          hintText: 'على الأقل 6 خانات',
          textInputType: TextInputType.visiblePassword,
          obscureText: _obscurePassword,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          suffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'كلمة المرور مطلوبة';
            }
            if (v.trim().length < 6) {
              return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
            }
            return null;
          },
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: 'customer_phone'.tr(),
          controller: _phoneController,
          hintText: '05xxxxxxxx',
          textInputType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPlatformAndSubscriptionSection() {
    return _buildCardWrapper(
      title: 'إعدادات الحساب والاشتراك',
      icon: Icons.tune_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    'admin_user_type'.tr(),
                    style: TextStyles.font14Weight400RightAligned().copyWith(
                      color: AppColors.subTitleColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.scafoldBackGround,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.lightGreyColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        iconEnabledColor: AppColors.textColor,
                        value: _userType,
                        items: [
                          DropdownMenuItem(
                            value: 'cafe',
                            child: TextWidget('user_type_cafe'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'shop',
                            child: TextWidget('user_type_shop'.tr()),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _userType = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    'admin_platform_type'.tr(),
                    style: TextStyles.font14Weight400RightAligned().copyWith(
                      color: AppColors.subTitleColor,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.scafoldBackGround,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.lightGreyColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        iconEnabledColor: AppColors.textColor,
                        value: _platformType,
                        items: [
                          DropdownMenuItem(
                            value: 'mobile',
                            child: TextWidget('platform_type_mobile'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'desktop',
                            child: TextWidget('platform_type_desktop'.tr()),
                          ),
                          DropdownMenuItem(
                            value: 'both',
                            child: TextWidget('platform_type_both'.tr()),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _platformType = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              'مدة الاشتراك المبدئي',
              style: TextStyles.font14Weight400RightAligned().copyWith(
                color: AppColors.subTitleColor,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColors.scafoldBackGround,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.lightGreyColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        dropdownColor: AppColors.surface,
                        iconEnabledColor: AppColors.textColor,
                        value: _subscriptionDays,
                        items: [
                          ...AdminConstants.subscriptionPresets.map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: TextWidget('$d ${'admin_days'.tr()}'),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _subscriptionDays = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  onPressed: () async {
                    final days = await showCustomDaysDialog(context);
                    if (days != null && days > 0) {
                      setState(() => _subscriptionDays = days);
                    }
                  },
                  icon: const Icon(Icons.more_time_rounded, size: 16),
                  label: const TextWidget('مدة مخصصة'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    side: BorderSide(color: AppColors.lightGreyColor),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: _isVip
                ? LinearGradient(
                    colors: AppColors.isDark
                        ? [const Color(0xFF2C2508), const Color(0xFF1E1A05)]
                        : [const Color(0xFFFFF8E7), const Color(0xFFFFF3D0)],
                  )
                : null,
            color: _isVip ? null : AppColors.scafoldBackGround,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _isVip
                  ? const Color(0xFFFFD700)
                  : AppColors.lightGreyColor.withValues(alpha: 0.5),
              width: _isVip ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _isVip
                      ? const Color(0xFFFFD700).withValues(alpha: 0.25)
                      : AppColors.lightGreyColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: _isVip
                      ? (AppColors.isDark
                            ? const Color(0xFFFFD700)
                            : const Color(0xFFD4AF37))
                      : AppColors.subTitleColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      'عميل مميز (VIP)',
                      style: TextStyles.font14Weight400RightAligned().copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isVip
                            ? (AppColors.isDark
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFB8860B))
                            : AppColors.textColor,
                      ),
                    ),
                    TextWidget(
                      'يمنح حسابه الأولوية وشارة التميز الذهبية',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.subTitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isVip,
                activeTrackColor: const Color(
                  0xFFFFD700,
                ).withValues(alpha: 0.5),
                activeThumbColor: const Color(0xFFFFD700),
                onChanged: (val) => setState(() => _isVip = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommercialAndTaxSection() {
    return _buildCardWrapper(
      title: 'بيانات المنشأة والنشاط التجاري والضريبي',
      icon: Icons.storefront_outlined,
      children: [
        AuthTextFormField(
          label: 'admin_project_name'.tr(),
          controller: _projectNameController,
          hintText: 'مثال: كافيه تحصيل / متجر الأمل',
          textInputType: TextInputType.text,
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: AuthTextFormField(
                label: '${'admin_crn'.tr()} (${'optional'.tr()})',
                controller: _crnController,
                hintText: '10 أرقام',
                textInputType: TextInputType.text,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AuthTextFormField(
                label: '${'admin_vat'.tr()} (${'optional'.tr()})',
                controller: _vatController,
                hintText: '15 رقم',
                textInputType: TextInputType.text,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AuthTextFormField(
                label: '${'admin_tax_rate'.tr()} (${'optional'.tr()})',
                controller: _taxRateController,
                hintText: '0.0',
                textInputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffixWidget: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      '%',
                      style: TextStyles.customStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed < 0 || parsed > 100) {
                      return '0 - 100';
                    }
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextWidget(
                      AppStrings.currencyLabel.tr(),
                      style: TextStyles.customStyle(
                        color: AppColors.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () async {
                      final selected = await CurrencySelectionBottomSheet.show(
                        context,
                        initialCurrency: _selectedCurrency,
                        onCurrencySelected: (c) {
                          setState(() => _selectedCurrency = c);
                        },
                      );
                      if (selected != null) {
                        setState(() => _selectedCurrency = selected);
                      }
                    },
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      height: 52.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.lightGreyColor.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _selectedCurrency.getName(AppStrings.currentLang),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              _selectedCurrency.getSymbol(
                                AppStrings.currentLang,
                              ),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.primaryColor,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: '${'admin_address'.tr()} (${'optional'.tr()})',
          controller: _addressController,
          hintText: 'مثال: القاهرة - المعادي / الرياض - الملز',
          textInputType: TextInputType.streetAddress,
        ),
      ],
    );
  }

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: TextWidget(
                  title,
                  style: TextStyles.font16WeightBoldText(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            text: 'إنشاء الحساب الآن',
            icon: Icons.check_circle_outline_rounded,
            height: 48.h,
            isLoading: _isLoading,
            onPressed: _handleCreateUser,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              side: BorderSide(color: AppColors.lightGreyColor),
            ),
            onPressed: () => Navigator.pop(context),
            child: TextWidget('cancel'.tr()),
          ),
        ),
      ],
    );
  }
}
