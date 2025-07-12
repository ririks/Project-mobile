# Aplikasi JEDAPUS: Aplikasi Pengajuan dan Pencatatan Cuti Pegawai

JEDAPUS merupakan sistem manajemen cuti digital yang dirancang khusus untuk Institut Teknologi dan Bisnis Bina Sarana Global. Aplikasi ini memungkinkan pegawai untuk mengajukan cuti secara digital, sementara admin HRD dan pimpinan dapat mengelola dan menyetujui pengajuan dengan efisien.

## Peran & Tanggung Jawab

| NIM            | Nama                    | Peran & Tanggung Jawab                                                                                                                                        |
| :------------- | :---------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **1122140008** | **Annisa Fitriani Rizky**     | **Project Manager**. Bertanggung jawab atas koordinasi tim, manajemen timeline, dan berkomunikasi dengan stakeholder. |
| **1122140092** | **Davina Alifyani** | **UI/UX Designer & Frontend Developer**. Bertugas membuat desain antarmuka dan mengimplementasikan UI dengan Flutter dan State Management       |
| **1122140050** | **Riri Komalasari**     | **Backend Developer**. Bertugas membuat skema database, dan mengimplementasikan business logic, serta melakukan maintenance.      |

## Fitur Utama

### Fitur untuk Staf/Pegawai
- **Dashboard Personal**: Ringkasan hak cuti dan status pengajuan
- **Pengajuan Cuti**: Form digital untuk mengajukan berbagai jenis cuti
- **Tracking Status**: Monitoring real-time status pengajuan cuti
- **Riwayat Cuti**: Histori lengkap pengajuan cuti yang pernah dibuat
- **Notifikasi**: Pemberitahuan otomatis untuk update status pengajuan
- **Profil Pegawai**: Manajemen data personal dan informasi kepegawaian

### Fitur untuk Admin HRD
- **Dashboard Administratif**: Overview seluruh pengajuan cuti di organisasi
- **Kelola Pegawai**: CRUD data pegawai dan informasi kepegawaian
- **Kelola Hak Cuti**: Pengaturan kuota cuti per jenis dan per pegawai
- **Review Pengajuan**: Interface untuk meninjau dan memproses pengajuan
- **Laporan Cuti**: Analisis dan statistik penggunaan cuti
- **Pengaturan Sistem**: Konfigurasi aplikasi dan aturan bisnis
- **Backup & Restore**: Manajemen data dan keamanan sistem

### Fitur untuk Rektor/Pimpinan
- **Dashboard Eksekutif**: Ringkasan pengajuan yang memerlukan persetujuan
- **Approval Workflow**: Sistem persetujuan bertingkat untuk pengajuan cuti
- **Riwayat Keputusan**: Histori semua keputusan yang telah dibuat
- **Laporan Strategis**: Insight untuk pengambilan keputusan manajemen

### Fitur Umum
- **Autentikasi Multi-Role**: Login berdasarkan peran pengguna
- **Responsive Design**: Tampilan optimal di berbagai perangkat
- **Real-time Updates**: Sinkronisasi data secara langsung
- **Search & Filter**: Pencarian dan penyaringan data yang efisien

---

## Teknologi

### Frontend
- **Flutter**: Framework utama untuk pengembangan cross-platform
- **Dart**: Bahasa pemrograman untuk logika aplikasi
- **Provider**: State management untuk manajemen state aplikasi
- **Google Fonts**: Typography dengan font Montserrat
- **Shared Preferences**: Local storage untuk session management

### Backend & Database
- **Supabase**: Backend-as-a-Service untuk API dan database
- **PostgreSQL**: Database relasional untuk penyimpanan data
- **Row Level Security**: Keamanan data tingkat baris
- **Real-time Subscriptions**: Update data secara real-time

---

## Prasyarat & Instalasi

### Prasyarat Sistem
- **Flutter SDK**: Versi 3.0 atau lebih baru
- **Dart SDK**: Versi 2.17 atau lebih baru
- **Android Studio/VS Code**: IDE untuk development
- **Git**: Version control system
- **Supabase Account**: Untuk backend services

### Prasyarat Development

**Cek versi Flutter**
    ```bash
    flutter --version
    ```

**Cek doctor untuk memastikan setup**
    ```bash
    flutter doctor
    ```

### Langkah Instalasi
    
Jalankan perintah berikut dari direktori root proyek:

1. **Clone Repository**
    ```bash
    git clone https://github.com/username/jedapus.git
    cd jedapus
    ```

2. **Instal Dependencies**
    ```bash
    flutter pub get
    ```

3. **Konfigurasi Environtment**
    *Copy file environment*
    ```bash
    cp .env.example .env
    ```
    *Edit konfigurasi Supabase*
    ```bash
    nano .env
    ```

4. **Setup Database**
    *Jalankan script SQL untuk membuat tabel*
    ```bash
    psql -h your-supabase-host -d your-database -f database/schema.sql
    ```

5. **Jalankan Aplikasi**
    *Development Mode*
    ```bash
    flutter run
    ```
    *Build untuk production*
    ```bash
    flutter build apk
    ```

---

## Struktur Proyek

Proyek ini mengikuti prinsip Clean Architecture dengan struktur folder sebagai berikut:

```
jedapus/
├── lib/
│ ├── core/
│ │ ├── constants.dart                  # Konstanta aplikasi
│ │ └── themes.dart                     # Tema dan styling
│ ├── data/
│ │ ├── models/                         # Model data
│ │ │ ├── user.dart
│ │ │ ├── pengajuan_cuti.dart
│ │ │ └── hak_cuti.dart
│ │ └── services/                       # Service layer
│ │ ├── auth_service.dart
│ │ ├── cuti_service.dart
│ │ └── employee_service.dart
│ ├── presentation/
│ │ ├── providers/                      # State management
│ │ │ ├── auth_provider.dart
│ │ │ ├── dashboard_provider.dart
│ │ │ └── cuti_provider.dart
│ │ ├── screens/                        # UI Screens
│ │ │ ├── auth/
│ │ │ │ └── login_screen.dart
│ │ │ ├── staf/
│ │ │ │ ├── staf_dashboard.dart
│ │ │ │ ├── staf_pengajuan.dart
│ │ │ │ ├── staf_riwayat.dart
│ │ │ │ └── staf_profile.dart
│ │ │ ├── hrd/
│ │ │ │ ├── hrd_dashboard.dart
│ │ │ │ ├── hrd_pengajuan.dart
│ │ │ │ ├── hrd_laporan.dart
│ │ │ │ ├── hrd_kelola_pegawai.dart
│ │ │ │ ├── hrd_kelola_hak_cuti.dart
│ │ │ │ ├── hrd_pengaturan_sistem.dart
│ │ │ │ ├── hrd_backup_restore.dart
│ │ │ │ └── hrd_profile.dart
│ │ │ └── rektor/
│ │ │ ├── rektor_dashboard.dart
│ │ │ ├── rektor_riwayat.dart
│ │ │ └── rektor_profile.dart
│ │ └── widgets/                        # Reusable components
│ │ ├── custom_button.dart
│ │ ├── custom_card.dart
│ │ └── loading_widget.dart
│ ├── app.dart                          # Main app configuration
│ └── main.dart                         # Entry point
├── assets/
│ ├── images/
│ │ └── global.png                      # Logo aplikasi
│ └── fonts/                            # Custom fonts
├── database/
│ ├── schema.sql                        # Database schema
│ └── seed_data.sql                     # Initial data
├── docs/
│ ├── api_documentation.md
│ └── user_manual.md
├── test/
│ ├── unit/                             # Unit tests
│ ├── widget/                           # Widget tests
│ └── integration/                      # Integration tests
├── pubspec.yaml                        # Dependencies
├── .env.example                        # Environment template
└── README.md                           # Project documentation
```

## Demo Aplikasi

https://youtu.be/MYAwvyy-mls