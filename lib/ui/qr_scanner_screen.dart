import 'dart:typed_data'; // paket untuk menangani data byte
import 'package:flutter/material.dart'; // paket flutter untuk komponen ui
import 'package:mobile_scanner/mobile_scanner.dart'; // paket untuk pemindaian qr code
import 'package:share_plus/share_plus.dart'; // paket untuk berbagi data antar aplikasi

// mendefinisikan layar pemindai qr code sebagai widget stateful
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  String? qrRawValue; // menyimpan nilai mentah (raw) dari qr code yang terdeteksi
  bool flashOn = false; // status apakah lampu flash menyala atau tidak
  bool scanning = false; // status apakah proses pemindaian sedang berjalan
  bool qrDetected = false; // status apakah qr code berhasil dideteksi
  late MobileScannerController scannerController; // controller untuk pengaturan scanner

  @override
  void initState() {
    super.initState();
    // menginisialisasi scanner controller dengan pengaturan default
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates, // menghindari hasil scan duplikat
      returnImage: true, // memungkinkan pengambilan gambar hasil scan
    );
  }

  @override
  void dispose() {
    // membersihkan scanner controller saat widget ini dihancurkan
    scannerController.dispose();
    super.dispose();
  }

  // fungsi untuk mereset proses pemindaian qr code
  void resetScanner() {
    setState(() {
      qrRawValue = null; // mengosongkan nilai qr yang sebelumnya terdeteksi
      scanning = false; // menandai bahwa proses pemindaian selesai
      qrDetected = false; // menyetel status qr belum terdeteksi
    });
    scannerController.start(); // memulai ulang kamera untuk pemindaian
  }

  // fungsi untuk menampilkan dialog yang memuat hasil pemindaian qr code
  void showResultDialog(Uint8List? image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // dialog akan menampilkan nilai qr yang terdeteksi
          title: Text(qrRawValue ?? "no qr code detected"), 
          content: Column(
            mainAxisSize: MainAxisSize.min, // menyesuaikan ukuran kolom dengan isi
            children: [
              if (image != null) 
                Image.memory(image), // menampilkan gambar hasil scan jika tersedia
              const SizedBox(height: 16), // memberikan jarak antara gambar dan tombol
              ElevatedButton.icon(
                onPressed: () {
                  if (qrRawValue != null) {
                    Share.share(qrRawValue!); // membagikan nilai qr melalui aplikasi lain
                  }
                },
                icon: const Icon(Icons.share),
                label: const Text("share qr code"), // teks tombol berbagi
              ),
            ],
          ),
          actions: [
            // tombol untuk menutup dialog
            TextButton(
              onPressed: () {
                Navigator.pop(context); // menutup dialog
              },
              child: const Text("close"),
            ),
            // tombol reset hanya muncul jika qr sudah terdeteksi
            if (qrDetected) 
              TextButton(
                onPressed: () {
                  resetScanner(); // memulai ulang scanner
                  Navigator.pop(context); // menutup dialog setelah reset
                },
                child: const Text("reset scan"),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("qr scanner"), // judul di bagian atas layar
      ),
      body: Stack(
        children: [
          // menampilkan widget mobile scanner untuk mendeteksi qr code
          MobileScanner(
            controller: scannerController, // menggunakan controller yang sudah dibuat
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes; // menangkap barcode yang terdeteksi
              final Uint8List? image = capture.image; // menangkap gambar hasil pemindaian

              // jika ada barcode yang terdeteksi dan proses pemindaian belum berjalan
              if (barcodes.isNotEmpty && !scanning && !qrDetected) {
                setState(() {
                  scanning = true; // menandakan proses pemindaian aktif
                  qrRawValue = barcodes.first.rawValue; // menyimpan nilai qr code
                  qrDetected = true; // menandai bahwa qr code berhasil dideteksi
                });

                // memunculkan dialog untuk menampilkan hasil scan
                showResultDialog(image);

                // setelah 2 detik, proses pemindaian diizinkan untuk dimulai kembali
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    scanning = false;
                  });
                });
              }
            },
          ),
          // efek transparan untuk menunjukkan bahwa proses pemindaian sedang berjalan
          if (scanning) ...[
            Container(
              color: Colors.grey.withOpacity(0.1), // layar menjadi sedikit gelap
            ),
          ],
          // area fokus di tengah layar
          Center(
            child: Container(
              width: 200, // lebar kotak area fokus
              height: 200, // tinggi kotak area fokus
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 8), // membuat border putih tebal
                borderRadius: BorderRadius.circular(12), // sudut kotak melengkung
              ),
            ),
          ),
          // bagian bawah layar untuk tombol kontrol
          Padding(
            padding: const EdgeInsets.all(16.0), // jarak elemen dari tepi layar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // tombol ditempatkan di bagian bawah
              children: [
                // tombol reset hanya muncul jika ada hasil pemindaian
                if (qrRawValue != null || scanning)
                  ElevatedButton.icon(
                    onPressed: resetScanner, // memulai ulang pemindaian
                    icon: const Icon(Icons.refresh), // ikon refresh
                    label: const Text("reset"),
                  ),
                const SizedBox(height: 16), // jarak antar tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // tombol tersebar rata
                  children: [
                    // tombol untuk membagikan data qr code
                    ElevatedButton.icon(
                      onPressed: () {
                        if (qrRawValue != null && qrRawValue!.isNotEmpty) {
                          Share.share(
                            qrRawValue!, // membagikan data mentah qr code
                            subject: "qr code data", // subjek pesan
                          );
                        } else {
                          // menampilkan pesan jika tidak ada data qr yang tersedia
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("no qr data available to share."),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.share), // ikon berbagi
                      label: const Text("share qr"), // teks tombol berbagi
                    ),
                    // tombol untuk mengatur flash
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          flashOn = !flashOn; // mengganti status flash
                          scannerController.toggleTorch(); // mengaktifkan atau mematikan flash
                        });
                      },
                      icon: Icon(
                        flashOn ? Icons.flash_on : Icons.flash_off, // ikon flash berubah sesuai status
                      ),
                      label: Text(flashOn ? "flash on" : "flash off"), // label flash sesuai status
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
