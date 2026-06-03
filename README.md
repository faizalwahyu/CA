# Compromise Assessment Collector

## Gambaran Umum

**Compromise Assessment (CA)** adalah proses yang dilakukan untuk menentukan apakah suatu sistem, server, endpoint, atau jaringan telah mengalami kompromi atau aktivitas yang tidak sah oleh pihak yang tidak berwenang. Berbeda dengan *Vulnerability Assessment* atau *Penetration Testing* yang berfokus pada identifikasi kelemahan keamanan, Compromise Assessment berfokus pada pencarian bukti adanya aktivitas kompromi yang telah atau sedang terjadi.

Repositori ini menyediakan skrip dan panduan untuk mengumpulkan informasi sistem, log, serta artefak keamanan yang dapat digunakan dalam kegiatan investigasi insiden, *threat hunting*, dan analisis kompromi.

## Tujuan

Compromise Assessment bertujuan untuk:

- Mengidentifikasi indikasi kompromi (*Indicators of Compromise/IoC*).
- Mendeteksi aktivitas berbahaya atau tidak sah pada sistem.
- Menentukan ruang lingkup dan dampak suatu insiden keamanan.
- Mengidentifikasi mekanisme *persistence* yang digunakan oleh penyerang.
- Mendukung proses *Incident Response* dan investigasi forensik digital.
- Menyediakan data dan artefak untuk analisis lebih lanjut.

## Kapan Compromise Assessment Dilakukan

Compromise Assessment umumnya dilakukan dalam kondisi berikut:

- Terdapat indikasi malware atau ransomware.
- Ditemukan aktivitas jaringan yang tidak biasa.
- Terdapat dugaan akses tidak sah ke sistem.
- Setelah terungkapnya kerentanan kritis yang berpotensi dieksploitasi.
- Investigasi terhadap kompromi web server atau aplikasi.
- Kegiatan *Threat Hunting* secara proaktif.
- Verifikasi pasca pemulihan insiden (*post-incident review*).
- Audit dan evaluasi keamanan sistem.

## Artefak yang Dikumpulkan

Bergantung pada sistem operasi dan layanan yang tersedia, skrip dapat mengumpulkan informasi sebagai berikut:

### Informasi Sistem

- Hostname
- Informasi sistem operasi
- Informasi perangkat keras
- Paket atau perangkat lunak yang terpasang
- Daftar layanan yang berjalan

### Informasi Pengguna dan Autentikasi

- Daftar pengguna lokal
- Daftar grup dan administrator
- Riwayat login
- Log autentikasi
- Konfigurasi SSH dan *authorized keys* (Linux)

### Informasi Proses dan Layanan

- Daftar proses yang sedang berjalan
- Konfigurasi layanan (*services*)
- Program yang berjalan saat startup
- Scheduled Tasks (Windows)
- Systemd Services dan Timers (Linux)

### Informasi Jaringan

- Koneksi jaringan aktif
- Port yang terbuka (*listening ports*)
- Tabel routing
- ARP cache
- Konfigurasi DNS

### Informasi Web Server

- Konfigurasi dan log Apache
- Konfigurasi dan log Nginx
- Konfigurasi dan log IIS

### Platform Kontainer

- Docker container dan image
- Podman container
- Informasi Kubernetes (jika tersedia)

### Log Keamanan

- Log sistem
- Log autentikasi
- Log aplikasi
- Windows Event Logs
- PowerShell Logs (Windows)

### Indikator Persistence

- Cron Jobs
- Scheduled Tasks
- Startup Entries
- Registry Autoruns (Windows)
- Systemd Services dan Timers (Linux)

### Artefak Sistem Berkas

- File yang baru dimodifikasi
- File executable pada direktori sementara
- File aplikasi web
- File dengan hak akses istimewa (SUID/SGID pada Linux)

## Metodologi Compromise Assessment

Pengumpulan artefak dilakukan berdasarkan tahapan umum *Incident Response* dan *Threat Hunting*:

1. **System Discovery**
   - Identifikasi sistem operasi, layanan, dan aplikasi yang berjalan.

2. **Evidence Collection**
   - Pengumpulan log, konfigurasi, artefak sistem, dan informasi keamanan.

3. **Persistence Analysis**
   - Pemeriksaan mekanisme yang memungkinkan akses bertahan setelah reboot atau logout.

4. **Execution Analysis**
   - Analisis proses, layanan, task, dan aktivitas eksekusi yang mencurigakan.

5. **Network Analysis**
   - Pemeriksaan koneksi aktif, port terbuka, dan aktivitas jaringan yang tidak biasa.

6. **Authentication Analysis**
   - Analisis login, autentikasi, dan aktivitas akun pengguna.

7. **Timeline Analysis**
   - Identifikasi aktivitas berdasarkan waktu modifikasi file dan log.

8. **Threat Hunting**
   - Pencarian indikator kompromi dan pola aktivitas yang sesuai dengan teknik penyerang.

## Ruang Lingkup Penggunaan

Compromise Assessment Collector dapat digunakan untuk mendukung:

- Computer Security Incident Response Team (CSIRT)
- Security Operations Center (SOC)
- Incident Response (IR)
- Threat Hunting
- Analisis awal insiden keamanan
- Persiapan investigasi forensik digital
- Audit keamanan sistem

## Keterbatasan

Alat ini dirancang sebagai sarana pengumpulan artefak dan analisis awal (*triage*). Alat ini **tidak dirancang untuk**:

- Menghapus malware atau ancaman.
- Melakukan perubahan konfigurasi sistem.
- Menggantikan proses investigasi forensik digital secara menyeluruh.
- Menggantikan solusi Endpoint Detection and Response (EDR).
- Menggantikan perangkat DFIR (*Digital Forensics and Incident Response*) khusus.

Hasil pengumpulan artefak tetap memerlukan analisis lebih lanjut oleh personel keamanan, CSIRT, atau analis forensik untuk menentukan ada atau tidaknya kompromi pada sistem.

## Output

Hasil pengumpulan artefak akan disimpan dalam direktori terpisah yang berisi:

- Informasi sistem
- Informasi pengguna
- Konfigurasi layanan
- Informasi jaringan
- Log keamanan
- Artefak persistence
- Artefak aplikasi web
- Artefak container
- Artefak keamanan lainnya yang tersedia pada sistem

Seluruh artefak dapat digunakan sebagai bahan analisis lebih lanjut dalam proses investigasi insiden.

## Disclaimer

Alat ini dikembangkan untuk tujuan defensif, investigasi keamanan, dan kegiatan penanganan insiden pada sistem yang dimiliki atau dikelola secara sah. Pengguna bertanggung jawab untuk memastikan bahwa penggunaan alat ini sesuai dengan kebijakan organisasi, peraturan yang berlaku, dan otorisasi yang dimiliki.

Pengembang tidak bertanggung jawab atas penyalahgunaan alat ini untuk aktivitas yang melanggar hukum atau tidak memiliki otorisasi yang sah.
