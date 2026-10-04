/// App permissions catalog and role presets matching the Tahsel application RBAC system.
class PermissionItem {
  final String key;
  final String titleAr;
  final String titleEn;

  const PermissionItem(this.key, this.titleAr, [this.titleEn = '']);
}

class PermissionGroup {
  final String id;
  final String titleAr;
  final String titleEn;
  final List<PermissionItem> items;

  const PermissionGroup({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.items,
  });
}

class AppPermissions {
  AppPermissions._();

  // Wildcard for full super-access (Owner default)
  static const String all = '*';

  // ── 1. POS & Operations ──────────────────────────────────────────
  static const String posAccess = 'pos.access';
  static const String posQuickSale = 'pos.quick_sale';
  static const String posManageSessions = 'pos.manage_sessions';
  static const String posAddDebt = 'pos.add_debt';

  // ── 2. Invoices & Sales ───────────────────────────────────────────
  static const String invoicesView = 'invoices.view';
  static const String invoicesCreate = 'invoices.create';
  static const String invoicesEdit = 'invoices.edit';
  static const String invoicesRecordPayment = 'invoices.record_payment';
  static const String invoicesDelete = 'invoices.delete';
  static const String invoicesPrintShare = 'invoices.print_share';

  // ── 3. Expenses ───────────────────────────────────────────────────
  static const String expensesView = 'expenses.view';
  static const String expensesAdd = 'expenses.add';
  static const String expensesDelete = 'expenses.delete';

  // ── 4. Customers & Customer Debts ─────────────────────────────────
  static const String customersView = 'customers.view';
  static const String customersViewPhone = 'customers.view_phone';
  static const String customersAdd = 'customers.add';
  static const String customersSettleDebt = 'customers.settle_debt';
  static const String customersDeleteDebt = 'customers.delete_debt';
  static const String customersSendWhatsapp = 'customers.send_whatsapp';
  static const String customersViewReports = 'customers.view_reports';
  static const String customersPrintShare = 'customers.print_share';

  // ── 5. My Debts (Supplier Liabilities) ────────────────────────────
  static const String myDebtsView = 'my_debts.view';
  static const String myDebtsAdd = 'my_debts.add';
  static const String myDebtsPay = 'my_debts.pay';
  static const String myDebtsDelete = 'my_debts.delete';

  // ── 6. Vault & Cash Register ──────────────────────────────────────
  static const String vaultAccess = 'vault.access';
  static const String vaultViewBalance = 'vault.view_balance';
  static const String vaultDeposit = 'vault.deposit';
  static const String vaultWithdraw = 'vault.withdraw';
  static const String vaultViewHistory = 'vault.view_history';

  // ── 7. Inventory Management ───────────────────────────────────────
  static const String inventoryView = 'inventory.view';
  static const String inventoryManageProducts = 'inventory.manage_products';
  static const String inventoryManageSuppliers = 'inventory.manage_suppliers';
  static const String inventoryManagePurchases = 'inventory.manage_purchases';
  static const String inventoryStockAdjustments = 'inventory.stock_adjustments';
  static const String inventoryViewAnalytics = 'inventory.view_analytics';

  // ── 8. HR & Employee Management ───────────────────────────────────
  static const String employeesView = 'employees.view';
  static const String employeesRecordAttendance = 'employees.record_attendance';
  static const String employeesManagePayroll = 'employees.manage_payroll';
  static const String employeesManageAppUsers = 'employees.manage_app_users';

  // ── 9. Reports & Financial Insights ───────────────────────────────
  static const String reportsViewNetProfit = 'reports.view_net_profit';
  static const String reportsViewSales = 'reports.view_sales';
  static const String reportsExport = 'reports.export';

  // ── 10. Shipping Reconciliation ───────────────────────────────────
  static const String shippingView = 'shipping.view';

  // ── 11. Settings & Business ───────────────────────────────────────
  static const String settingsEditProfile = 'settings.edit_profile';

  // ── Group IDs ─────────────────────────────────────────────────────
  static const String groupPos = 'pos';
  static const String groupInvoices = 'invoices';
  static const String groupExpenses = 'expenses';
  static const String groupCustomers = 'customers';
  static const String groupMyDebts = 'my_debts';
  static const String groupVault = 'vault';
  static const String groupInventory = 'inventory';
  static const String groupEmployees = 'employees';
  static const String groupReports = 'reports';
  static const String groupShipping = 'shipping';
  static const String groupSettings = 'settings';

  // ── Role Presets ──────────────────────────────────────────────────
  static const String roleCashier = 'cashier';
  static const String roleStorekeeper = 'storekeeper';
  static const String roleAccountant = 'accountant';
  static const String roleSupervisor = 'supervisor';
  static const String roleCustom = 'custom';

  /// All permission groups with full titles in Arabic and English
  static const List<PermissionGroup> allGroups = [
    PermissionGroup(
      id: groupPos,
      titleAr: 'العمليات والبيع المباشر',
      titleEn: 'POS & Operations',
      items: [
        PermissionItem(posAccess, 'فتح شاشة العمليات والبيع', 'Access POS & Operations'),
        PermissionItem(posQuickSale, 'البيع المباشر السريع', 'Quick Shop Sale'),
        PermissionItem(posManageSessions, 'بدء وإدارة جلسات البلايستيشن/الكافيه', 'Manage Cafe / PS Sessions'),
        PermissionItem(posAddDebt, 'تسجيل عملية كدين آجل', 'Add Debt from POS'),
      ],
    ),
    PermissionGroup(
      id: groupInvoices,
      titleAr: 'الفواتير والمبيعات',
      titleEn: 'Invoices & Sales',
      items: [
        PermissionItem(invoicesView, 'استعراض الفواتير وعروض الأسعار', 'View Invoices & Quotes'),
        PermissionItem(invoicesCreate, 'إنشاء فاتورة جديدة وعرض سعر', 'Create Invoice & Quote'),
        PermissionItem(invoicesEdit, 'تعديل الفواتير وعروض الأسعار', 'Edit Invoices & Quotes'),
        PermissionItem(invoicesRecordPayment, 'تسجيل وتحصيل دفعات الفاتورة', 'Record Invoice Payment'),
        PermissionItem(invoicesDelete, 'إلغاء وحذف الفواتير وعروض الأسعار (حساس)', 'Delete Invoices (Sensitive)'),
        PermissionItem(invoicesPrintShare, 'طباعة ومشاركة الفاتورة وعروض الأسعار PDF', 'Print & Share Invoice PDF'),
      ],
    ),
    PermissionGroup(
      id: groupExpenses,
      titleAr: 'المصروفات',
      titleEn: 'Expenses',
      items: [
        PermissionItem(expensesView, 'استعراض المصروفات', 'View Expenses'),
        PermissionItem(expensesAdd, 'تسجيل وإضافة مصروف', 'Add Expense'),
        PermissionItem(expensesDelete, 'حذف المصروفات (حساس)', 'Delete Expenses (Sensitive)'),
      ],
    ),
    PermissionGroup(
      id: groupCustomers,
      titleAr: 'إدارة العملاء والديون',
      titleEn: 'Customers & Debts',
      items: [
        PermissionItem(customersView, 'استعراض قائمة العملاء', 'View Customers List'),
        PermissionItem(customersViewPhone, 'رؤية رقم هاتف العميل والتواصل', 'View Customer Phone & Contact'),
        PermissionItem(customersAdd, 'إضافة وتعديل عميل', 'Add & Edit Customer'),
        PermissionItem(customersSettleDebt, 'تسجيل سداد دين عميل', 'Settle Customer Debt'),
        PermissionItem(customersDeleteDebt, 'حذف أو تعديل الديون وسجلات الدفع (حساس)', 'Delete/Edit Debts (Sensitive)'),
        PermissionItem(customersSendWhatsapp, 'إرسال مطالبة بالدين عبر الواتساب', 'Send WhatsApp Statements'),
        PermissionItem(customersViewReports, 'استعراض كشف الحساب والتقارير', 'View Customer Statement & Reports'),
        PermissionItem(customersPrintShare, 'طباعة ومشاركة كشف الحساب PDF', 'Print & Share Customer Statement'),
      ],
    ),
    PermissionGroup(
      id: groupMyDebts,
      titleAr: 'ديوني والالتزامات',
      titleEn: 'My Debts & Liabilities',
      items: [
        PermissionItem(myDebtsView, 'استعراض ديوني والالتزامات', 'View My Debts & Liabilities'),
        PermissionItem(myDebtsAdd, 'إضافة التزام دين عليا جديد', 'Add My Debt'),
        PermissionItem(myDebtsPay, 'تسجيل دفعات سداد عليا', 'Pay My Debt'),
        PermissionItem(myDebtsDelete, 'حذف أو تعديل ديوني وسجلات الدفع (حساس)', 'Delete/Edit My Debts (Sensitive)'),
      ],
    ),
    PermissionGroup(
      id: groupVault,
      titleAr: 'الخزينة والصندوق النقدي',
      titleEn: 'Cashbox & Vault',
      items: [
        PermissionItem(vaultAccess, 'الوصول للخزينة والصندوق النقدي', 'Access Vault & Cashbox'),
        PermissionItem(vaultViewBalance, 'رؤية رصيد الخزينة الحالي (سري)', 'View Current Vault Balance (Confidential)'),
        PermissionItem(vaultDeposit, 'إيداع نقدي يدوي في الخزينة', 'Manual Vault Deposit'),
        PermissionItem(vaultWithdraw, 'سحب نقدي يدوي من الخزينة', 'Manual Vault Withdrawal'),
        PermissionItem(vaultViewHistory, 'استعراض سجل حركات الخزينة', 'View Vault Transaction History'),
      ],
    ),
    PermissionGroup(
      id: groupInventory,
      titleAr: 'المخزون والمنتجات والمشتريات',
      titleEn: 'Inventory & Stock',
      items: [
        PermissionItem(inventoryView, 'استعراض المخزون والمنتجات', 'View Products & Stock'),
        PermissionItem(inventoryManageProducts, 'إضافة وتعديل وحذف المنتجات والأسعار', 'Manage Products & Prices'),
        PermissionItem(inventoryManageSuppliers, 'إدارة الموردين', 'Manage Suppliers'),
        PermissionItem(inventoryManagePurchases, 'تسجيل فواتير الشراء والتوريد', 'Manage Purchases'),
        PermissionItem(inventoryStockAdjustments, 'تسوية عجز وهالك وجرد المخزون', 'Stock Adjustments & Loss'),
        PermissionItem(inventoryViewAnalytics, 'استعراض تحليلات المخزون والأرباح', 'View Inventory Analytics'),
      ],
    ),
    PermissionGroup(
      id: groupEmployees,
      titleAr: 'إدارة شؤون الموظفين (HR)',
      titleEn: 'HR & Employee Management',
      items: [
        PermissionItem(employeesView, 'استعراض سجل الموظفين وإضافة وتعديل موظف', 'View Employee Records'),
        PermissionItem(employeesRecordAttendance, 'تسجيل الحضور والانصراف', 'Record Attendance'),
        PermissionItem(employeesManagePayroll, 'صرف الرواتب والسلفيات', 'Manage Payroll & Advances'),
      ],
    ),
    PermissionGroup(
      id: groupReports,
      titleAr: 'التقارير المالية والأرباح',
      titleEn: 'Financial Reports & Insights',
      items: [
        PermissionItem(reportsViewSales, 'استعراض تقارير المبيعات والإيرادات', 'View Sales Reports & Revenue'),
        PermissionItem(reportsViewNetProfit, 'رؤية صافي الأرباح وهوامش الربح (سرية)', 'View Net Profit & Margins (Confidential)'),
        PermissionItem(reportsExport, 'تصدير التقارير Excel و PDF', 'Export Reports Excel & PDF'),
      ],
    ),
    PermissionGroup(
      id: groupShipping,
      titleAr: 'مطابقة الشحن',
      titleEn: 'Shipping Reconciliation',
      items: [
        PermissionItem(shippingView, 'رفع ومطابقة كشوف شركات الشحن', 'Shipping Reconciliation'),
      ],
    ),
    PermissionGroup(
      id: groupSettings,
      titleAr: 'إعدادات المنشأة والنظام',
      titleEn: 'Store Settings',
      items: [
        PermissionItem(settingsEditProfile, 'تعديل بيانات المنشأة وطرق الطباعة', 'Edit Business & Print Settings'),
      ],
    ),
  ];

  static int get totalPermissions =>
      allGroups.fold<int>(0, (sum, group) => sum + group.items.length);

  /// Mapping of action/sub-permissions to their mandatory prerequisite permissions.
  static const Map<String, List<String>> permissionDependencies = {
    // POS
    posQuickSale: [posAccess],
    posManageSessions: [posAccess],
    posAddDebt: [posAccess, customersView],

    // Invoices
    invoicesCreate: [invoicesView],
    invoicesEdit: [invoicesView],
    invoicesRecordPayment: [invoicesView],
    invoicesDelete: [invoicesView],
    invoicesPrintShare: [invoicesView],

    // Expenses
    expensesAdd: [expensesView],
    expensesDelete: [expensesView],

    // Customers
    customersViewPhone: [customersView],
    customersAdd: [customersView],
    customersSettleDebt: [customersView],
    customersDeleteDebt: [customersView],
    customersSendWhatsapp: [customersView, customersViewPhone],
    customersViewReports: [customersView],
    customersPrintShare: [customersView, customersViewReports],

    // My Debts
    myDebtsAdd: [myDebtsView],
    myDebtsPay: [myDebtsView],
    myDebtsDelete: [myDebtsView],

    // Vault
    vaultViewBalance: [vaultAccess],
    vaultDeposit: [vaultAccess],
    vaultWithdraw: [vaultAccess],
    vaultViewHistory: [vaultAccess],

    // Inventory
    inventoryManageProducts: [inventoryView],
    inventoryManageSuppliers: [inventoryView],
    inventoryManagePurchases: [inventoryView],
    inventoryStockAdjustments: [inventoryView],
    inventoryViewAnalytics: [inventoryView],

    // Employees / HR
    employeesRecordAttendance: [employeesView],
    employeesManagePayroll: [employeesView],

    // Reports
    reportsViewNetProfit: [reportsViewSales],
    reportsExport: [reportsViewSales],
  };

  /// Returns permission groups filtered for the specific business type (Shop vs Cafe).
  static List<PermissionGroup> getGroupsForBusinessType({bool isShop = true}) {
    final List<PermissionGroup> result = [];

    for (final group in allGroups) {
      // 1. Shop-only groups: excluded for cafe accounts
      if (!isShop &&
          (group.id == groupInvoices ||
              group.id == groupVault ||
              group.id == groupInventory ||
              group.id == groupShipping)) {
        continue;
      }

      // 2. Filter items within each group
      final filteredItems = group.items.where((item) {
        // PS / Cafe session management is cafe-only (excluded for shop)
        if (isShop && item.key == posManageSessions) {
          return false;
        }
        return true;
      }).toList();

      if (filteredItems.isNotEmpty) {
        result.add(
          PermissionGroup(
            id: group.id,
            titleAr: group.titleAr,
            titleEn: group.titleEn,
            items: filteredItems,
          ),
        );
      }
    }

    return result;
  }

  /// Returns permissions list for a predefined role preset, filtered for business type.
  static List<String> permissionsForPreset(String preset, {bool isShop = true}) {
    List<String> raw;
    switch (preset) {
      case roleCashier:
        raw = [
          posAccess,
          posQuickSale,
          posManageSessions,
          posAddDebt,
          invoicesView,
          invoicesCreate,
          invoicesRecordPayment,
          invoicesPrintShare,
          customersView,
          customersAdd,
          customersSettleDebt,
          inventoryView,
        ];
        break;
      case roleStorekeeper:
        raw = [
          inventoryView,
          inventoryManageProducts,
          inventoryManageSuppliers,
          inventoryManagePurchases,
          inventoryStockAdjustments,
          myDebtsView,
          myDebtsAdd,
        ];
        break;
      case roleAccountant:
        raw = [
          invoicesView,
          invoicesCreate,
          invoicesEdit,
          invoicesRecordPayment,
          invoicesPrintShare,
          expensesView,
          expensesAdd,
          customersView,
          customersViewPhone,
          customersAdd,
          customersSettleDebt,
          customersViewReports,
          customersPrintShare,
          myDebtsView,
          myDebtsAdd,
          myDebtsPay,
          vaultAccess,
          vaultViewBalance,
          vaultDeposit,
          vaultWithdraw,
          vaultViewHistory,
          reportsViewSales,
          reportsExport,
          shippingView,
        ];
        break;
      case roleSupervisor:
        raw = [
          posAccess,
          posQuickSale,
          posManageSessions,
          posAddDebt,
          invoicesView,
          invoicesCreate,
          invoicesEdit,
          invoicesRecordPayment,
          invoicesDelete,
          invoicesPrintShare,
          expensesView,
          expensesAdd,
          customersView,
          customersViewPhone,
          customersAdd,
          customersSettleDebt,
          customersDeleteDebt,
          customersSendWhatsapp,
          customersViewReports,
          customersPrintShare,
          myDebtsView,
          myDebtsAdd,
          myDebtsPay,
          vaultAccess,
          vaultViewBalance,
          vaultDeposit,
          vaultWithdraw,
          vaultViewHistory,
          inventoryView,
          inventoryManageProducts,
          inventoryManageSuppliers,
          inventoryManagePurchases,
          inventoryStockAdjustments,
          employeesView,
          employeesRecordAttendance,
          shippingView,
        ];
        break;
      default:
        return [];
    }

    final allowedKeys = getGroupsForBusinessType(isShop: isShop)
        .expand((g) => g.items.map((i) => i.key))
        .toSet();

    return raw.where((p) => allowedKeys.contains(p)).toList();
  }

  /// Returns all direct and indirect prerequisites required by [permission].
  static Set<String> getPrerequisites(String permission) {
    final result = <String>{};
    void addReqs(String p) {
      final reqs = permissionDependencies[p];
      if (reqs != null) {
        for (final req in reqs) {
          if (result.add(req)) {
            addReqs(req);
          }
        }
      }
    }
    addReqs(permission);
    return result;
  }

  /// Returns all permissions that directly or indirectly depend on [permission].
  static Set<String> getDependents(String permission) {
    final result = <String>{};
    void addDeps(String p) {
      for (final entry in permissionDependencies.entries) {
        if (entry.value.contains(p)) {
          if (result.add(entry.key)) {
            addDeps(entry.key);
          }
        }
      }
    }
    addDeps(permission);
    return result;
  }

  /// Resolves an iterable of permissions by including all their prerequisites.
  static Set<String> resolveDependencies(Iterable<String> permissions) {
    final resolved = Set<String>.from(permissions);
    for (final perm in permissions) {
      resolved.addAll(getPrerequisites(perm));
    }
    return resolved;
  }

  /// Checks if [permission] has any prerequisite dependencies.
  static bool hasPrerequisites(String permission) =>
      permissionDependencies.containsKey(permission) &&
      permissionDependencies[permission]!.isNotEmpty;

  /// Returns the localized label for a permission by [key].
  static String getPermissionLabel(String key, {bool isArabic = true}) {
    for (final group in allGroups) {
      for (final item in group.items) {
        if (item.key == key) return isArabic ? item.titleAr : item.titleEn;
      }
    }
    return key;
  }

  /// Returns a comma-separated localized string of prerequisite labels for [permission].
  static String getPrerequisiteLabels(String permission, {bool isArabic = true}) {
    final reqs = permissionDependencies[permission];
    if (reqs == null || reqs.isEmpty) return '';
    return reqs.map((k) => getPermissionLabel(k, isArabic: isArabic)).join('، ');
  }

  /// Role label in Arabic
  static String getRoleLabel(String preset) {
    switch (preset) {
      case roleCashier:
        return 'كاشير (نقطة البيع)';
      case roleStorekeeper:
        return 'أمين مخزن ومشتريات';
      case roleAccountant:
        return 'محاسب مالي';
      case roleSupervisor:
        return 'مشرف عام للعمليات';
      case roleCustom:
        return 'مخصص';
      default:
        return preset;
    }
  }
}
