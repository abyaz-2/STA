import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _kAccent = Color(0xFF8BC34A);
const _kBlue = Color(0xFF1E88E5);

const _kHeroPalette = [
  Color(0xFFE53935),
  Color(0xFF8E24AA),
  Color(0xFF1E88E5),
  Color(0xFF00897B),
  Color(0xFFF4511E),
  Color(0xFF43A047),
  Color(0xFF6D4C41),
];

Color _heroColor(String name) =>
    _kHeroPalette[name.hashCode.abs() % _kHeroPalette.length];

// ── Payment methods ───────────────────────────────────────────────────────────
class _PayMethod {
  final IconData icon;
  final String label;
  final Color color;
  const _PayMethod(this.icon, this.label, this.color);
}

const _payMethods = [
  _PayMethod(Icons.credit_card, 'Credit Card', Color(0xFFFFA726)),
  _PayMethod(Icons.account_balance, 'Bank Account', Color(0xFF42A5F5)),
  _PayMethod(Icons.paypal, 'PayPal', Color(0xFF1565C0)),
  _PayMethod(Icons.currency_bitcoin, 'Bitcoin', Color(0xFFF9A825)),
  _PayMethod(Icons.add_circle, 'Custom', Color(0xFF757575)),
];

// ─────────────────────────────────────────────────────────────────────────────

class SubscriptionDetailScreen extends StatefulWidget {
  final Subscription subscription;
  const SubscriptionDetailScreen({required this.subscription, super.key});

  @override
  State<SubscriptionDetailScreen> createState() =>
      _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  late Subscription _sub;
  int _selectedPayMethod = 0;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sub = widget.subscription;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    await StorageService.addSubscription(_sub);
    await NotificationService.scheduleRenewalReminder(_sub);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Subscription saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  // ── Edit dialogs ──────────────────────────────────────────────────────────
  void _editAmount() {
    final ctrl = TextEditingController(text: _sub.amount.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Amount'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null) setState(() => _sub = _sub.copyWith(amount: v));
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _pickBillingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sub.nextBillingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _sub = _sub.copyWith(nextBillingDate: picked));
    }
  }

  String _monthsText() =>
      _sub.billingCycle.toLowerCase() == 'yearly' ? '12 months' : '1 month';

  String _formatDate(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final heroColor = _heroColor(_sub.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F3),
      body: Column(
        children: [
          // ── Hero header ───────────────────────────────────────────────────
          _HeroHeader(
            name: _sub.name,
            heroColor: heroColor,
            onBack: () => Navigator.pop(context),
            onSave: _save,
          ),

          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              child: Column(
                children: [
                  // Details card
                  _card(
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Amount',
                          trailing: GestureDetector(
                            onTap: _editAmount,
                            child: Text(
                              '₹ ${_sub.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _kBlue,
                              ),
                            ),
                          ),
                        ),
                        _div(),
                        _InfoRow(
                          label: 'Frequency',
                          trailing: GestureDetector(
                            onTap: () async {
                              final result = await showModalBottomSheet<String>(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (_) => _BillingCyclePicker(
                                  current: _sub.billingCycle,
                                ),
                              );
                              if (result != null) {
                                setState(
                                  () => _sub = _sub.copyWith(
                                    billingCycle: result,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              _sub.billingCycle[0].toUpperCase() +
                                  _sub.billingCycle.substring(1),
                              style: const TextStyle(
                                color: _kBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        _div(),
                        _InfoRow(
                          label: 'Next Billing Date',
                          trailing: GestureDetector(
                            onTap: _pickBillingDate,
                            child: Text(
                              _formatDate(_sub.nextBillingDate),
                              style: const TextStyle(
                                color: _kBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        _div(),
                        _InfoRow(
                          label: 'Remind before',
                          trailing: _Stepper(
                            value: _sub.reminderDaysBefore,
                            min: 1,
                            max: 7,
                            onChanged: (v) => setState(
                              () => _sub = _sub.copyWith(reminderDaysBefore: v),
                            ),
                          ),
                        ),
                        _div(),
                        _InfoRow(
                          label: 'Renews every',
                          trailing: Text(
                            _monthsText(),
                            style: const TextStyle(
                              color: _kBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment method card
                  _SectionCard(
                    title: 'Payment Method',
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.15,
                      children: List.generate(_payMethods.length, (i) {
                        final m = _payMethods[i];
                        final sel = _selectedPayMethod == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPayMethod = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: sel
                                  ? m.color.withValues(alpha: 0.12)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sel ? m.color : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(m.icon, color: m.color, size: 26),
                                const SizedBox(height: 6),
                                Text(
                                  m.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: sel ? m.color : Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Notes card
                  _SectionCard(
                    title: 'Notes',
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tap to edit..',
                        hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),

                  // Sharing card
                  _SectionCard(
                    title: 'Sharing',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Shared Subscription',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _sub.isShared ? 'Visible to group members' : 'Private',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: _sub.isShared,
                      activeColor: _kAccent,
                      onChanged: (v) =>
                          setState(() => _sub = _sub.copyWith(isShared: v)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() => const Divider(height: 1, indent: 20, endIndent: 20);

  Widget _card({required Widget child}) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

// ── Hero Header ───────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String name;
  final Color heroColor;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _HeroHeader({
    required this.name,
    required this.heroColor,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: heroColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: const Text(
                      '← Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: heroColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Text(
                name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  const _InfoRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

// ── Stepper ───────────────────────────────────────────────────────────────────
class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBtn(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$value day${value == 1 ? '' : 's'}',
            style: const TextStyle(
              color: _kBlue,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        _StepBtn(
          icon: Icons.add,
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(8),
          color: onTap != null ? Colors.white : Colors.grey.shade100,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? const Color(0xFF444444) : Colors.grey,
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Billing Cycle Bottom Sheet ────────────────────────────────────────────────
class _BillingCyclePicker extends StatelessWidget {
  final String current;
  const _BillingCyclePicker({required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Billing Cycle',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        for (final o in ['monthly', 'yearly'])
          ListTile(
            title: Text(
              o[0].toUpperCase() + o.substring(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: current == o
                ? const Icon(Icons.check_circle, color: _kAccent)
                : null,
            onTap: () => Navigator.pop(context, o),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
