import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import 'offer_details_screen.dart';
import 'product_details_screen.dart';

class BankProduct {
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final IconData icon;
  final List<Color> gradient;
  final String badge;
  final Color badgeColor;
  final String category; // 'financing' | 'savings' | 'insurance'

  const BankProduct({
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.icon,
    required this.gradient,
    required this.badge,
    required this.badgeColor,
    required this.category,
  });
}

const _products = [
  BankProduct(
    titleEn: 'Personal Finance',
    titleAr: 'التمويل الشخصي',
    descEn: 'Up to 500,000 SAR • 5 years',
    descAr: 'حتى ٥٠٠,٠٠٠ ر.س • ٥ سنوات',
    icon: Icons.account_balance_wallet,
    gradient: [Color(0xFF1A1060), Color(0xFF3D2B9E)],
    badge: 'Popular',
    badgeColor: AppColors.primary,
    category: 'financing',
  ),
  BankProduct(
    titleEn: 'Home Finance',
    titleAr: 'تمويل المسكن',
    descEn: 'Up to 3,000,000 SAR • 30 years',
    descAr: 'حتى ٣,٠٠٠,٠٠٠ ر.س • ٣٠ سنة',
    icon: Icons.home_work_outlined,
    gradient: [Color(0xFF0F3D2E), Color(0xFF1A6B50)],
    badge: 'New',
    badgeColor: AppColors.success,
    category: 'financing',
  ),
  BankProduct(
    titleEn: 'Auto Finance',
    titleAr: 'تمويل السيارات',
    descEn: 'Up to 200,000 SAR • 5 years',
    descAr: 'حتى ٢٠٠,٠٠٠ ر.س • ٥ سنوات',
    icon: Icons.directions_car_outlined,
    gradient: [Color(0xFF2C1810), Color(0xFF8B4513)],
    badge: '0% Profit',
    badgeColor: AppColors.gold,
    category: 'financing',
  ),
  BankProduct(
    titleEn: 'Saving Certificate',
    titleAr: 'شهادة الادخار',
    descEn: 'Up to 5.5% annual return',
    descAr: 'عائد سنوي حتى ٥.٥٪',
    icon: Icons.savings_outlined,
    gradient: [Color(0xFF1C1A00), Color(0xFF5C5200)],
    badge: 'Best Return',
    badgeColor: AppColors.gold,
    category: 'savings',
  ),
  BankProduct(
    titleEn: 'Investment Portfolio',
    titleAr: 'المحفظة الاستثمارية',
    descEn: 'Diversified Shariah-compliant funds',
    descAr: 'صناديق متنوعة متوافقة مع الشريعة',
    icon: Icons.trending_up,
    gradient: [Color(0xFF0A1F3D), Color(0xFF1A4080)],
    badge: 'Recommended',
    badgeColor: AppColors.primary,
    category: 'savings',
  ),
  BankProduct(
    titleEn: 'Travel Insurance',
    titleAr: 'تأمين السفر',
    descEn: 'Full coverage • 180 countries',
    descAr: 'تغطية كاملة • ١٨٠ دولة',
    icon: Icons.flight_outlined,
    gradient: [Color(0xFF1A0A2E), Color(0xFF4A1A6E)],
    badge: 'Exclusive',
    badgeColor: AppColors.primary,
    category: 'insurance',
  ),
];

class OfferItem {
  final String titleEn;
  final String titleAr;
  final String partnerEn;
  final String partnerAr;
  final String validUntil;
  final IconData icon;

  const OfferItem({
    required this.titleEn,
    required this.titleAr,
    required this.partnerEn,
    required this.partnerAr,
    required this.validUntil,
    required this.icon,
  });
}

const _offers = [
  OfferItem(
    titleEn: '0% installments on electronics',
    titleAr: 'تقسيط ٠٪ على الإلكترونيات',
    partnerEn: 'Extra Stores',
    partnerAr: 'إكسترا',
    validUntil: '31 Jul 2026',
    icon: Icons.devices_outlined,
  ),
  OfferItem(
    titleEn: '20% cashback on dining',
    titleAr: '٢٠٪ استرداد نقدي على المطاعم',
    partnerEn: 'Selected Restaurants',
    partnerAr: 'مطاعم مختارة',
    validUntil: '15 Aug 2026',
    icon: Icons.restaurant_outlined,
  ),
  OfferItem(
    titleEn: 'Free airport lounge access',
    titleAr: 'دخول مجاني لصالات المطار',
    partnerEn: 'All Airports',
    partnerAr: 'جميع المطارات',
    validUntil: '31 Dec 2026',
    icon: Icons.airline_seat_recline_extra_outlined,
  ),
];

const _offerAccents = [AppColors.primary, AppColors.gold, AppColors.success];

const _categories = [
  {'key': 'all', 'en': 'All', 'ar': 'الكل'},
  {'key': 'financing', 'en': 'Financing', 'ar': 'تمويل'},
  {'key': 'savings', 'en': 'Savings & Investment', 'ar': 'ادخار واستثمار'},
  {'key': 'insurance', 'en': 'Insurance', 'ar': 'تأمين'},
];

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final filtered = _selectedCategory == 'all'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Directionality(
      textDirection: lang.direction,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            AppHeader(titleKey: 'products'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroBanner(lang: lang),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            lang.isRTL ? 'منتجات البنك' : 'Bank Products',
                            style: AppTextStyles.sectionTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final c = _categories[i];
                            final selected = _selectedCategory == c['key'];
                            return _CategoryChip(
                              label: lang.isRTL ? c['ar']! : c['en']!,
                              selected: selected,
                              onTap: () =>
                                  setState(() => _selectedCategory = c['key']!),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(filtered.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ProductCard(product: filtered[i], lang: lang),
                        );
                      }),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Text(
                              lang.isRTL
                                  ? 'لا توجد منتجات في هذه الفئة'
                                  : 'No products in this category',
                              style: AppTextStyles.label,
                            ),
                          ),
                        ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            lang.isRTL ? 'العروض الحصرية' : 'Exclusive Offers',
                            style: AppTextStyles.sectionTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_offers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _OfferCard(
                            offer: _offers[i],
                            lang: lang,
                            accent: _offerAccents[i % _offerAccents.length],
                          ),
                        );
                      }),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: AppFonts.body(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final LangProvider lang;

  const _HeroBanner({required this.lang});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0A2E), Color(0xFF3D1A6E), Color(0xFF6B2FA0)],
          ),
          boxShadow: AppColors.shadowRaised2,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.22),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withOpacity(0.14),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              right: 6,
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 110,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 13, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          lang.isRTL ? 'عرض محدود' : 'Limited Offer',
                          style: AppFonts.body(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    lang.isRTL
                        ? 'تمويل شخصي بدون رسوم'
                        : 'Personal Finance\nwith Zero Fees',
                    style: AppTextStyles.stepTitle
                        .copyWith(fontSize: 24, height: 1.28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.isRTL
                        ? 'احصل على تمويل حتى ٥٠٠,٠٠٠ ر.س بموافقة فورية'
                        : 'Get up to 500,000 SAR with instant approval',
                    style: AppTextStyles.label
                        .copyWith(height: 1.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          AppPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: _products[0]),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        lang.isRTL ? 'تقدم الآن' : 'Apply Now',
                        style: AppTextStyles.buttonText.copyWith(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _TrustStat(
                        icon: Icons.people_outline_rounded,
                        value: '+50K',
                        label: lang.isRTL ? 'عميل' : 'Clients',
                      ),
                      _statDivider(),
                      _TrustStat(
                        icon: Icons.star_outline_rounded,
                        value: '4.8',
                        label: lang.isRTL ? 'تقييم' : 'Rating',
                      ),
                      _statDivider(),
                      _TrustStat(
                        icon: Icons.bolt_outlined,
                        value: lang.isRTL ? '٢٤س' : '24h',
                        label: lang.isRTL ? 'موافقة' : 'Approval',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() => Container(
        width: 1,
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        color: Colors.white.withOpacity(0.15),
      );
}

class _TrustStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _TrustStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.gold),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppFonts.body(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: AppFonts.body(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductCard extends StatefulWidget {
  final BankProduct product;
  final LangProvider lang;

  const _ProductCard({required this.product, required this.lang});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final lang = widget.lang;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onHighlightChanged: (v) => setState(() => _pressed = v),
          onTap: () {
            Navigator.push(
              context,
              AppPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product)),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppColors.shadowRaised1,
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: product.gradient,
                    ),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: product.gradient,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: product.gradient.last.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child:
                              Icon(product.icon, color: Colors.white, size: 27),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.isRTL ? product.titleAr : product.titleEn,
                                style:
                                    AppTextStyles.value.copyWith(fontSize: 15.5),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                lang.isRTL ? product.descAr : product.descEn,
                                style: AppTextStyles.label.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 9),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: product.badgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: product.badgeColor.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded,
                                        size: 10, color: product.badgeColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.badge,
                                      style: AppFonts.body(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: product.badgeColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            lang.isRTL
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferItem offer;
  final LangProvider lang;
  final Color accent;

  const _OfferCard({
    required this.offer,
    required this.lang,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            AppPageRoute(builder: (_) => OfferDetailsScreen(offer: offer)),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent.withOpacity(0.10), AppColors.card],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(offer.icon, color: accent, size: 21),
                    ),
                  ),
                ),
                CustomPaint(
                  size: const Size(1, double.infinity),
                  painter: _DashedLinePainter(color: AppColors.cardBorder),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.isRTL ? offer.titleAr : offer.titleEn,
                                style:
                                    AppTextStyles.value.copyWith(fontSize: 13.5),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lang.isRTL ? offer.partnerAr : offer.partnerEn,
                                style: AppTextStyles.label.copyWith(fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              lang.isRTL ? 'ينتهي' : 'Ends',
                              style: AppTextStyles.label.copyWith(fontSize: 9.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              offer.validUntil,
                              style: AppFonts.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
          Offset(0, y), Offset(0, math.min(y + dashHeight, size.height)), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
