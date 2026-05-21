import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/services/doctor_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/ui_components.dart';

enum AdminAccountTarget { patient, doctor }

class AdminCreateAccountPage extends StatefulWidget {
  const AdminCreateAccountPage({super.key, required this.target});

  final AdminAccountTarget target;

  @override
  State<AdminCreateAccountPage> createState() => _AdminCreateAccountPageState();
}

class _AdminCreateAccountPageState extends State<AdminCreateAccountPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _noteController = TextEditingController(); // specialty field for doctor

  bool _submitting = false;
  String? _resultMessage;

  // ── Doctor assignment state (only used when target == patient) ──
  List<DoctorModel> _doctorList = [];
  DoctorModel? _selectedDoctor;
  bool _loadingDoctors = false;

  bool get _isPatient => widget.target == AdminAccountTarget.patient;
  String get _roleLabel => _isPatient ? 'pasien/user' : 'dokter';
  String get _emailSuffix => _isPatient ? '@pasien.com' : '@dokter.com';

  @override
  void initState() {
    super.initState();
    if (_isPatient) _loadDoctors();
  }

  @override
  void didUpdateWidget(covariant AdminCreateAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _clearFields();
      _resultMessage = null;
      _selectedDoctor = null;
      if (_isPatient && _doctorList.isEmpty) _loadDoctors();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loadingDoctors = true);
    try {
      _doctorList = await DoctorService.fetchDoctors();
    } catch (_) {
      _doctorList = [];
    }
    if (mounted) setState(() => _loadingDoctors = false);
  }

  Future<void> _submit() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    final validationError = _validate(
      fullName: fullName,
      email: email,
      password: password,
      confirm: confirm,
    );
    if (validationError != null) {
      _showSnack(validationError);
      return;
    }

    setState(() => _submitting = true);
    try {
      final Map<String, dynamic> metadata = {
        'full_name': fullName,
        'role': widget.target.name,
        'created_by': 'admin',
      };

      if (_isPatient) {
        // Attach assigned doctor info
        if (_selectedDoctor != null) {
          metadata['assigned_doctor_id'] = _selectedDoctor!.id;
          metadata['assigned_doctor_name'] = _selectedDoctor!.fullName;
          metadata['assigned_doctor_specialty'] = _selectedDoctor!.specialty;
        }
      } else {
        // Doctor account — store specialty
        final specialty = _noteController.text.trim();
        if (specialty.isNotEmpty) metadata['specialty'] = specialty;
      }

      if (SupabaseService.isConfigured) {
        await SupabaseService.signUp(
          email: email,
          password: password,
          data: metadata,
        );
      }

      if (!mounted) return;

      final doctorInfo = _selectedDoctor != null
          ? '\nDokter: ${_selectedDoctor!.fullName} (${_selectedDoctor!.specialty})'
          : '';

      setState(() {
        _resultMessage = SupabaseService.isConfigured
            ? 'Akun $_roleLabel berhasil dibuat dan dikirim ke Supabase.$doctorInfo'
            : 'Mode demo: data akun $_roleLabel sudah divalidasi.$doctorInfo\nSambungkan Supabase untuk menyimpan akun sungguhan.';
        _clearFields();
      });
    } on AuthException catch (e) {
      if (mounted) _showSnack('Gagal membuat akun: ${e.message}');
    } catch (e) {
      if (mounted) _showSnack('Gagal membuat akun: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _validate({
    required String fullName,
    required String email,
    required String password,
    required String confirm,
  }) {
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      return 'Semua field wajib diisi.';
    }
    if (!email.endsWith(_emailSuffix)) {
      return 'Email $_roleLabel harus berakhiran $_emailSuffix.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (password != confirm) return 'Konfirmasi password tidak sama.';
    if (_isPatient && _selectedDoctor == null) {
      return 'Pilih dokter penanggung jawab terlebih dahulu.';
    }
    return null;
  }

  void _clearFields() {
    _fullNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _noteController.clear();
    _selectedDoctor = null;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      children: [
        PageHeader(
          title: 'Tambah Akun ${_isPatient ? 'Pasien/User' : 'Dokter'}',
          subtitle: _isPatient
              ? 'Admin/resepsionis membuat akun pasien dan menentukan dokter penanggung jawab.'
              : 'Admin/resepsionis membuat akun dokter untuk akses monitoring pasien.',
        ),
        const SizedBox(height: 16),
        _RoleInfoCard(isPatient: _isPatient, emailSuffix: _emailSuffix),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Account Form',
          child: Column(
            children: [
              AuthField(
                hintText: 'Nama lengkap',
                prefixIcon: Icons.person_outline_rounded,
                controller: _fullNameController,
              ),
              const SizedBox(height: 12),
              AuthField(
                hintText: 'email$_emailSuffix',
                prefixIcon: Icons.mail_outline_rounded,
                controller: _emailController,
              ),
              const SizedBox(height: 12),
              // ── Doctor assignment (patient) or specialty (doctor) ──
              if (_isPatient) ...[
                _DoctorSelector(
                  doctors: _doctorList,
                  selected: _selectedDoctor,
                  loading: _loadingDoctors,
                  onSelected: (doc) => setState(() => _selectedDoctor = doc),
                  onRefresh: _loadDoctors,
                ),
              ] else ...[
                AuthField(
                  hintText: 'Spesialisasi / poli',
                  prefixIcon: Icons.badge_outlined,
                  controller: _noteController,
                ),
              ],
              const SizedBox(height: 12),
              AuthField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              AuthField(
                hintText: 'Konfirmasi password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.person_add_alt_1_rounded, size: 19),
                  label: Text(
                    _submitting
                        ? 'Membuat akun...'
                        : 'Buat Akun ${_isPatient ? 'Pasien' : 'Dokter'}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_resultMessage != null) ...[
          const SizedBox(height: 16),
          SectionCard(
            background: const Color(0xFFF0FDF4),
            borderColor: const Color(0xFFBBF7D0),
            title: 'Sukses',
            trailing: const StatusPill(
              text: 'Done',
              bg: Color(0xFF22C55E),
              fg: Colors.white,
            ),
            child: Text(
              _resultMessage!,
              style: const TextStyle(fontSize: 10.5, color: kMuted),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Doctor Selector Widget
// ─────────────────────────────────────────────────────────────────────────────

class _DoctorSelector extends StatelessWidget {
  const _DoctorSelector({
    required this.doctors,
    required this.selected,
    required this.loading,
    required this.onSelected,
    required this.onRefresh,
  });

  final List<DoctorModel> doctors;
  final DoctorModel? selected;
  final bool loading;
  final ValueChanged<DoctorModel?> onSelected;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            const Icon(
              Icons.medical_information_outlined,
              color: Color(0xFF9CA3AF),
              size: 18,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Dokter Penanggung Jawab',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kPrimary,
                ),
              )
            else
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onRefresh,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: kMuted,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Doctor cards list
        if (loading && doctors.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Column(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Memuat daftar dokter...',
                  style: TextStyle(fontSize: 11, color: kMuted),
                ),
              ],
            ),
          )
        else if (doctors.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Tidak ada dokter tersedia. Buat akun dokter terlebih dahulu.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF991B1B)),
                  ),
                ),
                InkWell(
                  onTap: onRefresh,
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...doctors.map((doc) {
            final isSelected = selected?.id == doc.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSelected(isSelected ? null : doc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? kSoftBlue : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? kPrimary
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.8 : 1,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x1A2563EB),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isSelected
                            ? kPrimary
                            : const Color(0xFFE2E8F0),
                        child: Text(
                          doc.fullName.isNotEmpty
                              ? doc.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : kText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name & specialty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.fullName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? kPrimary : kText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doc.specialty,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: kMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? kPrimary
                                : const Color(0xFF9CA3AF),
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

        // Selected doctor summary
        if (selected != null) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22C55E), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ditangani oleh: ${selected!.fullName} (${selected!.specialty})',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _RoleInfoCard extends StatelessWidget {
  const _RoleInfoCard({required this.isPatient, required this.emailSuffix});

  final bool isPatient;
  final String emailSuffix;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      background: isPatient ? kSoftBlue : const Color(0xFFF0FDF4),
      borderColor: isPatient
          ? const Color(0xFFBFDBFE)
          : const Color(0xFFBBF7D0),
      title: 'Role ${isPatient ? 'Pasien/User' : 'Dokter'}',
      trailing: StatusPill(
        text: emailSuffix,
        bg: isPatient ? kPrimary : const Color(0xFF22C55E),
        fg: Colors.white,
      ),
      child: Text(
        isPatient
            ? 'Tidak ada register publik. Akun dibuat dari halaman admin setelah login. Wajib pilih dokter penanggung jawab.'
            : 'Tidak ada register publik. Akun dibuat dari halaman admin setelah login.',
        style: const TextStyle(fontSize: 10.5, color: kMuted),
      ),
    );
  }
}
