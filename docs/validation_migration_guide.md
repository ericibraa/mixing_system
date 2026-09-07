# Panduan Migrasi Validasi: Mobile → API

> Dokumen ini mendeskripsikan seluruh validasi yang saat ini dilakukan di sisi **mobile (Flutter)** beserta endpoint API yang berkaitan, sebagai referensi untuk memindahkan logika validasi ke sisi **API (SAP OData)**.

---

## 🔗 Base URL API

| Environment | Base URL |
|---|---|
| Development | `http://10.2.3.64:8010/sap/opu/odata/sap` |
| Production | *(lihat `ProdConfig`)* |

---

## 📋 Ringkasan Alur Fitur

```
ValidationScreen (Scan NRP Operator & Pengawas)
    ↓
HomeScreen
    ├── Weighing
    │   ├── Pilih Material / Order / Operation Type
    │   ├── ScaleWeighing (input timbang)
    │   └── Submit Weighing
    ├── Handover
    │   ├── Pilih Material / Order / Operation Type / Operation
    │   ├── ScanTong (scan wadah)
    │   └── Submit Handover
    └── Confirmation
        ├── Pilih Material / Order / Operation Type
        ├── Pilih Operation
        ├── FormConfirmation (input data)
        └── Submit Confirmation
```

---

## 1. 🔐 Validasi Screen — User Validation (NRP Scan)

**File:** `lib/screen/validation/validation.dart`
**Bloc:** `lib/screen/validation/bloc/validation_bloc.dart`
**Provider:** `lib/provider/validation_provider.dart`

### Endpoint
```
GET {baseUrl}/ZDMP_GET_MATERIAL_SRV/FImp_User
```

### Query Parameters
| Parameter | Tipe | Contoh | Keterangan |
|---|---|---|---|
| `Nrp` | `String` | `'12345'` | NRP user yang scan (dibungkus single quote) |
| `Title` | `String` | `'OPERATOR'` atau `'PENGAWAS'` | Peran user |
| `$format` | `String` | `json` | Format response |

### Validasi yang Dilakukan di Mobile (Saat Ini)

| # | Validasi | Lokasi Kode | Pesan Error |
|---|---|---|---|
| 1 | `results` response tidak boleh kosong | `validation.dart:107` | `"Invalid Operator"` |
| 2 | `title` harus match `OPERATOR` atau `PENGAWAS` | `validation.dart:119` | *(tidak ada pesan, langsung update state)* |
| 3 | Jika ke `/confirmation`, hanya butuh `PENGAWAS` yang terisi | `validation.dart:261-267` | Button tetap grey jika belum scan |
| 4 | Jika ke screen lain, **keduanya** harus terisi (Operator + Pengawas) | `validation.dart:265-266` | Button grey jika belum lengkap |

### Validasi yang Perlu Dipindahkan ke API

| # | Validasi | Deskripsi |
|---|---|---|
| V1 | **NRP Valid** | Cek apakah NRP terdaftar di sistem SAP |
| V2 | **Title Valid** | Cek apakah NRP tersebut memiliki title `OPERATOR` atau `PENGAWAS` yang sesuai |
| V3 | **Werks/Plant Match** | Pastikan user memiliki akses ke plant yang aktif |

### Response Model
```json
{
  "d": {
    "results": [
      {
        "__metadata": { "id": "", "uri": "", "type": "" },
        "Nrp": "12345",
        "Title": "OPERATOR",
        "Werks": "1000"
      }
    ]
  }
}
```

---

## 2. ⚖️ Validasi Weighing

### 2a. Validasi Form Awal — Pilih Order

**File:** `lib/screen/weighing/widgets/weighing.dart`

#### Validasi di Mobile (Button "Show Orders")

| # | Field | Validasi | Kode |
|---|---|---|---|
| 1 | `Plant` | Tidak boleh kosong | `weighing.dart:441` |
| 2 | `Material Code` | Tidak boleh kosong | `weighing.dart:443` |
| 3 | `Operation Type` | Wajib dipilih (not null) | `weighing.dart:442` |
| 4 | `Batch` | Tidak boleh kosong | `weighing.dart:444` |

---

### 2b. Validasi Scale Weighing — Input Form

**File:** `lib/screen/weighing/widgets/scale_weighing.dart`

---

#### ① Validasi `checkOperationType()` — Gate untuk Tombol Submit

> Baris **156–198** — fungsi ini jadi penjaga tombol **"Save & Print Label"**.
> Jika return `false`, tombol **disabled** (abu-abu). Jika `true`, tombol **aktif**.

```dart
bool checkOperationType() {
  switch (_weighingCubit.state.operationType) {

    case 'DECOCT':
      // Wajib: numberOfContainer, bruto, tara, netto, lot, line
      if (numberOfContainer.text.isNotEmpty &&
          bruto.text.isNotEmpty &&
          tara.text.isNotEmpty &&
          netto.text.isNotEmpty &&
          lot.text.isNotEmpty &&       // <-- Lot WAJIB untuk DECOCT
          line.text.isNotEmpty) {
        return true;
      }
      break;

    case 'CB':
      // Wajib: semua moisture content (Top, Middle, Bottom) + container, bruto, tara, netto, line
      if (topMoistureContent.text.isNotEmpty &&
          middleMoistureContent.text.isNotEmpty &&
          bottomMoistureContent.text.isNotEmpty &&
          numberOfContainer.text.isNotEmpty &&
          bruto.text.isNotEmpty &&
          tara.text.isNotEmpty &&
          netto.text.isNotEmpty &&
          line.text.isNotEmpty) {
        return true;
      }
      break;

    case 'CK':
      // Wajib: numberOfContainer, bruto, tara, netto, line (tanpa lot, tanpa moisture)
      if (numberOfContainer.text.isNotEmpty &&
          bruto.text.isNotEmpty &&
          tara.text.isNotEmpty &&
          netto.text.isNotEmpty &&
          line.text.isNotEmpty) {
        return true;
      }
      break;

    case 'LIQUID MIXING':
      // Wajib: numberOfContainer, netto, line (tanpa bruto/tara karena unit Liter)
      if (numberOfContainer.text.isNotEmpty &&
          netto.text.isNotEmpty &&
          line.text.isNotEmpty) {
        return true;
      }
      break;
  }
  return false; // default: tombol disabled
}
```

**Ringkasan field wajib per operationType:**

| Operation Type | `numberOfContainer` | `bruto` | `tara` | `netto` | `lot` | `line` | `moisture (Top/Mid/Bot)` |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `DECOCT` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `CB` | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ ✅ ✅ |
| `CK` | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| `LIQUID MIXING` | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ |

---

#### ② Validasi Scan Barcode Equipment (Scale)

> Baris **79–130** — dipanggil saat user scan QR code timbangan.

```dart
void _scanBarcode(Barcode? barcode) async {
  if (barcode != null && barcode.displayValue != null) {
    // ✅ Barcode valid, lanjut proses
    scannedBarcode = barcode.displayValue!;

    // Cek apakah ini mode LQD (Liquid)
    if (_weighingCubit.state.productiSupervisor == 'LQD') {
      // Mode LQD: langsung set bruto/netto dari volume, tidak perlu TCP
      isLdConect = true;
      _weighingCubit.setStartWork();
      _weighingCubit.setScaleWeighing(...copyWith(
          bruto: _parseDouble(volumeValue),
          netto: _parseDouble(volumeValue),
          numberOfContainer: numberOfContainer.text,
          unit: 'l'));
    }

    // Cek apakah equipment ditemukan dari hasil scan
    if (_weighingCubit.state.selectedEquipment.equipmentNo.isNotEmpty) {
      // ✅ Equipment valid → sambungkan TCP ke timbangan
      if (_weighingCubit.state.productiSupervisor != 'LQD') {
        tCPListen(); // koneksi TCP ke timbangan fisik
      }
    } else {
      // ❌ Equipment tidak valid di database
      showSnackBar("Invalid equipment", Colors.red);
    }

  } else {
    // ❌ Barcode null atau kosong
    showSnackBar("Barcode Error", Colors.red);
  }
}
```

---

#### ③ Validasi Koneksi TCP ke Timbangan

> Baris **358–455** — mencoba connect socket ke IP timbangan.

```dart
void tCPListen() async {
  try {
    socket = await Socket.connect(
        _weighingCubit.state.selectedEquipment.urlAddress, 4001);

    // ✅ Connect berhasil
    showSnackBar("Scale connected", Colors.green);
    _weighingCubit.setStartWork();
    _weighingCubit.setConnectedStatus(true);

    socket!.listen(
      (data) { /* parsing data timbangan dengan regex */ },
      onDone: () { socket!.destroy(); },
      onError: (error) {
        // ❌ Error saat membaca data
        showSnackBar("Failed connect to scale ...!", Colors.red);
        socket!.destroy();
      },
    );

  } catch (e) {
    // ❌ Gagal connect sama sekali
    showSnackBar("Failed connect to scale ...", Colors.red);
  }
}
```

---

#### ④ Validasi State setelah Data Weighing dari Server (ResultScale)

> Baris **476–591** — BlocListener WeighingCubit, dijalankan saat state berubah.

```dart
BlocListener<WeighingCubit, WeighingState>(
  listener: (context, state) {

    // Kondisi: operationDesc != operationDesc2 → pakai resultScales (set 1)
    if (state.selectedOperation.operationDesc !=
        state.selectedOperation.operationDesc2) {

      if (state.productiSupervisor == 'LQD') {
        // Mode Liquid: ambil data volume dari API
        volumeBloc.add(GetVolume(plant: state.plant));
        // Cek apakah ini container terakhir
        if (isFirst == false) {
          if (state.containerCounter == _validTotalContainer(state)) {
            isLast = true;
            isFirst = true;
          }
        }
      }

      if (state.productiSupervisor != 'LQD') {
        // Mode non-LQD: tampilkan bruto/netto dari timbangan
        bruto.text = state.scaleWeighing.bruto.toStringAsFixed(2);
        netto.text = state.scaleWeighing.netto.toStringAsFixed(2);
      } else {
        // Mode LQD: kalau ini wadah terakhir, kosongkan input
        if (isLast == true) {
          netto.clear();
          bruto.clear();
        }
        isLast = false;
      }

      if (state.resultScales.isNotEmpty) {
        // Ada data weighing sebelumnya dari server → populate form
        if (state.operationType == 'CB') {
          var moisture = state.resultScales[0].moistureContent!.split(";");
          // Split moisture content: format "top;middle;bottom"
          if (moisture.length > 2) {
            topMoistureContent.text = moisture[0];
            middleMoistureContent.text = moisture[1];
            bottomMoistureContent.text = moisture[2];
          } else if (moisture.first.isNotEmpty) {
            topMoistureContent.text = moisture[0]; // hanya top yang ada
          }
        }

        // Set total container
        final totalContainer = _resolveTotalContainer(state.resultScales[0], state);
        if (totalContainer.isNotEmpty) {
          numberOfContainer.text = totalContainer;
          _weighingCubit.setTotalContainer(totalContainer);
        }

        // Set counter wadah aktif
        var cancelWadah = state.resultScales[0].cancelWadah?.split(';') ?? [];
        if (state.resultScales[0].cancelWadah!.isEmpty) {
          // Tidak ada wadah yang dicancel → lanjut dari wadah maksimum + 1
          _weighingCubit.setContainerCounter(_maxWadah(state.resultScales) + 1);
        } else {
          // Ada wadah yang dicancel → mulai dari yang dicancel
          _weighingCubit.setContainerCounter(_parseInt(cancelWadah[0], fallback: 1));
        }
      }

    } else {
      // Kondisi: operationDesc == operationDesc2 → pakai resultScales2 (set 2)
      // Logika sama, tapi menggunakan resultScales2
      if (state.resultScales2.isNotEmpty) { /* sama seperti di atas */ }
    }
  },
),
```

---

#### ⑤ Validasi setelah Submit Weighing Berhasil

> Baris **594–738** — BlocListener SubmitWeighingBloc.

```dart
BlocListener<SubmitWeighingBloc, SubmitWeighingState>(
  listener: (context, state) async {
    switch (state) {

      case SubmitWeighingSuccess():
        var sumCont = _weighingCubit.state.containerCounter;

        // Cek apakah semua wadah sudah selesai
        if (sumCont == _parseInt(numberOfContainer.text)) {
          print("All Done"); // sudah selesai semua container
        } else {
          _weighingCubit.setContainerCounter(sumCont + 1); // lanjut container berikutnya
        }

        // Validasi kelengkapan data label dari server
        final weighingTime = _formatSapDateTime(submitData?.startDate, submitData?.startTime);
        final totalContainer = ...firstWhere((total) => total > 0, orElse: () => 0);

        if (weighingTime.isEmpty || totalContainer == 0) {
          // ❌ Data dari server belum lengkap, tolak print
          _showError('Data label dari server belum lengkap');
          break;
        }

        // ✅ Data lengkap → cetak label
        final printed = await labelPrinter.printWeighingLabel(...);
        showSnackBar(printed ? "Label printed" : "failed to print",
                     printed ? Colors.black : Colors.red);
        break;

      case SubmitWeighingError():
        // ❌ Error dari API SAP
        showSnackBar(state.error, Colors.red);
        break;
    }
  },
),
```

---

#### ⑥ Validasi Data ResultScale dari Server

> Baris **740–791** — BlocListener ResultScaleBloc & ResultScale2Bloc.

```dart
BlocListener<ResultScaleBloc, ResultScaleState>(
  listener: (context, state) {
    if (state is ResultScaleLoaded) {
      final results = state.resultScale.d?.results ?? [];

      if (results.isEmpty) {
        // ❌ Tidak ada data weighing sebelumnya dari server
        _showError('Data weighing belum tersedia');
        return;
      }

      // ✅ Ada data → populate state
      if (_weighingCubit.state.selectedEquipment.equipmentNo.isEmpty) {
        _weighingCubit.setSelectedEquipment(results[0].equipmentNo!);
      }
      _weighingCubit.setResultScaleList(results);
    } else if (state is ResultScaleError) {
      showSnackBar(state.error, Colors.red);
    }
  },
),
// ResultScale2Bloc: logika identik untuk set 2
```

---

#### ⑦ Validasi Tombol Submit (Bottom Navigation Bar)

> Baris **1017–1092** — kontrol tampilan tombol bawah layar.

```dart
// Kondisi tampil tombol "Save & Print Label" vs "Complete"
if (
  weighingState.containerCounter <= _validTotalContainer(weighingState)
  ||
  (weighingState.resultScales.isNotEmpty &&
   weighingState.resultScales.length < _validTotalContainer(weighingState))
) {
  // Masih ada container yang belum ditimbang
  TextButton(
    // Tombol aktif hanya jika checkOperationType() == true
    onPressed: checkOperationType() ? () {
      submitWeighingBloc.add(SendDataWeighing(weighingState: weighingState));
    } : null,
    style: TextButton.styleFrom(
      backgroundColor: checkOperationType() ? Colors.black : Colors.grey,
    ),
    child: Text("Save & Print Label "
        "${weighingState.containerCounter}/"
        "${_validTotalContainer(weighingState)}"),
  );
} else {
  // Semua container selesai → tampil tombol Complete
  TextButton(
    onPressed: () {
      // Jika totalContainer masih 0, tidak bisa complete
      _validTotalContainer(weighingState) == 0 ? null : context.go('/home');
      if (weighingState.isConnectedTcp) closeConnection();
    },
    style: TextButton.styleFrom(
      backgroundColor: _validTotalContainer(weighingState) == 0
          ? Colors.grey    // ❌ belum ada data container
          : Colors.green,  // ✅ semua container selesai
    ),
    child: Text(_validTotalContainer(weighingState) == 0
        ? "Save & Print Label"  // belum ada totalContainer
        : "Complete"),          // sudah selesai semua
  );
}
```

---

#### ⑧ Kondisi Tampilan Form Berdasarkan productiSupervisor

> Baris **1274–1457** — form input tampil berbeda tergantung jenis material.

```dart
// Hanya tampil untuk LQD (Liquid)
if (weighingState.productiSupervisor == 'LQD') {
  // Dropdown Volume (dari API GetVolume)
  DropdownMenu<String>(
    dropdownMenuEntries: menuEntries,
    onSelected: (value) {
      netto.text = value!;
      bruto.text = value;
      // LQD: bruto = netto = volume yang dipilih, unit = 'l'
    },
    label: Text('Volume'),
  );
}

// Field Lot — hanya tampil untuk DECOCT
if (weighingState.operationType == 'DECOCT') {
  TextFormField(controller: lot, labelText: 'Lot');
}

// Field Bruto/Tara/Netto — hanya tampil jika TCP sudah terhubung
if (weighingState.isConnectedTcp) {
  // Bruto: readOnly (dari timbangan)
  TextFormField(controller: bruto, readOnly: true);
  // Tara: editable (user input manual)
  TextFormField(controller: tara, onChanged: (value) {
    _weighingCubit.setScaleWeighing(
        state.scaleWeighing.copyWith(tara: _parseDouble(value)));
  });
  // Netto: readOnly (auto = bruto - tara dari timbangan)
  TextFormField(controller: netto, readOnly: true);
}

// Field Netto khusus LQD — hanya tampil jika LQD DAN sudah connect
if (weighingState.productiSupervisor == 'LQD' && isLdConect) {
  // LQD: Netto bisa diinput manual (bukan dari timbangan TCP)
  TextFormField(
    controller: netto,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    labelText: 'Netto', suffix: Text("L"),
    onFieldSubmitted: (value) => _onChangeNettoLqd(value),
  );
}

// Moisture Content (Top/Mid/Bot) — hanya tampil untuk CB
if (weighingState.operationType == 'CB') {
  // readOnly jika sudah ada data dari server (resultScales.isNotEmpty)
  TextFormField(
    controller: topMoistureContent,
    readOnly: weighingState.resultScales.isNotEmpty,
  );
  TextFormField(
    controller: middleMoistureContent,
    readOnly: weighingState.resultScales.isNotEmpty,
  );
  TextFormField(
    controller: bottomMoistureContent,
    readOnly: weighingState.resultScales.isNotEmpty,
  );
}

// numberOfContainer — readOnly jika sudah ada data dari server
// dan ini bukan operation clone (operationDesc == operationDesc2)
TextFormField(
  controller: numberOfContainer,
  readOnly: weighingState.resultScales.isNotEmpty &&
      weighingState.selectedOperation.operationDesc !=
      weighingState.selectedOperation.operationDesc2,
);
```

---

#### ⑨ Kondisi Tampil Tabel Riwayat Weighing

> Baris **1458–1711** — DataTable riwayat container yang sudah ditimbang.

```dart
// Cek apakah ini operation biasa (set 1) atau clone/object (set 2)
if (weighingState.selectedOperation.operationDesc !=
    weighingState.selectedOperation.operationDesc2) {
  // Set 1: tampilkan resultScales
  if (weighingState.resultScales.isNotEmpty) {
    DataTable(rows: [
      for (var dataLabel in weighingState.resultScales)
        DataRow(cells: [
          // ... counter, bruto, tara, netto
          DataCell(IconButton( // Tombol reprint label
            onPressed: () {
              if (weighingState.selectedEquipment.ipPrinter.isNotEmpty) {
                // ✅ Printer IP tersedia → bisa reprint
                var zplData = _zplDataFromResult(dataLabel, weighingState);
                if (zplData == null) return; // data tidak lengkap, batal
                labelPrinter.printWeighingLabel(...);
              } else {
                // ❌ IP printer kosong → belum scan scale
                showSnackBar("Please Scan Scale", Colors.red);
              }
            },
          ))
        ])
    ]);
  }
} else {
  // Set 2: tampilkan resultScales2 (untuk operation clone/objek sama)
  if (weighingState.resultScales2.isNotEmpty) {
    // Logika identik dengan set 1, tapi data dari resultScales2
    DataTable(/* ... sama seperti di atas */);
  }
}
```

---

#### ⑩ Validasi Data ZPL Label (untuk Print)

> Baris **305–356** — fungsi `_zplDataFromResult()`, dipanggil sebelum print.

```dart
ZplData? _zplDataFromResult(ResultScaleList dataLabel, WeighingState weighingState) {

  // Validasi 1: totalContainer wajib ada
  final totalContainer = _resolveTotalContainer(dataLabel, weighingState);
  if (totalContainer.isEmpty) {
    _showError('Total container kosong dari server');
    return null; // ← print dibatalkan
  }

  // Validasi 2: tanggal start weighing harus bisa di-parse
  final startWork = _formatSapDateTime(dataLabel.createdDate, dataLabel.createdTime);
  if (startWork.isEmpty) {
    _showError('Tanggal weighing tidak valid');
    return null; // ← print dibatalkan
  }

  // ✅ Semua valid → buat ZPL data untuk dikirim ke printer
  return ZplData(
    materialCode: weighingState.materialCode,
    orderNo: dataLabel.orderNo,
    bruto: _parseDouble(dataLabel.bruto),
    tara: _parseDouble(dataLabel.tara),
    netto: _parseDouble(dataLabel.netto),
    // ... field lainnya
  );
}
```

---

### 2c. Submit Weighing

**File:** `lib/screen/weighing/bloc/submit_weighing_bloc.dart`
**Provider:** `lib/provider/submit_weighing.dart`

#### Endpoint
```
POST {baseUrl}/ZDMP_POST_WEIGHT_SRV/WeighingSet
```

#### Validasi di Mobile (Sebelum Submit)

| # | Validasi | Kode | Keterangan |
|---|---|---|---|
| 1 | Kalkulasi `expiredDate` / `expiredTime` dari `expiredSet` | `submit_weighing_bloc.dart:36-47` | Jika `expiredNo != '0'`, hitung berdasarkan unit DAY/HOUR |
| 2 | Untuk `DECOCT`: tentukan `lotNo` dari container atau manual input | `submit_weighing_bloc.dart:27-33` | Jika `lot == '-'` ambil dari `selectedContainer.lot` |

#### Request Body (Fields yang Dikirim ke API)
```json
{
  "OrderNo": "string",
  "ActivityNo": "string",
  "EquipmentNo": "string",
  "Resource": "string",
  "ActivityWh": "string",
  "Bruto": "string (numeric)",
  "Tara": "string (numeric)",
  "Netto": "string (numeric)",
  "UnitWeighing": "string",
  "Temperature": "string",
  "UnitTemperature": "GC",
  "MoistureContent": "string",
  "UnitMoisture": "%",
  "ExpiredDate": "yyyyMMdd",
  "ExpiredTime": "HHmmss",
  "Operator": "string (NRP)",
  "Pengawas": "string (NRP)",
  "StartDate": "yyyyMMdd",
  "StartTime": "HHmmss",
  "Wadah": "string (int)",
  "TotalWadah": "string (int)",
  "Line": "string",
  "FinishDate": "yyyyMMdd",
  "FinishTime": "HHmmss",
  "LotNo": "string",
  "ObjectName": "string"
}
```

#### Validasi yang Perlu Dipindahkan ke API

| # | Field | Validasi |
|---|---|---|
| V1 | `OrderNo` | Harus valid dan exist di SAP |
| V2 | `ActivityNo` | Harus sesuai dengan order |
| V3 | `EquipmentNo` | Harus terdaftar sebagai equipment valid |
| V4 | `Bruto`, `Tara`, `Netto` | Harus numeric, `Netto = Bruto - Tara` |
| V5 | `Operator`, `Pengawas` | Harus NRP yang valid dengan title yang sesuai |
| V6 | `StartDate`, `StartTime` | Tidak boleh di masa depan |
| V7 | `Wadah` | Harus <= `TotalWadah` |
| V8 | `MoistureContent` (untuk CB) | Harus terisi jika operation type CB |
| V9 | `LotNo` (untuk DECOCT) | Harus terisi jika operation type DECOCT |
| V10 | `Temperature` (untuk DECOCT) | Harus berisi format `startTemp;endTemp` |

---

## 3. 🤝 Validasi Handover

**File:** `lib/screen/handover/widget/handover.dart`

### 3a. Validasi Form Awal — Pilih Order

| # | Field | Validasi | Kode |
|---|---|---|---|
| 1 | `Plant` | Tidak boleh kosong | `handover.dart:378` |
| 2 | `Material Code` | Tidak boleh kosong | `handover.dart:380` |
| 3 | `Operation Type` | Wajib dipilih | `handover.dart:379` |
| 4 | `Batch` | Tidak boleh kosong (minimal 6 karakter untuk trigger API) | `handover.dart:381` |

> **Catatan:** Batch API dipanggil otomatis jika panjang input > 5 karakter (`handover.dart:267`)

---

### 3b. Submit Handover — Logika If-Else

**File:** `lib/bloc/post_handover_bloc.dart`

#### ① Kondisi `activityWh` — Apakah Ada Fullpack BOMItem Kosong

> Baris **29–32** — menentukan apakah `activityWh` perlu diisi dari fullpack atau dikosongkan.

```dart
// post_handover_bloc.dart:29-32
String activityWh = '';
if (event.orderData.fullpack.isNotEmpty &&
    event.orderData.fullpack[0].bOMItem.isEmpty) {
  // ✅ Fullpack ada tapi BOMItem kosong → ambil activityNo dari fullpack[0]
  activityWh = event.orderData.fullpack[0].activityNo;
}
// ❌ Fullpack kosong atau BOMItem ada → activityWh tetap ''
```

**Implikasi API:** Field `ActivityWh` di `OrdToOprNav` bisa kosong string atau berisi activityNo tergantung kondisi ini.

---

#### ② Error Handling Submit Handover

> Baris **63–68** — penanganan error response dari SAP.

```dart
// post_handover_bloc.dart:63-68
} on ErrorResponse catch (e) {
  if (e.error != null && e.error!.message != null) {
    // ✅ Ada pesan error spesifik dari SAP → tampilkan ke user
    emit(SubmitHandoverError(e.error!.message!.value!));
  } else {
    // ❌ Error tanpa pesan → fallback ke generic error
    emit(const SubmitHandoverError('Server Error'));
  }
}
```

---

### 3c. Submit Handover

**Provider:** `lib/provider/submit_handover_provider.dart`

#### Endpoint
```
POST {baseUrl}/ZDMP_POST_ORDER_SRV/OrderSet
```

#### Request Body
```json
{
  "OrderNo": "string",
  "Plant": "string",
  "Material": "string",
  "BatchFG": "string",
  "RoutingNo": "string",
  "InternalCntr": "string",
  "OperationType": "string",
  "OrdToOprNav": [
    {
      "RoutingNo": "string",
      "InternalCntr": "string",
      "ActivityNo": "string",
      "OperationDesc": "string",
      "ControlRecipe": "string",
      "OperationApps": "string",
      "Line": "string",
      "StartDate": "yyyyMMdd",
      "StartTime": "HHmmss",
      "FinishDate": "yyyyMMdd",
      "FinishTime": "HHmmss",
      "Operator": "string (NRP)",
      "Pengawas": "string (NRP)",
      "ActivityWh": "string"
    }
  ]
}
```

#### Validasi yang Perlu Dipindahkan ke API

| # | Field | Validasi |
|---|---|---|
| V1 | `OrderNo` | Harus ada di SAP |
| V2 | `Plant` | Harus sesuai dengan plant user yang login |
| V3 | `Material` | Harus valid di master material |
| V4 | `BatchFG` | Harus sesuai dengan order |
| V5 | `OrdToOprNav[].Operator` | Harus NRP Operator yang valid |
| V6 | `OrdToOprNav[].Pengawas` | Harus NRP Pengawas yang valid |
| V7 | `OrdToOprNav[].Line` | Tidak boleh kosong |
| V8 | `OrdToOprNav[].StartDate/Time` | Harus format valid & tidak di masa depan |
| V9 | `OrdToOprNav[].ActivityWh` | Jika BOMItem kosong, wajib diisi dari activityNo fullpack pertama |

---

## 3.5 🔀 Validasi Handover & Mixing

**File:** `lib/screen/handover & mixing/widgets/`

---

### ① Mapping OperationType → OperationApps (handover_mixing.dart:341–357)

> Saat user memilih Operation Type di dropdown, mobile langsung memetakan ke kode SAP yang digunakan sebagai `OperationApps` di request.

```dart
// handover_mixing.dart:341-357
switch (materialValue) {
  case 'DECOCT':
    title = '31'; // → operationApps = "ge '31'"
    break;
  case 'CB':
    title = '32'; // → operationApps = "ge '32'"
    break;
  case 'CK':
    title = '33'; // → operationApps = "ge '33'"
    break;
  case 'LIQUID MIXING':
    title = '34'; // → operationApps = "ge '34'"
    break;
  case 'SEMI SOLID MIXING':
    title = '45'; // → operationApps = "ge '45'"
    break;
}
_handoverCubit.setOperationApps(title);
```

> **Implikasi API:** Field `OperationApps` yang dikirim di request harus salah satu dari `31`, `32`, `33`, `34`, `45` tergantung operationType.

---

### ② Validasi Scan Barcode Tong (scan_tong.dart & handover_cubit.dart)

> `_scanOperator()` — baris **43–96** di `scan_tong.dart`; logika inti di `setScannedTong()` — baris **88–329** di `handover_cubit.dart`

#### A. Switch-case berdasarkan `errorScanType` setelah scan

```dart
// scan_tong.dart:50-94
switch (_handoverCubit.state.errorScanType) {

  case ErrorScanType.dataScanned:
    // ❌ Tong/fullpack sudah pernah discan sebelumnya
    showSnackBar("Data is Scanned", Colors.red);
    Vibration.vibrate(duration: 800);
    break;

  case ErrorScanType.incorrectPriority:
    // ❌ Priority barcode tidak sesuai urutan (harus berurutan)
    showSnackBar("Invalid Priority", Colors.red);
    FlutterRingtonePlayer().play(fromAsset: "assets/ringtone/wrong.mp3");
    Vibration.vibrate(duration: 800);
    break;

  case ErrorScanType.noError:
    // ✅ Scan berhasil, tidak perlu aksi tambahan di scan_tong.dart
    // (scan_tong_results_weighing.dart: jika noError → trigger FlagHandover ke API)
    break;

  case ErrorScanType.dataNull:
    // ❌ Barcode tidak ditemukan di daftar tong/fullpack
    showSnackBar("Data Not Found", Colors.red);
    FlutterRingtonePlayer().play(fromAsset: "assets/ringtone/wrong.mp3");
    Vibration.vibrate(duration: 800);
    break;
}
```

#### B. Perbedaan Perilaku: `scan_tong.dart` vs `scan_tong_results_weighing.dart`

```dart
// scan_tong_results_weighing.dart:92-96 — TAMBAHAN saat noError:
case ErrorScanType.noError:
  // ✅ Langsung panggil API FlagHandover untuk menandai tong sudah di-scan
  handoverFlagBloc.add(FlagHandover(
      handoverFlag: hasScanned,
      originalOrder: _handoverCubit.state.selectedOrder.orderNo ?? ''));
  break;
// scan_tong.dart — TIDAK panggil API saat noError, hanya update state lokal
```

---

### ③ Logika Matching Barcode di `setScannedTong()` — handover_cubit.dart

> Baris **88–329** — fungsi kritis yang menentukan apakah scan valid atau tidak.

#### A. Routing scan berdasarkan Tab aktif

```dart
// handover_cubit.dart:105-107
if (state.tab == HandoverStatus.scantong ||
    state.tab == HandoverStatus.scanTongResultsWeighing) {
  // → Matching ke tongs + fullpack (alur ResultsWeighing)
} else {
  // → Matching ke tongs + materialSets (alur material biasa/mixing)
}
```

#### B. Matching Tong — berdasarkan `activityNo.length` + operationType

```dart
// handover_cubit.dart:108-137
for (var i = 0; i < tongs.length; i++) {
  switch (activityNo.length) {
    case 4:
      // Barcode 4-segment → untuk semua operationType KECUALI DECOCT
      if (state.operationType != 'DECOCT') {
        isMatch = tongs[i].activityNo == activityNo[3]; // segment ke-4
      }
      break;
    case 5:
      // Barcode 5-segment → KHUSUS untuk DECOCT
      if (state.operationType == 'DECOCT') {
        isMatch = tongs[i].activityNo == activityNo[3]; // segment ke-4
      }
      break;
  }

  if (tongs[i].isScanned!) {
    if (isMatch) {
      errorType = ErrorScanType.dataScanned; // ❌ Sudah discan
      break;
    }
    continue; // Lewati tong yang sudah discan
  }

  if (isMatch) {
    tongs[i] = tongs[i].copyWith(isScanned: true); // ✅ Tandai terscan
    completed++;
    errorType = ErrorScanType.noError;
    break;
  }
}
```

#### C. Matching Fullpack (tab scantong/scanTongResultsWeighing) — berdasarkan panjang barcode

```dart
// handover_cubit.dart:139-194
for (var k = 0; k < fullpack.length; k++) {
  switch (activityNo.length) {

    case 7:
      if (state.tab == HandoverStatus.scanTongResultsWeighing) {
        // Mode ResultsWeighing: matching berdasarkan activityWh + counter
        isMatch = fullpack[k].activityWh == activityNo[6] &&
                  fullpack[k].counter == activityNo[5];
      } else {
        // Mode biasa: matching berdasarkan activityDmp + counter
        isMatch = fullpack[k].activityDmp == activityNo[2] &&
                  fullpack[k].counter == activityNo[5];
      }
      break;

    case 9:
      if (fullpack[k].batch!.isEmpty) {
        // Tanpa batch → cukup cocokkan bOMItem + counter
        isMatch = (fullpack[k].bOMItem == activityNo[3] &&
                   fullpack[k].counter == activityNo[6]);
      } else {
        // Dengan batch → harus cocok juga batchnya
        isMatch = (fullpack[k].bOMItem == activityNo[3] &&
                   fullpack[k].counter == activityNo[6] &&
                   int.parse(fullpack[k].batch!) == int.parse(activityNo[8]));
      }
      break;

    case 10:
      if (fullpack[k].batch!.isEmpty) {
        isMatch = (fullpack[k].bOMItem == activityNo[3] &&
                   fullpack[k].counter == activityNo[6]);
      } else {
        // 10-segment: ada materialDoc tambahan
        isMatch = (fullpack[k].bOMItem == activityNo[3] &&
                   fullpack[k].counter == activityNo[6] &&
                   int.parse(fullpack[k].batch!) == int.parse(activityNo[8]) &&
                   fullpack[k].materialDoc == activityNo[9]); // ← extra field
      }
      break;
  }

  if (fullpack[k].isScannedFullpack || fullpack[k].handoverFlag == 'X') {
    if (isMatch) { errorType = ErrorScanType.dataScanned; break; } // ❌ Sudah discan
    continue;
  }

  if (fullpack[k].scanFlag == "" || fullpack[k].handoverFlag == '') {
    // Validasi priority urutan scan
    if (lastPrioEmpty != "" && lastPrioEmpty != fullpack[k].priority) {
      errorType = ErrorScanType.incorrectPriority; // ❌ Priority tidak urut
      break;
    }
    lastPrioEmpty = fullpack[k].priority;
    if (isMatch) {
      fullpack[k] = fullpack[k].copyWith(isScannedFullpack: true); // ✅ Terscan
      completedFullpack++;
      errorType = ErrorScanType.noError;
      break;
    }
  }
}
```

#### D. Matching MaterialSet (tab mixing/material biasa) — berdasarkan panjang barcode

```dart
// handover_cubit.dart:233-300
for (var k = 0; k < materialSets.length; k++) {
  switch (activityNo.length) {
    case 5:
      // Format pendek: matching activityNo + priority (full barcode string)
      isMatch = materialSets[k].activityNo == activityNo[1] &&
                materialSets[k].priority == scannedBarcode;
      break;
    case 6:
      // Format 6-segment: matching bOMItem + recipient harus "W"
      isMatch = materialSets[k].bOMItem == activityNo[3] &&
                materialSets[k].recipient == "W";
      break;
    case 7:
      // Format 7-segment: matching activityDmp + counter + activityWh
      isMatch = materialSets[k].activityDmp == activityNo[2] &&
                materialSets[k].counter == activityNo[5] &&
                materialSets[k].activityWh == activityNo[6];
      break;
    case 9:
      if (materialSets[k].batch.isEmpty) {
        isMatch = (materialSets[k].bOMItem == activityNo[3] &&
                   materialSets[k].counter == activityNo[6]);
      } else {
        isMatch = (materialSets[k].bOMItem == activityNo[3] &&
                   materialSets[k].counter == activityNo[6] &&
                   int.parse(materialSets[k].batch) == int.parse(activityNo[8]));
      }
      break;
    case 10:
      if (materialSets[k].batch.isEmpty) {
        isMatch = (materialSets[k].bOMItem == activityNo[3] &&
                   materialSets[k].counter == activityNo[6]);
      } else {
        isMatch = (materialSets[k].bOMItem == activityNo[3] &&
                   materialSets[k].counter == activityNo[6] &&
                   int.parse(materialSets[k].batch) == int.parse(activityNo[8]) &&
                   materialSets[k].materialDoc == activityNo[9]);
      }
      break;
  }

  if (materialSets[k].scanFlag == "X") {
    if (isMatch) { errorType = ErrorScanType.dataScanned; break; } // ❌ Sudah discan
    continue;
  }
  if (materialSets[k].scanFlag == "") {
    if (isMatch) {
      materialSets[k] = materialSets[k].copyWith(isScanned: true); // ✅ Terscan
      completedMaterialset++;
      errorType = ErrorScanType.noError;
      break;
    }
  }
}
```

#### E. Kalkulasi Status Completion

```dart
// handover_cubit.dart:309-328 — setelah loop scan selesai
var isCompleted         = tongs.isNotEmpty && completed == tongs.length;
var isCompletedFullpack = fullpack.isNotEmpty && completedFullpack == fullpack.length;
var isCompletedMaterial = materialSets.isNotEmpty && completedMaterialset == materialSets.length;

emit(state.copyWith(
  isCompletedcontainer: isCompleted,                      // semua tong selesai
  isComplete: isCompleted && isCompletedFullpack,          // tong + fullpack selesai
  isCompleteTong: isCompleted && isCompletedFullpack && isCompletedMaterial, // semua selesai
  isCompleteMaterials: isCompletedMaterial && completedMaterialset != 0,
  isCompleteWeighingResults: isCompletedFullpack,
  errorScanType: errorType,
));
```

---

### ④ Kondisi Tombol Bottom Bar — scan_tong.dart

> Baris **378–641** — empat state berbeda untuk tombol bottom bar.

```dart
// Kondisi 1: Ada fullpack (berdasarkan BOM)
if (handoverState.fullpack.isNotEmpty) {
  if (handoverState.isComplete) {
    // ✅ Semua tong + fullpack selesai → tampil tombol "Save" + "Next Process"
    Row([ButtonSave(), ButtonNextProcess()])
  } else {
    // ⏳ Belum selesai → tampil tombol "Scan Barcode"
    ButtonScanBarcode()
  }
} else {
  // Kondisi 2: Tidak ada fullpack (tong biasa tanpa BOM detail)
  if (handoverState.isCompletedcontainer) {
    // ✅ Semua tong selesai → tampil tombol "Save" + "Next Process"
    Row([ButtonSave(), ButtonNextProcess()])
  } else {
    // ⏳ Belum selesai → tampil tombol "Scan Barcode"
    ButtonScanBarcode()
  }
}
```

#### Setelah Submit Berhasil

```dart
// scan_tong.dart:154-172 & scan_tong_results_weighing.dart:137-155
if (state is SubmitHandoverLoaded) {
  if (state.submitHandover == 'success') {
    showSnackBar("Send data successfully", Colors.black);

    if (_handoverCubit.state.isNext) {
      // ✅ User tekan "Next Process" → reset fullpack/wadah & pindah ke scantongmaterial
      Future.delayed(Duration(seconds: 2), () {
        _handoverCubit.resetFullpackWadah();
        _handoverCubit.setTab(HandoverStatus.scantongmaterial);
      });
    } else {
      // ✅ User tekan "Save" → reset fullpack/wadah & kembali ke halaman handover
      _handoverCubit.resetFullpackWadah();
      _handoverCubit.setTab(HandoverStatus.handover);
    }
  }
} else if (state is SubmitHandoverError) {
  showSnackBar(state.error, Colors.red); // ❌ Error dari SAP
}
```

---

### ⑤ Kondisi Tombol Bottom Bar — scan_tong_results_weighing.dart

> Baris **449–733** — kondisi lebih kompleks karena ada tiga state berbeda.

```dart
if (isLoading) {
  // ⏳ Sedang mengirim data FlagHandover ke API → tombol disabled + loading indicator
  ButtonDisabled("Sending scanned data")

} else if (handoverState.operationType == 'CB') {
  // Mode CB: semua fullpack harus sudah di-flag ("X") DAN line harus ada
  if (fullpack.where((item) => item.handoverFlag == 'X').length == fullpack.length
      && line.text.isNotEmpty) {
    // ✅ Semua fullpack ter-flag & line ada → "Complete" (submit)
    ButtonComplete(onPressed: () => submitHandoverBloc.add(SubmitHandover(...)))

  } else if (fullpack.where((item) => item.handoverFlag == 'X').isEmpty) {
    // ❌ Belum ada satu pun yang di-flag → hanya bisa scan barcode
    ButtonScanBarcode()

  } else {
    // 🔄 Sebagian sudah di-flag → tampil "Scan Barcode" + "Save" berdampingan
    Row([ButtonScanBarcode(), ButtonSave()])
  }

} else {
  // Mode selain CB: kondisi sama — semua fullpack harus di-flag & line ada
  if (fullpack.where((item) => item.handoverFlag == 'X').length == fullpack.length
      && line.text.isNotEmpty) {
    // ✅ Semua selesai → "Complete"
    ButtonComplete()
  } else {
    // ⏳ Belum selesai → "Scan Barcode"
    ButtonScanBarcode()
  }
}
```

---

### ⑥ BlocListener HandoverFlagBloc — scan_tong_results_weighing.dart

> Baris **172–202** — alur setelah flag scan dikirim ke API.

```dart
// scan_tong_results_weighing.dart:172-202
BlocListener<HandoverFlagBloc, HandoverFlagState>(
  listener: (context, state) {
    if (state is HandoverFlagLoading) {
      // ⏳ Sedang mengirim flag ke API → tampilkan loading di tombol
      setState(() => isLoading = true);

    } else if (state is HandoverFlagLoaded) {
      // ✅ Flag berhasil → ambil data WadahSet baru dari API
      setState(() => isLoading = false);
      wadahSetBloc.add(GetWadahSet(
          routingNo,
          tongs[0].activityNo,
          operationType));

    } else if (state is HandoverFlagError) {
      // ❌ Flag gagal → tampilkan error & matikan loading
      setState(() => isLoading = false);
      showSnackBar(state.error, Colors.red);

    } else {
      // State lain (initial, dll) → matikan loading
      setState(() => isLoading = false);
    }
  },
),
```

---

### ⑦ BlocListener WadahSetBloc — scan_tong_results_weighing.dart

> Baris **204–226** — setelah data WadahSet diterima dari API.

```dart
// scan_tong_results_weighing.dart:204-226
BlocListener<WadahSetBloc, WadahSetState>(
  listener: (context, state) {
    if (state is WadahSetLoaded) {
      // ✅ Data wadah baru diterima → update state dan navigasi ke tab ScanTongResultsWeighing
      _handoverCubit.setResultTong(state.wadahSet.d!.resultsTong!);

      // Kumpulkan semua fullpack dari tiap tong
      List<ResultsFullPack> fullpacks = [];
      for (var fullpack in state.wadahSet.d!.resultsTong!) {
        if (fullpack.wadToMatNav!.resultsFullPack != null) {
          fullpacks.addAll(fullpack.wadToMatNav!.resultsFullPack!);
        }
      }
      _handoverCubit.setFullpack(fullpacks);
      _handoverCubit.setTab(HandoverStatus.scanTongResultsWeighing);
      _handoverCubit.setPrevTab(HandoverStatus.chooseLocation);

    } else if (state is WadahSetError) {
      // ❌ Gagal ambil data → tampilkan error
      showSnackBar(state.error, Colors.red);
    }
  },
),
```

---

### ⑧ Validasi yang Perlu Dipindahkan ke API (Handover & Mixing)

| # | Field / Kondisi | Validasi |
|---|---|---|
| V1 | `OperationApps` | Harus salah satu dari `31`, `32`, `33`, `34`, `45` sesuai `OperationType` |
| V2 | Barcode tong — panjang segment | Jika panjang `< 4` → reject; jika 4 → non-DECOCT; jika 5 → DECOCT |
| V3 | Priority scan fullpack | Barcode harus discan berurutan sesuai priority; jangan skip priority |
| V4 | `handoverFlag == 'X'` | API harus memvalidasi bahwa fullpack yang dikirim belum pernah di-flag |
| V5 | `bOMItem` + `counter` + `batch` | Barcode fullpack harus cocok dengan kombinasi field ini di SAP |
| V6 | `isNext` flag | API tidak bisa validasi ini — murni logika navigasi mobile (OK tetap di mobile) |
| V7 | Semua tong sudah scan | Jika submit, API bisa validasi `completedContainer == totalContainer` |

---

## 4. ✅ Validasi Confirmation


**File:** `lib/screen/confirmation/widgets/confirmation.dart`
**File Form:** `lib/screen/confirmation/widgets/form_confirmation.dart`

### 4a. Validasi Form Awal — Pilih Order

| # | Field | Validasi | Kode |
|---|---|---|---|
| 1 | `Plant` | Tidak boleh kosong | `confirmation.dart:409` |
| 2 | `Material Code` | Tidak boleh kosong | `confirmation.dart:411` |
| 3 | `Operation Type` | Wajib dipilih | `confirmation.dart:410` |
| 4 | `Batch` | Tidak boleh kosong | `confirmation.dart:412` |

---

### 4b. Validasi Form Confirmation — Input Data

| # | Field | Validasi | Kode |
|---|---|---|---|
| 1 | `Line` (Scan Barcode) | Wajib diisi untuk aktifkan tombol "Confirm" | `form_confirmation.dart:341` |
| 2 | `Batch` panjang | Jika > 5 karakter, trigger API fetch operation type | `confirmation.dart:293` |
| 3 | `Reason` | Opsional, jika diisi dipecah tiap 132 karakter | `form_confirmation.dart:659` |

---

### 4c. Submit Confirmation

**Provider:** `lib/provider/submit_confirmation.dart`

#### Endpoint
```
POST {baseUrl}/ZDMP_POST_WEIGHT_SRV/YieldSet
```

#### Request Body
```json
{
  "RoutingNo": "string",
  "InternalCntr": "string",
  "OrderNo": "string",
  "ActivityNo": "string",
  "YieldQty": "string (numeric)",
  "UnitYield": "string",
  "StartDateOpr": "string (date dari SAP)",
  "StartTimeOpr": "string (time dari SAP)",
  "StartDateConf": "string (yyyyMMdd)",
  "StartTimeConf": "string (HHmmss)",
  "FinishDate": "string (yyyyMMdd)",
  "FinishTime": "string (HHmmss)",
  "Line": "string",
  "PostDate": "string (yyyyMMdd)",
  "MachineHour": "string (numeric)",
  "LaborHour": "string (numeric, MachineHour x JumlahLabor)",
  "OperationApps": "string",
  "Operator": "string (NRP dari auth)",
  "Pengawas": "string (NRP dari auth)",
  "YieldToLinesNav": [
    { "Text": "string (max 132 char per item)" }
  ]
}
```

#### Validasi yang Perlu Dipindahkan ke API

| # | Field | Validasi |
|---|---|---|
| V1 | `OrderNo` | Harus valid di SAP |
| V2 | `ActivityNo` | Harus sesuai dengan routing order |
| V3 | `YieldQty` | Harus numeric, > 0 |
| V4 | `MachineHour` | Harus numeric, > 0 |
| V5 | `LaborHour` | Harus numeric, hasil dari `MachineHour x NumberOfLabor` |
| V6 | `Line` | Tidak boleh kosong |
| V7 | `Operator`, `Pengawas` | Harus NRP valid dengan title sesuai |
| V8 | `YieldToLinesNav[].Text` | Tiap item max 132 karakter |

---

## 5. 🚩 Validasi Flag Materials (Scan Tong)

**File:** `lib/provider/flag_scan_provider.dart`

#### Endpoint
```
POST {baseUrl}/ZDMP_POST_ORDER_SRV/MaterialFlagSet
```

#### Validasi di Mobile

| # | Validasi | Keterangan |
|---|---|---|
| 1 | Connection timeout | Jika timeout → `"Request Timeout, check your connection and please try again!"` |
| 2 | Response status == 201 | Jika bukan 201 → return `'error'` |

#### Validasi yang Perlu Dipindahkan ke API

| # | Field | Validasi |
|---|---|---|
| V1 | Material/Tong barcode | Harus terdaftar di sistem |
| V2 | Order relevan | Material harus berkaitan dengan order yang aktif |

---

## 6. 📊 Ringkasan Semua Endpoint & Validasi

| # | Flow | Endpoint | Method | Validasi Mobile Saat Ini | Prioritas Migrasi |
|---|---|---|---|---|---|
| 1 | User Validation | `/ZDMP_GET_MATERIAL_SRV/FImp_User` | GET | NRP valid, title match, plant match | 🔴 Tinggi |
| 2 | Get Materials | `/ZDMP_GET_MATERIAL_SRV/...` | GET | Plant wajib ada | 🟡 Sedang |
| 3 | Get Operation Type | *(endpoint internal)* | GET | Material + Plant + Batch wajib ada | 🟡 Sedang |
| 4 | Get Orders | *(endpoint internal)* | GET | Plant + Material + OpType + Batch wajib ada | 🟡 Sedang |
| 5 | Submit Weighing | `/ZDMP_POST_WEIGHT_SRV/WeighingSet` | POST | Field per operationType, Bruto/Tara/Netto, date valid | 🔴 Tinggi |
| 6 | Submit Handover | `/ZDMP_POST_ORDER_SRV/OrderSet` | POST | Plant, material, batch, NRP operator/pengawas, Line | 🔴 Tinggi |
| 7 | Submit Confirmation | `/ZDMP_POST_WEIGHT_SRV/YieldSet` | POST | Line wajib, MachineHour > 0, NRP valid, Reason max 132/item | 🔴 Tinggi |
| 8 | Flag Materials | `/ZDMP_POST_ORDER_SRV/MaterialFlagSet` | POST | Barcode valid, order relevan | 🟢 Rendah |

---

## 7. 🔄 Logika Bisnis yang Dihitung di Mobile

Berikut adalah logika kalkulasi di mobile yang **sebaiknya juga bisa divalidasi atau dihitung ulang di API**:

### Expired Date/Time (Weighing)
```dart
// submit_weighing_bloc.dart:36-47
if (expiredNo != '0') {
  if (unit == 'DAY') {
    expiredDate = startWork + Duration(days: int(expiredNo));
  } else {
    expiredDate = startWork + Duration(hours: int(expiredNo));
  }
}
```
**Saran API:** API bisa menghitung ulang dan memvalidasi `ExpiredDate`/`ExpiredTime` berdasarkan `expiredSet` yang tersimpan di backend.

### Labor Hour (Confirmation)
```dart
// form_confirmation.dart:83-84 & 435-436
laborHour = machineHour * numberOfLabor;
```
**Saran API:** API bisa memvalidasi bahwa `LaborHour` yang dikirim = `MachineHour x NumberOfLabor`.

### Container Counter (Weighing)
```dart
// scale_weighing.dart:250-252
// containerCounter harus <= totalContainer
```
**Saran API:** API bisa menolak submit jika `Wadah > TotalWadah`.

### Temperature Format (DECOCT)
```dart
// format: "tempStart;tempEnd"
temperature = '$tempStart;$tempEnd'
```
**Saran API:** API bisa memvalidasi format temperature dengan separator `;`.

---

## 8. 📝 Catatan Implementasi

> **PENTING:** Field `Operator` dan `Pengawas` yang dikirim ke semua endpoint POST adalah **NRP** (bukan nama), diambil dari `AuthBloc` state setelah proses scan di `ValidationScreen`.

> **CATATAN:** Format tanggal yang digunakan konsisten: `yyyyMMdd` untuk date dan `HHmmss` untuk time di semua endpoint POST.

> **PERHATIAN:** Endpoint SAP OData menggunakan **x-csrf-token** dan **Cookie** untuk operasi POST. Token ini di-refresh setiap kali ada operasi POST via `AuthProvider().loginWithToken()`.

> **TIPS:** Validasi yang paling kritis untuk dipindahkan pertama kali adalah validasi **NRP User** (endpoint FImp_User) dan validasi **field wajib pada Submit Weighing/Handover/Confirmation** karena ini langsung berpengaruh ke data SAP.
