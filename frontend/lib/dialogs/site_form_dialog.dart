import 'package:flutter/material.dart';

class SiteDraft {
  const SiteDraft(this.name, this.location, this.timezone, this.notes);
  final String name, location, timezone, notes;
}

class SiteFormDialog extends StatefulWidget {
  const SiteFormDialog({super.key});

  @override
  State<SiteFormDialog> createState() => _SiteFormDialogState();
}

class _SiteFormDialogState extends State<SiteFormDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 22,
      right: 22,
      top: 24,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thêm điểm quan trắc',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tên điểm đo *',
              prefixIcon: Icon(Icons.water_outlined),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nhập tên điểm đo.' : null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: const InputDecoration(
              labelText: 'Vị trí',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Ghi chú',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                if (_form.currentState!.validate()) {
                  Navigator.pop(
                    context,
                    SiteDraft(
                      _name.text.trim(),
                      _location.text.trim(),
                      'Asia/Ho_Chi_Minh',
                      _notes.text.trim(),
                    ),
                  );
                }
              },
              child: const Text('Lưu điểm đo'),
            ),
          ),
        ],
      ),
    ),
  );
}

