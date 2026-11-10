import 'package:flutter/material.dart';

class AddTreatmentDialog extends StatefulWidget {
  const AddTreatmentDialog({
    super.key,
    required this.onAdd,
  });

  final ValueChanged<Map<String, dynamic>> onAdd;

  @override
  State<AddTreatmentDialog> createState() => _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends State<AddTreatmentDialog> {
  String _type = 'MEN_VI_SINH';
  final _customTypeCtrl = TextEditingController(text: 'Vitamin C tạt ao');
  final _nameCtrl = TextEditingController(text: 'Men vi sinh Bio-BZT USA');
  final _dosageCtrl = TextEditingController(text: '2.0');
  String _unit = 'gói';
  final _purposeCtrl = TextEditingController(text: 'Cấy men vi sinh phân hủy mùn bã hữu cơ đáy');
  final _notesCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static const _treatmentPresets = <String, ({String label, IconData icon, Color color, Color bg})>{
    'MEN_VI_SINH': (
      label: 'Men vi sinh (Xử lý đáy / Nước)',
      icon: Icons.biotech_rounded,
      color: Color(0xFF059669),
      bg: Color(0xFFECFDF5),
    ),
    'KHOANG_CHAT': (
      label: 'Khoáng tạt (Kích lột xác)',
      icon: Icons.diamond_outlined,
      color: Color(0xFF0284C7),
      bg: Color(0xFFF0F9FF),
    ),
    'VOI_NONG_NGHIEP': (
      label: 'Vôi tạt (CaCO3, Dolomite)',
      icon: Icons.terrain_rounded,
      color: Color(0xFFD97706),
      bg: Color(0xFFFEF3C7),
    ),
    'DIET_KHUAN': (
      label: 'Diệt khuẩn (Iodine, BKC, Thuốc tím)',
      icon: Icons.sanitizer_rounded,
      color: Color(0xFFDC2626),
      bg: Color(0xFFFEE2E2),
    ),
    'OXY_VIEN': (
      label: 'Oxy viên cấp cứu đáy',
      icon: Icons.bubble_chart_rounded,
      color: Color(0xFF0891B2),
      bg: Color(0xFFECFEFF),
    ),
    'TRI_BENH': (
      label: 'Thuốc / Khử khí độc (Yucca, Men gan)',
      icon: Icons.medication_liquid_rounded,
      color: Color(0xFF7C3AED),
      bg: Color(0xFFF5F3FF),
    ),
    'KHAC': (
      label: 'Chế phẩm khác (Tự nhập loại...)',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF9333EA),
      bg: Color(0xFFFAF5FF),
    ),
  };

  @override
  void dispose() {
    _customTypeCtrl.dispose();
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final effectiveType = _type == 'KHAC'
        ? (_customTypeCtrl.text.trim().isNotEmpty ? _customTypeCtrl.text.trim() : 'Chế phẩm khác')
        : _type;

    final payload = {
      'treatedAt': DateTime.now().toUtc().toIso8601String(),
      'treatmentType': effectiveType,
      'productName': _nameCtrl.text.trim(),
      'dosage': double.tryParse(_dosageCtrl.text.trim()) ?? 1.0,
      'unit': _unit,
      'purpose': _purposeCtrl.text.trim(),
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
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE9D5FF)),
                        ),
                        child: const Icon(Icons.science_rounded, color: Color(0xFF9333EA), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ghi nhận xử lý thuốc & vi sinh',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.3),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Quản lý men vi sinh, khoáng tạt, vôi nông nghiệp và thuốc trị bệnh',
                              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 1. Phân loại chế phẩm (Dropdown đẹp mắt với icon & bo góc tròn)
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    borderRadius: BorderRadius.circular(16),
                    dropdownColor: Colors.white,
                    elevation: 8,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9333EA)),
                    decoration: InputDecoration(
                      labelText: 'Phân loại chế phẩm *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.category_rounded, color: Color(0xFF9333EA)),
                    ),
                    selectedItemBuilder: (context) {
                      return _treatmentPresets.entries.map((e) {
                        final meta = e.value;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: meta.bg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(meta.icon, size: 14, color: meta.color),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                meta.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    items: _treatmentPresets.entries.map((entry) {
                      final key = entry.key;
                      final meta = entry.value;
                      final isSelected = key == _type;
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: meta.bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: meta.color.withValues(alpha: 0.2)),
                                ),
                                child: Icon(meta.icon, size: 15, color: meta.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  meta.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? meta.color : const Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, size: 16, color: meta.color),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _type = v;
                          if (v == 'VOI_NONG_NGHIEP') {
                            _nameCtrl.text = 'Vôi nông nghiệp CaCO3';
                            _unit = 'kg';
                            _dosageCtrl.text = '50';
                            _purposeCtrl.text = 'Tăng kiềm và ổn định pH';
                          } else if (v == 'KHOANG_CHAT') {
                            _nameCtrl.text = 'Khoáng Calciphor Plus';
                            _unit = 'kg';
                            _dosageCtrl.text = '15';
                            _purposeCtrl.text = 'Bổ sung khoáng kích lột xác';
                          } else if (v == 'MEN_VI_SINH') {
                            _nameCtrl.text = 'Men vi sinh Bio-BZT USA';
                            _unit = 'gói';
                            _dosageCtrl.text = '2';
                            _purposeCtrl.text = 'Xử lý mùn bã đáy ao';
                          } else if (v == 'KHAC') {
                            _nameCtrl.text = '';
                            _purposeCtrl.text = '';
                          }
                        });
                      }
                    },
                  ),

                  // Khi chọn "Chế phẩm khác": Mở ô cho người dùng tự nhập là cái gì
                  if (_type == 'KHAC') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF9333EA)),
                              SizedBox(width: 6),
                              Text(
                                'Loại chế phẩm tùy chỉnh của bạn:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _customTypeCtrl,
                            decoration: InputDecoration(
                              labelText: 'Nhập tên loại chế phẩm *',
                              hintText: 'VD: Hóa chất hạ phèn PAC, Vitamin C tạt, Men tỏi ủ, Tinh dầu thảo dược...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.mode_edit_outline_rounded, color: Color(0xFF9333EA)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => _customTypeCtrl.clear(),
                                tooltip: 'Xóa nhập lại',
                              ),
                            ),
                            validator: (v) => (_type == 'KHAC' && (v == null || v.trim().isEmpty))
                                ? 'Vui lòng nhập tên loại chế phẩm'
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _quickCustomChip('Vitamin C tạt ao'),
                              _quickCustomChip('Chất hạ phèn PAC'),
                              _quickCustomChip('Men tỏi lên men'),
                              _quickCustomChip('Tinh dầu thảo dược'),
                              _quickCustomChip('Khoáng tạt nano'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // 2. Tên chế phẩm thương mại
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Tên thuốc / Chế phẩm thương phẩm *',
                      hintText: 'VD: Bio-BZT USA, Calciphor, Iodine 9000...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.medication_rounded, color: Color(0xFF0284C7)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tên chế phẩm' : null,
                  ),
                  const SizedBox(height: 14),

                  // 3. Liều lượng & Đơn vị tính
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _dosageCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Liều lượng *',
                            hintText: 'VD: 2.0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF059669)),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập liều hợp lệ' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: DropdownButtonFormField<String>(
                          initialValue: _unit,
                          borderRadius: BorderRadius.circular(16),
                          dropdownColor: Colors.white,
                          elevation: 8,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7)),
                          decoration: InputDecoration(
                            labelText: 'Đơn vị tính',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg (Kilogram)')),
                            DropdownMenuItem(value: 'lít', child: Text('lít (Litre)')),
                            DropdownMenuItem(value: 'gói', child: Text('gói (Pack)')),
                            DropdownMenuItem(value: 'chai', child: Text('chai (Bottle)')),
                            DropdownMenuItem(value: 'xô', child: Text('xô (Bucket)')),
                            DropdownMenuItem(value: 'bao', child: Text('bao (Bag)')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _unit = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Mục đích xử lý
                  TextFormField(
                    controller: _purposeCtrl,
                    decoration: InputDecoration(
                      labelText: 'Mục đích xử lý',
                      hintText: 'Cấy vi sinh định kỳ, tăng kiềm, lột xác...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.track_changes_rounded, color: Color(0xFFD97706)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Ghi chú cách tạt
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú / Cách tạt',
                      hintText: 'Ủ với rỉ mật 4h trước khi tạt quanh giàn quạt...',
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
                        label: const Text('Lưu xử lý ao'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9333EA),
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

  Widget _quickCustomChip(String text) {
    return InkWell(
      onTap: () => setState(() => _customTypeCtrl.text = text),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD8B4FE)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE)),
        ),
      ),
    );
  }
}
