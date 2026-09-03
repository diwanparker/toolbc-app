# ToolBC App

Aplikasi mobile & web klinis modern untuk manajemen dan pemantauan pasien Tuberkulosis (TBC / TB) berbasis standar DOTS (*Directly Observed Treatment Short-course*), panduan Kemenkes RI, dan WHO.

---

## 🌟 Fitur Utama

- **Manajemen Kepatuhan Obat (DOTS Monitoring)**:
  - Pencatatan dosis obat harian (Fase Intensif HRZE & Fase Lanjutan HR).
  - Penghitungan otomatis persentase kepatuhan (*Adherence Rate*) dan hari terapi aktif.
- **Checkup Gejala Mandiri (Symptom Checkup)**:
  - Skrining harian untuk evaluasi gejala kritis (Batuk menetap, demam, keringat malam, penurunan BB).
  - Triage risiko klinis otomatis (*Low, Moderate, High Risk*) dengan eskalasi instan ke dokter penanggung jawab.
- **Asisten AI Edukasi TBC (AI Chatbot)**:
  - Konsultasi 24/7 terintegrasi dengan AI router (`ag/gemini-3.6-flash-medium` via `9router`).
  - Dilengkapi *Markdown Rich Text Parser* untuk visualisasi respon yang rapi (bold, italic, bullet list, header).
- **Dasbor Multi-Role Terpadu**:
  - **Pasien**: Target terapi, konfirmasi minum obat, asisten AI, dan riwayat klinis.
  - **Dokter**: Pemantauan pasien binaan, antrian eskalasi resiko, evaluasi hasil lab (TCM / GeneXpert), dan transisi fase pengobatan.
  - **Admin**: Manajemen hak akses, pendaftaran pasien baru, dan penugasan dokter (*Doctor Assignment*).

---

## 🎨 Sistem Desain (Medical Grade UI/UX)

- **Aksesibilitas**: Kontras tinggi sesuai standar **WCAG 2.1 AAA**.
- **Palet Warna Klinis**:
  - 🔵 **Azure Medical Blue (`#0284C7`)**: Identitas brand & status aktif.
  - 🟢 **Emerald Green (`#059669`)**: Kepatuhan tinggi & kondisi stabil.
  - 🟠 **Warm Amber (`#D97706`)**: Fase intensif & peringatan dini.
  - 🔴 **Rose Crimson (`#E11D48`)**: Gejala kritis & kasus mendesak.
- **Micro-Interactions**: *Diffuse multi-layer shadows*, tombol ergonomis (>= 48px touch target), dan *floating bottom navigation bar*.

---

## 🚀 Panduan Menjalankan

### 1. Prasyarat
- Flutter SDK 3.10+ / Dart 3.0+
- Backend ToolBC aktif di `http://localhost:5272` (atau endpoint server yang sesuai)

### 2. Menjalankan di Lokal (Web / Desktop / Mobile)

```bash
# Masuk ke direktori app
cd toolbc-app

# Install dependencies
flutter pub get

# Jalankan di Google Chrome (Web)
flutter run -d chrome

# Jalankan di Windows Desktop
flutter run -d windows

# Jalankan dengan target backend custom
flutter run -d chrome --dart-define=API_BASE_URL="http://localhost:5272/api"
```

Untuk pengujian di perangkat fisik Android melalui USB:
```bash
adb reverse tcp:5272 tcp:5272
```

---

## 🔑 Akun Uji Coba Demo

| Role | Email | Password |
|---|---|---|
| **Pasien** | `davina@pasien.com` | `Pasien123!` |
| **Dokter** | `arya@dokter.com` | `Dokter123!` |
| **Admin** | `admin@admin.com` | `Admin123!` |

---

## 📦 Build & Rilis

```bash
# Verifikasi kode & analisis statis
flutter analyze
flutter test

# Build Android APK
flutter build apk --release

# Build Android App Bundle (Play Store)
flutter build appbundle --release --dart-define=API_BASE_URL="https://your-production-backend.com/api"
```

---

## 📄 Lisensi & Hak Cipta
Dikelola oleh Tim Pengembang **ToolBC** ([github.com/toolbc](https://github.com/toolbc)).
