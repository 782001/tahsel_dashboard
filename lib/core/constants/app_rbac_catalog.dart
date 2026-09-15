class AppPermissionItem {
  final String key;
  final String titleAr;
  final String titleEn;

  const AppPermissionItem({
    required this.key,
    required this.titleAr,
    required this.titleEn,
  });
}

class AppPermissionGroup {
  final String id;
  final String titleAr;
  final String titleEn;
  final List<AppPermissionItem> items;

  const AppPermissionGroup({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.items,
  });
}

class AppRbacCatalog {
  AppRbacCatalog._();

  static const List<AppPermissionGroup> groups = [
    AppPermissionGroup(
      id: 'pos',
      titleAr: 'العمليات والبيع المباشر',
      titleEn: 'POS & Operations',
      items: [
        AppPermissionItem(key: 'pos.access', titleAr: 'فتح شاشة العمليات والبيع', titleEn: 'Access POS & Operations'),
        AppPermissionItem(key: 'pos.quick_sale', titleAr: 'البيع المباشر السريع', titleEn: 'Quick Shop Sale'),
        AppPermissionItem(key: 'pos.manage_sessions', titleAr: 'بدء وإدارة جلسات البلايستيشن/الكافيه', titleEn: 'Manage Cafe / PS Sessions'),
        AppPermissionItem(key: 'pos.add_debt', titleAr: 'تسجيل عملية كدين آجل', titleEn: 'Add Debt from POS'),
      ],
    ),
    AppPermissionGroup(
      id: 'invoices',
      titleAr: 'الفواتير والمبيعات',
      titleEn: 'Invoices & Sales',
      items: [
        AppPermissionItem(key: 'invoices.view', titleAr: 'استعراض الفواتير وعروض الأسعار', titleEn: 'View Invoices and quotes'),
        AppPermissionItem(key: 'invoices.create', titleAr: 'إنشاء فاتورة جديدة وعرض سعر', titleEn: 'Create Invoice and Quote'),
        AppPermissionItem(key: 'invoices.edit', titleAr: 'تعديل الفواتير وعروض الأسعار', titleEn: 'Edit Invoices and quotes'),
        AppPermissionItem(key: 'invoices.record_payment', titleAr: 'تسجيل وتحصيل دفعات الفاتورة', titleEn: 'Record Invoice Payment'),
        AppPermissionItem(key: 'invoices.delete', titleAr: 'إلغاء وحذف الفواتير وعروض الأسعار (حساس)', titleEn: 'Delete / Cancel Invoices and quotes (Sensitive)'),
        AppPermissionItem(key: 'invoices.print_share', titleAr: 'طباعة ومشاركة الفاتورة وعروض الأسعار PDF', titleEn: 'Print & Share Invoice and Quote PDF'),
      ],
    ),
    AppPermissionGroup(
      id: 'expenses',
      titleAr: 'المصروفات',
      titleEn: 'Expenses',
      items: [
        AppPermissionItem(key: 'expenses.view', titleAr: 'استعراض المصروفات', titleEn: 'View Expenses'),
        AppPermissionItem(key: 'expenses.add', titleAr: 'تسجيل وإضافة مصروف', titleEn: 'Add Expense'),
        AppPermissionItem(key: 'expenses.delete', titleAr: 'حذف المصروفات (حساس)', titleEn: 'Delete Expenses (Sensitive)'),
      ],
    ),
    AppPermissionGroup(
      id: 'customers',
      titleAr: 'إدارة العملاء والديون',
      titleEn: 'Customers & Debts',
      items: [
        AppPermissionItem(key: 'customers.view', titleAr: 'استعراض قائمة العملاء', titleEn: 'View Customers List'),
        AppPermissionItem(key: 'customers.add', titleAr: 'إضافة وتعديل عميل', titleEn: 'Add & Edit Customer'),
        AppPermissionItem(key: 'customers.settle_debt', titleAr: 'تسجيل سداد دين عميل', titleEn: 'Settle Customer Debt'),
        AppPermissionItem(key: 'customers.delete_debt', titleAr: 'حذف او تعديل الديون وسجلات الدفع (حساس)', titleEn: 'Delete or Edit Debts and Payment Records (Sensitive)'),
        AppPermissionItem(key: 'customers.send_whatsapp', titleAr: 'إرسال مطالبة بالدين عبر الواتساب', titleEn: 'Send WhatsApp Statements'),
        AppPermissionItem(key: 'customers.view_reports', titleAr: 'استعراض كشف الحساب والتقارير', titleEn: 'View Customer Statement & Reports'),
      ],
    ),
    AppPermissionGroup(
      id: 'my_debts',
      titleAr: 'ديوني والالتزامات',
      titleEn: 'My Debts & Liabilities',
      items: [
        AppPermissionItem(key: 'my_debts.view', titleAr: 'استعراض ديوني والالتزامات', titleEn: 'View my Debts & Liabilities'),
        AppPermissionItem(key: 'my_debts.add', titleAr: 'إضافة والتزام دين عليا جديد', titleEn: 'Add my Debt'),
        AppPermissionItem(key: 'my_debts.pay', titleAr: 'تسجيل دفعات سداد عليا', titleEn: 'Pay my Debt'),
        AppPermissionItem(key: 'my_debts.delete', titleAr: 'حذف او تعديل ديوني وسجلات الدفع (حساس)', titleEn: 'Delete or Edit My Debts and Payment Records (Sensitive)'),
      ],
    ),
    AppPermissionGroup(
      id: 'vault',
      titleAr: 'الخزينة والصندوق النقدي',
      titleEn: 'Cashbox & Vault',
      items: [
        AppPermissionItem(key: 'vault.access', titleAr: 'الوصول للخزينة والصندوق النقدي', titleEn: 'Access Vault & Cashbox'),
        AppPermissionItem(key: 'vault.view_balance', titleAr: 'رؤية رصيد الخزينة الحالي (سري)', titleEn: 'View Current Vault Balance (Confidential)'),
        AppPermissionItem(key: 'vault.deposit', titleAr: 'إيداع نقدي يدوي في الخزينة', titleEn: 'Manual Vault Deposit'),
        AppPermissionItem(key: 'vault.withdraw', titleAr: 'سحب نقدي يدوي من الخزينة', titleEn: 'Manual Vault Withdrawal'),
        AppPermissionItem(key: 'vault.view_history', titleAr: 'استعراض سجل حركات الخزينة', titleEn: 'View Vault Transaction History'),
      ],
    ),
    AppPermissionGroup(
      id: 'inventory',
      titleAr: 'المخزون والمنتجات والمشتريات',
      titleEn: 'Inventory & Stock',
      items: [
        AppPermissionItem(key: 'inventory.view', titleAr: 'استعراض المخزون والمنتجات', titleEn: 'View Products & Stock'),
        AppPermissionItem(key: 'inventory.manage_products', titleAr: 'إضافة وتعديل وحذف المنتجات والأسعار', titleEn: 'Manage Products & Prices'),
        AppPermissionItem(key: 'inventory.manage_suppliers', titleAr: 'إدارة الموردين', titleEn: 'Manage Suppliers'),
        AppPermissionItem(key: 'inventory.manage_purchases', titleAr: 'تسجيل فواتير الشراء والتوريد', titleEn: 'Manage Purchases'),
        AppPermissionItem(key: 'inventory.stock_adjustments', titleAr: 'تسوية عجز وهالك وجرد المخزون', titleEn: 'Stock Adjustments & Loss'),
        AppPermissionItem(key: 'inventory.view_analytics', titleAr: 'استعراض تحليلات المخزون والأرباح', titleEn: 'View Inventory Analytics'),
      ],
    ),
    AppPermissionGroup(
      id: 'employees',
      titleAr: 'إدارة شؤون الموظفين (HR)',
      titleEn: 'HR & Employee Management',
      items: [
        AppPermissionItem(key: 'employees.view', titleAr:"استعراض سجل الموظفين واضافة وتعديل موظف", titleEn: 'View Employee Records add & edit employee'),
        AppPermissionItem(key: 'employees.record_attendance', titleAr: 'تسجيل الحضور والانصراف', titleEn: 'Record Attendance'),
        AppPermissionItem(key: 'employees.manage_payroll', titleAr: 'صرف الرواتب والسلفيات', titleEn: 'Manage Payroll & Advances'),
        // AppPermissionItem(key: 'employees.manage_app_users', titleAr: 'إدارة موظفي التطبيق وصلاحياتهم (مدير)', titleEn: 'Manage App Users & Permissions'),
      ],
    ),
    AppPermissionGroup(
      id: 'reports',
      titleAr: 'التقارير المالية والأرباح',
      titleEn: 'Financial Reports & Insights',
      items: [
        AppPermissionItem(key: 'reports.view_net_profit', titleAr: 'رؤية صافي الأرباح وهوامش الربح (سرية)', titleEn: 'View Net Profit & Margins (Confidential)'),
        AppPermissionItem(key: 'reports.view_sales', titleAr: 'استعراض تقارير المبيعات والإيرادات وحصلت كام', titleEn: 'View Sales Reports and What You Collected'),
        AppPermissionItem(key: 'reports.view_tax', titleAr: 'استعراض تقارير الضرائب والقيمة المضافة', titleEn: 'View Tax & VAT Reports'),
        AppPermissionItem(key: 'reports.export', titleAr: 'تصدير التقارير Excel و PDF', titleEn: 'Export Reports Excel & PDF'),
      ],
    ),
    AppPermissionGroup(
      id: 'shipping',
      titleAr: 'مطابقة الشحن',
      titleEn: 'Shipping Reconciliation',
      items: [
        AppPermissionItem(key: 'shipping.view', titleAr: 'رفع ومطابقة كشوف شركات الشحن', titleEn: 'Shipping Reconciliation'),
      ],
    ),
    AppPermissionGroup(
      id: 'settings',
      titleAr: 'إعدادات المنشأة والنظام',
      titleEn: 'Store Settings',
      items: [
        AppPermissionItem(key: 'settings.edit_profile', titleAr: 'تعديل بيانات المنشأة وطرق الطباعة', titleEn: 'Edit Business'),
        AppPermissionItem(key: 'settings.manage_subscription', titleAr: 'الاطلاع على الباقة والاشتراك', titleEn: 'View Subscription'),
        AppPermissionItem(key: 'settings.delete_account', titleAr: 'طلب حذف الحساب والبيانات', titleEn: 'Delete Account'),
      ],
    ),
  ];

  static int get totalPermissions =>
      groups.fold<int>(0, (sum, group) => sum + group.items.length);
}
