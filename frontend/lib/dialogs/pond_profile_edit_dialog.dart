import 'package:flutter/material.dart';
import '../models/diary_models.dart';

class PondProfileEditDialog extends StatefulWidget {
  const PondProfileEditDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  final ShrimpProfile profile;
  final ValueChanged<Map<String, dynamic>> onSave;

  @override
  State<PondProfileEditDialog> createState() => _PondProfileEditDialogState();
}

class _PondProfileEditDialogState extends State<PondProfileEditDialog> {
  late final TextEditingController _areaCtrl;
  late final TextEditingController _depthCtrl;
  late final TextEditingController _speciesCtrl;
  late final TextEditingController _stockedCountCtrl;
  late final TextEditingController _targetWeightCtrl;
  DateTime? _stockedOn;
  String _farmingStage = 'GIAI_DOAN_1';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _areaCtrl = TextEditingController(text: widget.profile.areaM2.toStringAsFixed(0));
    _depthCtrl = TextEditingController(text: widget.profile.depthM.toStringAsFixed(2));
    _speciesCtrl = TextEditingController(text: widget.profile.shrimpSpecies);
    _stockedCountCtrl = TextEditingController(text: widget.profile.stockedCount.toString());
    _targetWeightCtrl = TextEditingController(
        text: (widget.profile.targetHarvestWeightG ?? 25.0).toStringAsFixed(0));
    _stockedOn = widget.profile.stockedOn ?? DateTime.now().subtract(const Duration(days: 25));
    _farmingStage = widget.profile.farmingStage;
  }

  @override
  void dispose() {
    _areaCtrl.dispose();
    _depthCtrl.dispose();
    _speciesCtrl.dispose();
    _stockedCountCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _stockedOn ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _stockedOn = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final payload = {
      'areaM2': double.tryParse(_areaCtrl.text.trim()) ?? 1000.0,
      'depthM': double.tryParse(_depthCtrl.text.trim()) ?? 1.5,
      'shrimpSpecies': _speciesCtrl.text.trim(),
      'stockedCount': int.tryParse(_stockedCountCtrl.text.trim()) ?? 100000,
      'stockedOn': _stockedOn != null
          ? "${_stockedOn!.year.toString().padLeft(4, '0')}-${_stockedOn!.month.toString().padLeft(2, '0')}-${_stockedOn!.day.toString().padLeft(2, '0')}"
          : null,
      'farmingStage': _farmingStage,
      'targetHarvestWeightG': double.tryParse(_targetWeightCtrl.text.trim()) ?? 25.0,
    };
    widget.onSave(payload);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings_suggest_rounded, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cấu hình số hóa ao nuôi',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Ao: ${widget.profile.siteName} · Thiết lập thông số vụ tôm',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _areaCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Diện tích ao (m²)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.crop_square_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập diện tích' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _depthCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Độ sâu nước (m)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.water_rounded),
                          ),
                          validator: (v) => (v == null || double.tryParse(v) == null) ? 'Nhập độ sâu' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _speciesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Đối tượng nuôi (Tôm / Cá / Khác)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bubble_chart_rounded),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập đối tượng nuôi' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stockedCountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng giống thả (con)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.groups_rounded),
                          ),
                          validator: (v) => (v == null || int.tryParse(v) == null) ? 'Nhập số con' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(8),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Ngày thả giống (DOC 0)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(
                              _stockedOn != null
                                  ? '${_stockedOn!.day}/${_stockedOn!.month}/${_stockedOn!.year}'
                                  : 'Chọn ngày',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _farmingStage,
                          borderRadius: BorderRadius.circular(16),
                          dropdownColor: Colors.white,
                          elevation: 8,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0284C7)),
                          decoration: const InputDecoration(
                            labelText: 'Giai đoạn nuôi',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'UOM_GIONG', child: Text('Ươm giống (<20 ngày)')),
                            DropdownMenuItem(value: 'GIAI_DOAN_1', child: Text('Giai đoạn 1 (20-45 ngày)')),
                            DropdownMenuItem(value: 'GIAI_DOAN_2', child: Text('Giai đoạn 2 (45-70 ngày)')),
                            DropdownMenuItem(value: 'VE_DICH', child: Text('Về đích (>70 ngày)')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _farmingStage = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _targetWeightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Trọng lượng thu hoạch mục tiêu (g/con)',
                      hintText: '25.0',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Hủy bỏ'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Lưu thông số ao'),
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
}
