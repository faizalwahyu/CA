## Panduan Penggunaan

### Linux

1. Unduh atau salin file `ca_linux.sh` ke server Linux.
2. Berikan hak eksekusi pada script:

```bash
chmod +x ca_linux.sh
```

3. Jalankan script menggunakan akun dengan hak akses root atau sudo:

```bash
sudo ./ca_linux.sh
```

atau

```bash
sudo bash ca_linux.sh
```

4. Tunggu hingga proses pengumpulan selesai.

5. Hasil akan tersimpan pada direktori yang sama dengan lokasi script dijalankan dalam format:

```text
CA_<hostname>_<timestamp>/
CA_<hostname>_<timestamp>.tar.gz
CA_<hostname>_<timestamp>.tar.gz.sha256
```

### Windows

1. Jalankan PowerShell sebagai Administrator.

2. Jika diperlukan, izinkan eksekusi script pada sesi saat ini:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

3. Jalankan collector:

```powershell
.\ca_windows.ps1
```

atau

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\ca_windows.ps1
```

4. Tunggu hingga proses pengumpulan selesai.

5. Hasil akan tersimpan pada direktori yang sama dengan lokasi script dijalankan dalam format:

```text
CA_<hostname>_<timestamp>\
CA_<hostname>_<timestamp>.zip
CA_<hostname>_<timestamp>.zip.sha256
```

### Verifikasi Integritas

#### Linux

```bash
sha256sum -c CA_<hostname>_<timestamp>.tar.gz.sha256
```

#### Windows

```powershell
Get-FileHash .\CA_<hostname>_<timestamp>.zip -Algorithm SHA256
```

Pastikan nilai hash yang dihasilkan sesuai dengan file `.sha256`.

### Catatan

* Jalankan collector sesegera mungkin setelah indikasi kompromi ditemukan.
* Hindari melakukan reboot sebelum proses pengumpulan artefak dilakukan.
* Simpan hasil koleksi pada media yang aman untuk proses analisis lebih lanjut.
* Collector hanya melakukan pengumpulan artefak dan tidak melakukan perubahan konfigurasi maupun tindakan remediasi pada sistem.
