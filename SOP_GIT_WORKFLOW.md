# 📋 SOP Git & FVM Workflow — ToolBC App

> **Project:** `flutter_tbc` (toolbc-app)
> **Flutter Version:** `3.41.7` (via FVM)
> **Dart SDK:** `^3.11.0`
> **Last Updated:** 21 Mei 2026

---

## Daftar Isi

1. [Prasyarat (Install Sekali)](#1--prasyarat-install-sekali)
2. [Clone / Pull Repository](#2--clone--pull-repository)
3. [Setup FVM & Flutter](#3--setup-fvm--flutter)
4. [Buat Branch Baru](#4--buat-branch-baru)
5. [Workflow Coding](#5--workflow-coding)
6. [Commit & Push](#6--commit--push)
7. [Buat Pull Request](#7--buat-pull-request)
8. [Aturan Penamaan](#8--aturan-penamaan)
9. [Troubleshooting](#9--troubleshooting)

---

## 1. 🛠 Prasyarat (Install Sekali)

Pastikan tools berikut sudah ter-install di komputer kamu:

| Tool | Cara Install | Cek Versi |
|------|-------------|-----------|
| **Git** | [git-scm.com](https://git-scm.com/) | `git --version` |
| **FVM** | `dart pub global activate fvm` | `fvm --version` |
| **Flutter** | Otomatis via FVM (jangan install manual) | `fvm flutter --version` |
| **Android Studio / VS Code** | Download dari website resmi | - |

> [!IMPORTANT]
> Jangan install Flutter secara manual/global jika menggunakan FVM.
> FVM akan mengatur versi Flutter per project.

---

## 2. 📥 Clone / Pull Repository

### A. Pertama Kali (Clone)

```powershell
# Pindah ke folder kerja
cd c:\android\toolbc

# Clone repository
git clone <URL_REPOSITORY> toolbc-app

# Masuk ke folder project
cd toolbc-app
```

### B. Sudah Ada di Lokal (Pull Update)

```powershell
# Masuk ke folder project
cd c:\android\toolbc\toolbc-app

# Pastikan kamu di branch yang benar (biasanya main/develop)
git checkout main

# Pull perubahan terbaru dari remote
git pull origin main
```

> [!WARNING]
> **SELALU pull dulu sebelum mulai coding!**
> Ini mencegah conflict saat push nanti.

---

## 3. ⚙️ Setup FVM & Flutter

Setelah clone/pull, **wajib** setup FVM agar versi Flutter sesuai dengan project.

### Step-by-step:

```powershell
# 1. Masuk ke folder project
cd c:\android\toolbc\toolbc-app

# 2. Install versi Flutter yang ditentukan di .fvmrc
fvm install
```

> FVM akan membaca file `.fvmrc` dan otomatis install Flutter versi **3.41.7**.

```powershell
# 3. Aktifkan versi Flutter untuk project ini
fvm use 3.41.7

# 4. Verifikasi versi Flutter aktif
fvm flutter --version
```

Output yang diharapkan:
```
Flutter 3.41.7 • channel stable
Dart 3.11.x
```

```powershell
# 5. Install dependencies project
fvm flutter pub get
```

### Setup IDE

#### VS Code
File `.vscode/settings.json` sudah otomatis dikonfigurasi oleh FVM. Jika belum:
```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

#### Android Studio
1. Buka **Settings** → **Languages & Frameworks** → **Flutter**
2. Set Flutter SDK path ke: `c:\android\toolbc\toolbc-app\.fvm\flutter_sdk`

> [!NOTE]
> Folder `.fvm/` sudah masuk `.gitignore`, jadi tidak akan ikut ter-push.
> Setiap developer harus menjalankan `fvm install` sendiri setelah clone.

---

## 4. 🌿 Buat Branch Baru

> [!CAUTION]
> **JANGAN pernah coding langsung di branch `main`!**
> Selalu buat branch baru untuk setiap fitur/bugfix.

### Step-by-step:

```powershell
# 1. Pastikan kamu di branch main dan sudah pull terbaru
git checkout main
git pull origin main

# 2. Buat branch baru dan langsung pindah ke branch tersebut
git checkout -b <nama-branch>
```

### Format Nama Branch

```
<tipe>/<deskripsi-singkat>
```

| Tipe | Digunakan Untuk | Contoh |
|------|----------------|--------|
| `feature/` | Fitur baru | `feature/doctor-assignment` |
| `fix/` | Perbaikan bug | `fix/login-validation` |
| `ui/` | Perubahan UI/tampilan | `ui/chat-bubble-redesign` |
| `refactor/` | Refactoring kode | `refactor/supabase-service` |
| `docs/` | Dokumentasi | `docs/update-readme` |
| `hotfix/` | Fix urgent di production | `hotfix/crash-on-submit` |

### Contoh:

```powershell
# Fitur baru: assign dokter ke pasien
git checkout -b feature/doctor-assignment

# Fix bug: validasi login gagal
git checkout -b fix/login-validation

# Update UI: redesign halaman chat
git checkout -b ui/chat-redesign
```

---

## 5. 💻 Workflow Coding

```powershell
# Cek status perubahan
git status

# Cek branch aktif
git branch

# Jalankan app untuk testing
fvm flutter run

# Jalankan analyzer sebelum commit
fvm flutter analyze --no-fatal-infos
```

> [!TIP]
> Gunakan `fvm flutter` (bukan `flutter`) agar selalu menggunakan versi Flutter yang sesuai project.

---

## 6. 📤 Commit & Push

### Step-by-step:

```powershell
# 1. Cek file apa saja yang berubah
git status

# 2. Tambahkan semua perubahan ke staging
git add .

# -- ATAU tambahkan file tertentu saja --
git add lib/features/admin/admin_pages.dart
git add lib/core/models/doctor_model.dart

# 3. Commit dengan pesan yang jelas
git commit -m "feat: implement doctor assignment saat tambah pasien"

# ══════════════════════════════════════════════════════════
# ⚠️  WAJIB: Jalankan analyze & test SEBELUM push!
# ══════════════════════════════════════════════════════════

# 4. Jalankan static analysis — HARUS 0 error
fvm flutter analyze

# 5. Jalankan semua unit/widget test — HARUS semua PASS
fvm flutter test

# 6. Jika analyze & test LULUS, baru boleh push
git push -u origin <nama-branch>
```

> [!CAUTION]
> **DILARANG push jika `flutter analyze` atau `flutter test` masih ada error/failure!**
> Fix semua issue terlebih dahulu, lalu ulangi step 4-5.

> [!IMPORTANT]
> Flag `-u` (upstream) hanya perlu dipakai **saat push pertama kali** untuk branch baru.
> Push berikutnya cukup `git push` saja.

### Format Commit Message

```
<tipe>: <deskripsi singkat>
```

| Prefix | Keterangan | Contoh |
|--------|-----------|--------|
| `feat:` | Fitur baru | `feat: tambah doctor selector di form pasien` |
| `fix:` | Bug fix | `fix: validasi email suffix gagal` |
| `ui:` | Perubahan UI | `ui: redesign chat bubble` |
| `refactor:` | Refactoring | `refactor: pisahkan doctor service` |
| `docs:` | Dokumentasi | `docs: tambah SOP workflow` |
| `chore:` | Maintenance | `chore: update dependencies` |

### Contoh Lengkap:

```powershell
git add .
git commit -m "feat: implement doctor assignment saat tambah pasien

- Buat DoctorModel dan DoctorService
- Tambah doctor selector widget di admin form
- Validasi wajib pilih dokter sebelum buat akun pasien
- Simpan assigned_doctor_id ke metadata Supabase"

# ✅ Wajib lolos sebelum push!
fvm flutter analyze          # Harus: No issues found!
fvm flutter test             # Harus: All tests passed!

git push -u origin feature/doctor-assignment
```

> [!TIP]
> Untuk commit message yang panjang, gunakan format multi-line seperti di atas.
> Baris pertama = ringkasan, baris setelah baris kosong = detail.

---

## 7. 🔀 Buat Pull Request

Setelah push, buat **Pull Request (PR)** di GitHub/GitLab:

1. Buka repository di browser
2. Akan muncul banner **"Compare & pull request"** → klik
3. Isi form PR:
   - **Title:** Sama dengan commit message utama
   - **Description:** Jelaskan perubahan yang dilakukan
   - **Reviewer:** Assign ke lead/reviewer tim
   - **Labels:** Tambahkan label yang sesuai (feature, bugfix, dll)
4. Klik **"Create Pull Request"**
5. **Tunggu review & approval** sebelum merge

> [!CAUTION]
> **JANGAN merge PR sendiri** tanpa review dari tim (kecuali kamu lead).

---

## 8. 📝 Aturan Penamaan

### Branch
```
feature/deskripsi-singkat     ✅
fix/deskripsi-singkat         ✅
Feature/DeskripsiSingkat      ❌ (jangan pakai huruf besar)
fitur_baru_login              ❌ (pakai prefix + slash)
```

### Commit Message
```
feat: tambah fitur X          ✅
fix: perbaiki bug Y           ✅
Tambah fitur                  ❌ (tanpa prefix)
update                        ❌ (tidak deskriptif)
asdfgh                        ❌ (tidak jelas)
```

### File Dart
```
doctor_model.dart             ✅ (snake_case)
DoctorModel.dart              ❌ (jangan PascalCase untuk file)
doctor-model.dart             ❌ (jangan kebab-case)
```

---

## 9. 🔧 Troubleshooting

### ❌ `fvm: command not found`
```powershell
dart pub global activate fvm
# Pastikan Dart SDK bin ada di PATH
```

### ❌ `flutter: command not found` setelah FVM
```powershell
# Gunakan fvm flutter, bukan flutter langsung
fvm flutter run
fvm flutter pub get
```

### ❌ Conflict saat pull
```powershell
# 1. Stash perubahan lokal
git stash

# 2. Pull terbaru
git pull origin main

# 3. Kembalikan perubahan
git stash pop

# 4. Resolve conflict manual jika ada, lalu commit
```

### ❌ Salah branch / lupa buat branch
```powershell
# Jika belum commit, langsung buat branch baru
git checkout -b feature/nama-fitur

# Jika sudah terlanjur commit di main
git checkout -b feature/nama-fitur    # branch baru dari posisi sekarang
git checkout main                      # balik ke main
git reset --hard origin/main           # reset main ke remote
git checkout feature/nama-fitur        # balik ke branch baru (commit aman)
```

### ❌ `pub get` gagal / dependency error
```powershell
# Hapus cache dan install ulang
fvm flutter clean
fvm flutter pub get
```

---

## 📌 Quick Reference (Cheatsheet)

```powershell
# ═══════════════════════════════════════════
# FULL WORKFLOW DARI AWAL SAMPAI PUSH
# ═══════════════════════════════════════════

# 1. Masuk project
cd c:\android\toolbc\toolbc-app

# 2. Setup FVM (sekali setelah clone)
fvm install
fvm use 3.41.7

# 3. Pull terbaru
git checkout main
git pull origin main

# 4. Buat branch baru
git checkout -b feature/nama-fitur

# 5. Install dependencies
fvm flutter pub get

# 6. Coding... ✍️

# 7. Commit
git add .
git commit -m "feat: deskripsi perubahan"

# 8. ⚠️ WAJIB: Analyze & Test sebelum push!
fvm flutter analyze          # Harus 0 error
fvm flutter test             # Harus semua PASS

# 9. Push (hanya jika step 8 LULUS)
git push -u origin feature/nama-fitur

# 10. Buat Pull Request di GitHub/GitLab 🎉
```

---

> **Dokumen ini berlaku untuk semua anggota tim ToolBC App.**
> Jika ada pertanyaan, hubungi project lead.
