import 'package:flutter/material.dart';

class AddFeedingDialog extends StatefulWidget {
  const AddFeedingDialog({
    super.key,
    required this.onAdd,
  });

  final ValueChanged<Map<String, dynamic>> onAdd;

  @override
  State<AddFeedingDialog> createState() => _AddFeedingDialogState();
}

class _AddFeedingDialogState extends State<AddFeedingDialog> {
  late final TextEditingController _mealCtrl;
  final _brandCtrl = TextEditingController(text: 'Grobest #2 (Protein 40%)');
  final _amountCtrl = TextEditingController(text: '25.0');
  String _trayStatus = 'HẾT';
  final _notesCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mealCtrl = TextEditingController(text: 'Cữ 1 (06:00)');
  }

  @override
  void dispose() {
    _mealCtrl.dispose();
    _brandCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'fedAt': DateTime.now().toUtc().toIso8601String(),
      'feedMeal': _mealCtrl.text.trim().isEmpty ? 'Cữ 1 (06:00)' : _mealCtrl.text.trim(),
      'feedBrand': _brandCtrl.text.trim(),
      'amountKg': double.tryParse(_amountCtrl.text.trim()) ?? 20.0,
      'feedTrayStatus': _trayStatus,
      'notes': _notesCtrl.text.trim(),
    };
    widget.onAdd(payload);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Icon(Icons.restaurant_rounded, color: Color(0xFFD97706), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ghi nhận cữ cho ăn',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Nhập khối lượng và phản xạ kiểm tra nhá ăn thực tế',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 1. Tên cữ cho ăn (Tự do nhập chữ)
                  TextFormField(
                    controller: _mealCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tên cữ / Giờ cho ăn *',
                      hintText: 'VD: Cữ 1 (06:00), Cữ trưa, Cữ phụ đêm 22h...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.alarm_rounded, color: Color(0xFF0284C7)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () => _mealCtrl.clear(),
                        tooltip: 'Xóa nhập lại',
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên cữ' : null,
                  ),
                  const SizedBox(height: 8),

                  // Gợi ý cữ ăn nhanh (chạm để điền & chỉnh sửa tùy ý)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _quickChip('Cữ 1 (06:00)'),
                      _quickChip('Cữ 2 (10:30)'),
                      _quickChip('Cữ 3 (14:30)'),
                      _quickChip('Cữ 4 (18:30)'),
                      _quickChip('Cữ phụ đêm (22:00)'),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. Lượng thức ăn & Hãng thức ăn
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Lượng thức ăn (kg) *',
                            hintText: '25.0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            prefixIcon: const Icon(Icons.scale_rounded, color: Color(0xFF059669)),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập số kg' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _brandCtrl,
                          decoration: InputDecoration(
                            labelText: 'Hãng / Mã thức ăn',
                            hintText: 'Grobest #2...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            prefixIcon: const Icon(Icons.inventory_2_outlined, color: Color(0xFF7C3AED)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3. Tình trạng nhá / vó ăn (Khung chọn trực quan đẹp mắt, không dùng menu xổ xuống thô)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.checklist_rounded, size: 16, color: Color(0xFF0284C7)),
                            SizedBox(width: 6),
                            Text(
                              'Tình trạng nhá / vó ăn (Phản xạ bắt mồi):',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _statusCard(
                              code: 'HẾT',
                              label: 'Ăn sạch 100%',
                              icon: Icons.check_circle_rounded,
                              activeColor: const Color(0xFF16A34A),
                              activeBg: const Color(0xFFDCFCE7),
                            ),
                            _statusCard(
                              code: 'DƯ_DƯỚI_10%',
                              label: 'Dư nhẹ (< 10%)',
                              icon: Icons.info_outline_rounded,
                              activeColor: const Color(0xFFD97706),
                              activeBg: const Color(0xFFFEF3C7),
                            ),
                            _statusCard(
                              code: 'DƯ_TRÊN_10%',
                              label: 'Dư nhiều (> 10%)',
                              icon: Icons.warning_amber_rounded,
                              activeColor: const Color(0xFFEA580C),
                              activeBg: const Color(0xFFFFEDD5),
                            ),
                            _statusCard(
                              code: 'BỎ_ĂN',
                              label: 'Bỏ ăn / Ăn kém',
                              icon: Icons.cancel_outlined,
                              activeColor: const Color(0xFFDC2626),
                              activeBg: const Color(0xFFFEE2E2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Ghi chú & Hành vi tôm
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú / Hành vi đàn tôm',
                      hintText: 'VD: Tôm bơi lội mạnh, phản xạ quạt nước nhạy, đường ruột to...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text('Lưu cữ ăn'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickChip(String text) {
    final isCurrent = _mealCtrl.text.trim() == text;
    return InkWell(
      onTap: () => setState(() => _mealCtrl.text = text),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF0284C7).withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: isCurrent ? const Color(0xFF0284C7) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _statusCard({
    required String code,
    required String label,
    required IconData icon,
    required Color activeColor,
    required Color activeBg,
  }) {
    final isSelected = _trayStatus == code;
    return InkWell(
      onTap: () => setState(() => _trayStatus = code),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFCBD5E1),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              size: 16,
              color: isSelected ? activeColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
