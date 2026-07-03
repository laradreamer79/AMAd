import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import 'add_bill_screen.dart';
import 'bill.dart';
import 'bill_payment_details_screen.dart';
import 'providers/bills_provider.dart';

class BillsFlowScreen extends StatelessWidget {
  const BillsFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BillsScreen());
  }
}

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  void _openBill(BuildContext context, Bill bill) {
    Navigator.push(
      context,
      AppPageRoute(builder: (_) => BillPaymentDetailsScreen(bill: bill)),
    );
  }

  void _showBillActions(BuildContext context, Bill bill, LangProvider lang) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.name, style: AppTextStyles.stepTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(bill.biller, style: AppTextStyles.label),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.payments_outlined, color: AppColors.primary),
                  title: Text(lang.t('pay_now'), style: AppTextStyles.value),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openBill(context, bill);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                  title: Text(lang.t('manage_bill'), style: AppTextStyles.value),
                  subtitle: Text(lang.t('manage_bill_desc'), style: AppTextStyles.label),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${lang.t('manage_bill')}: ${bill.name}')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final bills = context.watch<BillsProvider>().bills;

    return Directionality(
      textDirection: lang.direction,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            AppHeader(titleKey: 'bills'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('pay_bills_title'), style: AppTextStyles.stepTitle),
                      const SizedBox(height: 6),
                      Text(lang.t('pay_bills_subtitle'), style: AppTextStyles.stepSubtitle),
                      const SizedBox(height: 22),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.35,
                        children: BillCategory.values
                            .map((category) => _BillCategoryCard(category: category))
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(lang.t('bills'), style: AppTextStyles.sectionTitle),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                AppPageRoute(builder: (_) => const AllBillsScreen()),
                              );
                            },
                            child: Text(
                              lang.t('show_all'),
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (bills.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(lang.t('no_bills_yet'), style: AppTextStyles.label),
                          ),
                        )
                      else
                        ...bills.take(3).map(
                              (bill) => _BillTile(
                                bill: bill,
                                onTap: () => _showBillActions(context, bill, lang),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllBillsScreen extends StatelessWidget {
  const AllBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final bills = context.watch<BillsProvider>().bills;

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'all_bills'),
            Expanded(
              child: SafeArea(
                top: false,
                child: bills.isEmpty
                    ? Center(
                        child: Text(lang.t('no_bills_yet'), style: AppTextStyles.label),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: bills.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final bill = bills[index];
                          return _BillTile(
                            bill: bill,
                            onTap: () => Navigator.push(
                              context,
                              AppPageRoute(
                                builder: (_) => BillPaymentDetailsScreen(bill: bill),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillCategoryCard extends StatelessWidget {
  final BillCategory category;

  const _BillCategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (category == BillCategory.newBill) {
          Navigator.push(
            context,
            AppPageRoute(builder: (_) => const AddBillScreen()),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${category.title} selected')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.cardGradient,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.shadowRaised1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: AppColors.primary, size: 22),
            ),
            Text(category.title, style: AppTextStyles.value.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  final Bill bill;
  final VoidCallback onTap;

  const _BillTile({required this.bill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.shadowRaised1,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(bill.category.icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.name, style: AppTextStyles.value),
                    const SizedBox(height: 4),
                    Text(
                      bill.biller,
                      style: AppTextStyles.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(bill.amount, style: AppTextStyles.value),
                  const SizedBox(height: 4),
                  Text(
                    bill.dueDate,
                    style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
