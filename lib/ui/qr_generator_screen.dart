import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart'; // package screenshot
import 'package:share_plus/share_plus.dart'; // package untuk share file

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  String? qrRawValue; // teks dari input user
  Color qrColor = Colors.black; // warna default qr
  final ScreenshotController screenshotController = ScreenshotController(); // controller untuk screenshot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Code"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, '/'); // tombol untuk balik ke halaman lain
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // padding lebih besar untuk kesan rapi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Input untuk teks QR
            TextField(
              decoration: const InputDecoration(
                labelText: "Enter text to generate QR",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                setState(() {
                  qrRawValue = value; // simpan input user
                });
              },
            ),
            const SizedBox(height: 20), // jarak antar widget

            // Divider untuk memisahkan bagian
            const Divider(),
            const SizedBox(height: 10),

            // Judul untuk custom warna
            const Text(
              "Customize QR Color",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left, // rata kiri
            ),
            const SizedBox(height: 10),

            // Pilihan warna
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorBox(
                  color: Colors.black,
                  isSelected: qrColor == Colors.black,
                  onTap: () {
                    setState(() {
                      qrColor = Colors.black; // warna hitam
                    });
                  },
                ),
                ColorBox(
                  color: Colors.indigo,
                  isSelected: qrColor == Colors.indigo,
                  onTap: () {
                    setState(() {
                      qrColor = Colors.indigo; // warna indigo
                    });
                  },
                ),
                ColorBox(
                  color: Colors.blue,
                  isSelected: qrColor == Colors.blue,
                  onTap: () {
                    setState(() {
                      qrColor = Colors.blue; // warna biru
                    });
                  },
                ),
                ColorBox(
                  color: Colors.green,
                  isSelected: qrColor == Colors.green,
                  onTap: () {
                    setState(() {
                      qrColor = Colors.green; // warna hijau
                    });
                  },
                ),
                ColorBox(
                  color: Colors.red,
                  isSelected: qrColor == Colors.red,
                  onTap: () {
                    setState(() {
                      qrColor = Colors.red; // warna merah
                    });
                  },
                ),
                ColorBox(
                  color: Colors.purpleAccent.shade100,
                  isSelected: qrColor == Colors.purpleAccent.shade100,
                  onTap: () {
                    setState(() {
                      qrColor = Colors.purpleAccent.shade100; // warna ungu terang
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20), // jarak setelah pilihan warna

            // Divider untuk memisahkan bagian
            const Divider(),
            const SizedBox(height: 10),

            // Tampilkan QR Code
            if (qrRawValue != null)
              Column(
                children: [
                  Screenshot(
                    controller: screenshotController, // controller screenshot untuk QR
                    child: PrettyQr(
                      data: qrRawValue!, // teks QR
                      elementColor: qrColor, // warna sesuai pilihan
                      size: 200, // ukuran QR
                      errorCorrectLevel: QrErrorCorrectLevel.M, // tingkat koreksi error
                      roundEdges: true, // sudut melengkung
                    ),
                  ),
                  const SizedBox(height: 20), // jarak sebelum tombol share

                  // Tombol share QR Code
                  ElevatedButton.icon(
                    onPressed: _shareQrCode, // panggil fungsi share QR
                    icon: const Icon(Icons.share), // ikon tombol share
                    label: const Text("Share QR Code"), // teks tombol share
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareQrCode() async {
    // ambil screenshot dari QR
    final image = await screenshotController.capture();
    if (image != null) {
      // kalau berhasil ambil gambar, share menggunakan Share Plus
      await Share.shareXFiles([
        XFile.fromData(
          image,
          name: "qr_code.png", // nama file screenshot
          mimeType: "image/png", // format file
        ),
      ]);
    }
  }
}

// widget untuk kotak warna
class ColorBox extends StatelessWidget {
  final Color color; // warna kotak
  final bool isSelected; // apakah kotak ini dipilih
  final VoidCallback onTap; // fungsi kalau kotak ditekan

  const ColorBox({
    required this.color,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, // lebar kotak
        height: 40, // tinggi kotak
        margin: const EdgeInsets.symmetric(horizontal: 5), // jarak antar kotak
        decoration: BoxDecoration(
          color: color, // warna kotak
          borderRadius: BorderRadius.circular(8), // sudut melengkung
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2) // kotak terpilih
              : Border.all(color: Colors.grey, width: 1), // kotak biasa
        ),
      ),
    );
  }
}
