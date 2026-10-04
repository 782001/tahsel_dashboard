import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tahsel_dashboard/core/extensions/string_extensions.dart';
import 'package:tahsel_dashboard/core/services/currency/data/world_currencies.dart';
import 'package:tahsel_dashboard/core/services/currency/domain/entities/currency_entity.dart';
import 'package:tahsel_dashboard/core/services/injection_container.dart';
import 'package:tahsel_dashboard/core/utils/app_colors.dart';
import 'package:tahsel_dashboard/core/utils/app_strings.dart';
import 'package:tahsel_dashboard/core/utils/styles.dart';
import 'package:tahsel_dashboard/features/admin/domain/entities/app_user.dart';
import 'package:tahsel_dashboard/features/admin/domain/usecases/admin_usecases.dart';
import 'package:tahsel_dashboard/features/admin/presentation/cubit/user_detail/user_detail_cubit.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/currency_selection_bottom_sheet.dart';
import 'package:tahsel_dashboard/features/admin/presentation/widgets/status_badge.dart';
import 'package:tahsel_dashboard/shared/widgets/buttons/custom_button.dart';
import 'package:tahsel_dashboard/shared/widgets/custom_app_bar/custom_app_bar.dart';
import 'package:tahsel_dashboard/shared/widgets/fields/text_widget.dart';
import 'package:tahsel_dashboard/shared/widgets/text_fields/auth_custom_text_field.dart';
import 'package:tahsel_dashboard/shared/widgets/toast/custom_toast.dart';

class EditUserScreen extends StatefulWidget {
  final AppUser user;

  const EditUserScreen({super.key, required this.user});

  static Future<bool?> push(BuildContext context, {required AppUser user}) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<UserDetailCubit>(),
          child: EditUserScreen(user: user),
        ),
      ),
    );
  }

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _crnController;
  late final TextEditingController _vatController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _addressController;

  late String _userType;
  late String _platformType;
  late bool _isVip;
  late CurrencyEntity _selectedCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u.fullName);
    _projectNameController = TextEditingController(text: u.projectName);
    _emailController = TextEditingController(text: u.email);
    _phoneController = TextEditingController(text: u.phoneNumber);
    _crnController = TextEditingController(text: u.crn ?? '');
    _vatController = TextEditingController(text: u.vat ?? '');
    _taxRateController = TextEditingController(
      text: u.taxRate != null ? u.taxRate.toString() : '',
    );
    _addressController = TextEditingController(text: u.address ?? '');
    _userType = u.userType.isNotEmpty ? u.userType : 'cafe';
    _platformType = u.platformType.isNotEmpty ? u.platformType : 'mobile';
    _isVip = u.isVip;
    _selectedCurrency = WorldCurrencies.findByCode(u.currency);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _projectNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _crnController.dispose();
    _vatController.dispose();
    _taxRateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double? parsedTaxRate = _taxRateController.text.trim().isNotEmpty
          ? double.tryParse(_taxRateController.text.trim())
          : null;

      final updateUserUseCase = sl<UpdateUserUseCase>();
      final result = await updateUserUseCase(
        UpdateUserParams(
          uid: widget.user.uid,
          fullName: _nameController.text.trim(),
          projectName: _projectNameController.text.trim(),
          email: widget.user.email,
          phoneNumber: _phoneController.text.trim(),
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
          showSuccessToast('admin_user_updated'.tr());
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
        centerTitle: 'admin_edit_user'.tr(),
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
                    _buildBasicInfoSection(),
                    SizedBox(height: 16.h),
                    _buildPlatformAndTypeSection(),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.12),
            child: Text(
              widget.user.fullName.isNotEmpty
                  ? widget.user.fullName[0].toUpperCase()
                  : '؟',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextWidget(
                        widget.user.fullName,
                        style: TextStyles.font16WeightBoldText(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    StatusBadge(
                      statusKey: widget.user.accountStatus,
                      isEmployee: widget.user.isEmployee,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                TextWidget(
                  widget.user.email,
                  style: TextStyles.font14Weight400RightAligned().copyWith(
                    color: AppColors.subTitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                TextWidget(
                  '${'admin_uid'.tr()}: ${widget.user.uid}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.subTitleColor,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
          Divider(height: 24.h, color: AppColors.lightGreyColor),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildCardSection(
      title: 'admin_profile'.tr(),
      icon: Icons.person_outline_rounded,
      children: [
        AuthTextFormField(
          label: 'admin_full_name'.tr(),
          controller: _nameController,
          hintText: 'admin_full_name'.tr(),
          textInputType: TextInputType.name,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'admin_full_name'.tr() : null,
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: 'admin_project_name'.tr(),
          controller: _projectNameController,
          hintText: 'admin_project_name'.tr(),
          textInputType: TextInputType.text,
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: 'email_address'.tr(),
          controller: _emailController,
          hintText: 'email_address'.tr(),
          textInputType: TextInputType.emailAddress,
          enabled: false,
          suffixIcon: Icons.lock_outline_rounded,
          headerTrailingWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13.sp,
                color: AppColors.subTitleColor,
              ),
              SizedBox(width: 4.w),
              TextWidget(
                'غير قابل للتعديل',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subTitleColor,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.h, right: 4.w),
          child: TextWidget(
            'البريد الإلكتروني مرتبط بحساب المصادقة ولا يمكن تعديله لضمان أمان الحساب.',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.subTitleColor,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        AuthTextFormField(
          label: 'customer_phone'.tr(),
          controller: _phoneController,
          hintText: 'customer_phone'.tr(),
          textInputType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildPlatformAndTypeSection() {
    return _buildCardSection(
      title: 'admin_platform_type'.tr(),
      icon: Icons.devices_rounded,
      children: [
        TextWidget(
          'admin_user_type'.tr(),
          style: TextStyles.font14Weight400RightAligned().copyWith(
            color: AppColors.subTitleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'user_type_cafe'.tr(),
                icon: Icons.local_cafe_rounded,
                selected: _userType == 'cafe',
                onSelected: () => setState(() => _userType = 'cafe'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildChoiceChip(
                label: 'user_type_shop'.tr(),
                icon: Icons.storefront_rounded,
                selected: _userType == 'shop',
                onSelected: () => setState(() => _userType = 'shop'),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        TextWidget(
          'admin_platform_type'.tr(),
          style: TextStyles.font14Weight400RightAligned().copyWith(
            color: AppColors.subTitleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildChoiceChip(
                label: 'platform_type_mobile'.tr(),
                icon: Icons.phone_android_rounded,
                selected: _platformType == 'mobile',
                onSelected: () => setState(() => _platformType = 'mobile'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildChoiceChip(
                label: 'platform_type_desktop'.tr(),
                icon: Icons.computer_rounded,
                selected: _platformType == 'desktop',
                onSelected: () => setState(() => _platformType = 'desktop'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildChoiceChip(
                label: 'platform_type_both'.tr(),
                icon: Icons.devices_other_rounded,
                selected: _platformType == 'both',
                onSelected: () => setState(() => _platformType = 'both'),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: _isVip
                ? (AppColors.isDark
                    ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                    : const Color(0xFFFFD700).withValues(alpha: 0.12))
                : AppColors.scafoldBackGround,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _isVip
                  ? const Color(0xFFFFD700).withValues(alpha: AppColors.isDark ? 0.7 : 0.5)
                  : AppColors.lightGreyColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: _isVip
                      ? const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        )
                      : null,
                  color: _isVip ? null : AppColors.disabledColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: _isVip ? Colors.white : AppColors.sandText,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      'حساب مميز (VIP)',
                      style: TextStyles.font14Weight400RightAligned().copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isVip
                            ? (AppColors.isDark ? const Color(0xFFFFD700) : const Color(0xFFB8860B))
                            : AppColors.textColor,
                      ),
                    ),
                    TextWidget(
                      _isVip
                          ? 'الحساب يتمتع بمزايا الحساب المميز VIP'
                          : 'تفعيل الحساب كـ VIP لإتاحة مزايا الباقة المميزة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.subTitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isVip,
                activeTrackColor: const Color(0xFFFFD700).withValues(alpha: 0.5),
                activeThumbColor: const Color(0xFFFFD700),
                onChanged: (val) => setState(() => _isVip = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.scafoldBackGround,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor
                : AppColors.lightGreyColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: selected
                  ? AppColors.primaryColor
                  : AppColors.subTitleColor,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommercialAndTaxSection() {
    return _buildCardSection(
      title: 'بيانات المنشأة والنشاط التجاري والضريبي',
      icon: Icons.storefront_outlined,
      children: [
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
                textInputType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                      final selected =
                          await CurrencySelectionBottomSheet.show(
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
                          color: AppColors.lightGreyColor.withValues(alpha: 0.3),
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
                              _selectedCurrency
                                  .getName(AppStrings.currentLang),
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
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              _selectedCurrency
                                  .getSymbol(AppStrings.currentLang),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CustomButton(
            text: 'save_changes'.tr(),
            isLoading: _isLoading,
            height: 48.h,
            icon: Icons.check_circle_outline_rounded,
            onPressed: _handleSave,
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
