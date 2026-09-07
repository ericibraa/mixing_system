const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const OUTPUT_DIR = path.join(__dirname, 'images');
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

const diagrams = [
  {
    id: '01_end_to_end_flowchart',
    title: '1. High-Level End-to-End System Flowchart',
    category: 'System Overview',
    code: `flowchart TD
    Start(["Mulai Aplikasi"]) --> InitConfig["Inisialisasi Config (Dev/Prod) & DioClient"]
    InitConfig --> CheckAuth{"Cek Token & Auth State?"}
    
    CheckAuth -- "Tidak Ada Token" --> ScreenLogin["Tampilan Login (Input SAP User/Pass)"]
    ScreenLogin --> DoLogin["Kirim Request Login Basic Auth"]
    DoLogin --> SaveToken["Simpan Token & Cookie SAP"]
    SaveToken --> ScreenHome
    
    CheckAuth -- "Token Valid" --> ScreenHome["HomeScreen (Pilih Menu)"]
    
    ScreenHome --> Choice{"Pilih Modul Transaksi"}
    
    Choice -- "Weighing" --> ResetAuthW["Reset Temp User & Buka ValidationScreen (/weighing)"]
    Choice -- "Handover" --> ResetAuthH["Reset Temp User & Buka ValidationScreen (/handover)"]
    Choice -- "Handover & Mixing" --> ResetAuthHM["Reset Temp User & Buka ValidationScreen (/handover-mixing)"]
    Choice -- "Confirmation" --> ResetAuthC["Reset Temp User & Buka ValidationScreen (/confirmation)"]
    
    subgraph Gatekeeper ["Gerbang Validasi Personel (Validation Screen)"]
        ResetAuthW & ResetAuthH & ResetAuthHM --> ScanDual["Scan NRP Operator & Scan NRP Pengawas"]
        ResetAuthC --> ScanSingle["Scan NRP Pengawas (Operator Opsional)"]
        
        ScanDual --> ValAPI1["Cek SAP: FImp_User (Operator & Pengawas)"]
        ScanSingle --> ValAPI2["Cek SAP: FImp_User (Pengawas)"]
        
        ValAPI1 --> CheckDual{"Keduanya Valid & Sesuai Title?"}
        ValAPI2 --> CheckSingle{"Pengawas Valid?"}
        
        CheckDual -- "Tidak" --> ErrorDual["Tampilkan 'Invalid Operator/Pengawas'"] --> ScanDual
        CheckSingle -- "Tidak" --> ErrorSingle["Tampilkan 'Invalid Pengawas'"] --> ScanSingle
    end

    CheckDual -- "Ya" --> RouteToModule{"Arahkan ke Modul"}
    CheckSingle -- "Ya" --> ModulConf["Modul Confirmation"]
    
    RouteToModule -- "/weighing" --> ModulWeigh["Modul Weighing"]
    RouteToModule -- "/handover" --> ModulHand["Modul Handover"]
    RouteToModule -- "/handover-mixing" --> ModulHandMix["Modul Handover & Mixing"]
    
    subgraph Execution ["Eksekusi Modul Operasional"]
        ModulWeigh --> FlowWeigh["Timbang Material -> Submit WeighingSet -> Cetak Label ZPL"]
        ModulHandMix --> FlowHM["Scan Tong -> Scan Fullpack -> Flag Material -> Submit OrderSet"]
        ModulHand --> FlowH["Pilih Order -> Verifikasi Item -> Submit OrderSet"]
        ModulConf --> FlowC["Input Yield -> Jam Mesin/Labor -> Scan Line -> Submit YieldSet"]
    end
    
    FlowWeigh & FlowHM & FlowH & FlowC --> FinishTx["Transaksi Selesai & Data Tersimpan di SAP"]
    FinishTx --> ReturnHome["Kembali ke HomeScreen / Form Reset"]
    ReturnHome --> End(["Selesai"])`
  },
  {
    id: '02_user_validation_flowchart',
    title: '2. Flowchart: Validasi Personel (NRP Scan)',
    category: 'User Validation',
    code: `flowchart TD
    StartVal(["Mulai Validasi Personel"]) --> InitScreen["Tampilkan ValidationScreen"]
    InitScreen --> ScanOp["Operator Scan Barcode Badge / Input NRP"]
    
    ScanOp --> ReqOp["Kirim GET /ZDMP_GET_MATERIAL_SRV/FImp_User<br/>Params: Nrp='...', Title='OPERATOR'"]
    ReqOp --> RespOp{"Response Valid & results.length > 0?"}
    
    RespOp -- "Tidak" --> ErrOp["Tampilkan Snackbar 'Invalid Operator'"] --> ScanOp
    RespOp -- "Ya" --> SaveOp["Simpan Operator (NRP, Nama, Werks) ke State"]
    
    SaveOp --> CheckTarget{"Target Rute Modul?"}
    
    CheckTarget -- "/confirmation" --> CheckPengawasNeeded{"Perlu Scan Pengawas?"}
    CheckTarget -- "Lainnya (/weighing, /handover*)" --> ForcePengawas["Wajib Scan Pengawas"]
    
    ForcePengawas --> ScanSpv["Pengawas Scan Barcode Badge / Input NRP"]
    CheckPengawasNeeded --> ScanSpv
    
    ScanSpv --> ReqSpv["Kirim GET /ZDMP_GET_MATERIAL_SRV/FImp_User<br/>Params: Nrp='...', Title='PENGAWAS'"]
    ReqSpv --> RespSpv{"Response Valid & results.length > 0?"}
    
    RespSpv -- "Tidak" --> ErrSpv["Tampilkan Snackbar 'Invalid Pengawas'"] --> ScanSpv
    RespSpv -- "Ya" --> SaveSpv["Simpan Pengawas (NRP, Nama, Werks) ke State"]
    
    SaveSpv --> EnableBtn["Aktifkan Tombol Lanjutkan (Next)"]
    EnableBtn --> ClickNext["User Tekan Tombol Lanjutkan"]
    ClickNext --> RouteTarget["Navigasi ke Halaman Tujuan (Router.push)"]
    RouteTarget --> EndVal(["Selesai Validasi"])`
  },
  {
    id: '03_user_validation_sequence',
    title: '3. Sequence Diagram: Validasi Personel (NRP Scan)',
    category: 'User Validation',
    code: `sequenceDiagram
    autonumber
    actor OP as Operator
    actor SPV as Pengawas
    participant UI as ValidationScreen (Flutter)
    participant Bloc as ValidationBloc
    participant Repo as ValidationProvider / DioClient
    participant SAP as SAP OData (FImp_User)

    Note over OP,UI: 1. Validasi Operator
    OP->>UI: Scan Barcode Badge NRP Operator
    UI->>Bloc: add(ValidationOperatorEvent(nrp, 'OPERATOR'))
    Bloc->>Repo: getUserValidation(nrp, 'OPERATOR')
    Repo->>SAP: GET /ZDMP_GET_MATERIAL_SRV/FImp_User?Nrp='{nrp}'&Title='OPERATOR'
    alt NRP Operator Valid di SAP
        SAP-->>Repo: 200 OK (results: [{Nrp, Title, Werks, Name}])
        Repo-->>Bloc: Data User Ditemukan
        Bloc-->>UI: State: OperatorLoaded (Tampilkan Nama Operator, Check Hijau)
    else NRP Tidak Terdaftar / Title Salah
        SAP-->>Repo: 200 OK (results: []) / 400 Error
        Repo-->>Bloc: User Not Found
        Bloc-->>UI: State: ValidationError("Invalid Operator")
        UI-->>OP: Notifikasi Error di Layar
    end

    Note over SPV,UI: 2. Validasi Pengawas
    SPV->>UI: Scan Barcode Badge NRP Pengawas
    UI->>Bloc: add(ValidationPengawasEvent(nrp, 'PENGAWAS'))
    Bloc->>Repo: getUserValidation(nrp, 'PENGAWAS')
    Repo->>SAP: GET /ZDMP_GET_MATERIAL_SRV/FImp_User?Nrp='{nrp}'&Title='PENGAWAS'
    alt NRP Pengawas Valid di SAP
        SAP-->>Repo: 200 OK (results: [{Nrp, Title, Werks, Name}])
        Repo-->>Bloc: Data Pengawas Ditemukan
        Bloc-->>UI: State: PengawasLoaded (Tampilkan Nama Pengawas, Check Hijau)
        UI->>UI: Update Button State (Enable Tombol Lanjutkan)
    else NRP Pengawas Tidak Terdaftar
        SAP-->>Repo: 200 OK (results: []) / 400 Error
        Repo-->>Bloc: User Not Found
        Bloc-->>UI: State: ValidationError("Invalid Pengawas")
        UI-->>SPV: Notifikasi Error di Layar
    end

    OP->>UI: Tekan Tombol "Lanjutkan"
    UI->>UI: Simpan NRP Operator & Pengawas di Global Context
    UI->>UI: Navigasi ke Modul Transaksi (Weighing / Handover / Confirmation)`
  },
  {
    id: '04_weighing_flowchart',
    title: '4. Flowchart: Modul Weighing (Penimbangan)',
    category: 'Weighing',
    code: `flowchart TD
    StartW(["Mulai Modul Weighing"]) --> FormPilih["Form Pilih: Plant, Material Code, Operation Type, Batch"]
    FormPilih --> FetchOrders["Ambil List Order dari SAP (GetOrderWeighing)"]
    FetchOrders --> SelectOrder["Pilih Order & Wadah (Container)"]
    SelectOrder --> ScanScale["Scan Barcode Equipment Timbangan (Scale ID)"]
    
    ScanScale --> CheckEquip{"Equipment Valid di Master SAP?"}
    CheckEquip -- "Tidak" --> ErrEquip["Error: 'Timbangan Tidak Dikenal'"] --> ScanScale
    CheckEquip -- "Ya" --> GetScaleNet["Dapatkan IP Address & Port Timbangan"]
    
    GetScaleNet --> ModeCheck{"Mode Pembacaan?"}
    
    ModeCheck -- "TCP Socket" --> ConnectTCP["Socket.connect(scaleIp, scalePort, timeout: 5s)"]
    ConnectTCP --> ListenTCP{"Koneksi Berhasil?"}
    ListenTCP -- "Gagal" --> ManualPrompt["Tampilkan Error & Switch ke Manual Input"]
    ListenTCP -- "Sukses" --> StreamWeight["Stream Data Bobot Realtime dari Timbangan"]
    
    ModeCheck -- "Manual Input" --> ManualPrompt
    ManualPrompt --> InputMan["Operator Input Angka Bobot Manual"]
    
    StreamWeight & InputMan --> StepTara["1. Timbang Wadah Kosong (Bobot Tara)"]
    StepTara --> StepBruto["2. Timbang Wadah + Isi Material (Bobot Bruto)"]
    StepBruto --> CalcNetto["3. Hitung Netto: Netto = Bruto - Tara"]
    
    CalcNetto --> ValidateTolerance{"Netto Sesuai Target & Toleransi SAP?"}
    ValidateTolerance -- "Di Luar Toleransi" --> WarnTol["Peringatan: Bobot melebihi batas toleransi!"]
    WarnTol --> OperatorOverride{"Izinkan Lanjut?"}
    OperatorOverride -- "Ulangi" --> StepTara
    
    OperatorOverride -- "Lanjut" --> CheckOpType{"Operation Type == 'DECOCT'?"}
    ValidateTolerance -- "Sesuai" --> CheckOpType
    
    CheckOpType -- "Ya" --> InputTemp["Input Suhu Awal & Suhu Akhir (Format: 'T1;T2')"]
    CheckOpType -- "Tidak" --> CalcExp["Hitung Expired Date/Time dari ExpiredSet"]
    InputTemp --> CalcExp
    
    CalcExp --> ReadySubmit["Validasi Data Lengkap (Button Submit Aktif)"]
    ReadySubmit --> SubmitSAP["Kirim POST /ZDMP_POST_WEIGHT_SRV/WeighingSet"]
    
    SubmitSAP --> CheckSubmit{"Submit Berhasil (201 Created)?"}
    CheckSubmit -- "Gagal" --> ShowErr["Tampilkan Pesan Error dari SAP"] --> ReadySubmit
    CheckSubmit -- "Sukses" --> GenZPL["Generate ZPL Data Template Barcode"]
    
    GenZPL --> PrintPrompt["Kirim Print Command ke Printer Zebra (TCP Port 9100)"]
    PrintPrompt --> PrintResult{"Label Tercetak?"}
    PrintResult -- "Gagal" --> RetryPrint["Munculkan Tombol 'Reprint Label'"]
    PrintResult -- "Sukses" --> NextContainer{"Masih Ada Wadah Berikutnya?"}
    RetryPrint --> NextContainer
    
    NextContainer -- "Ya (Wadah < Total)" --> IncWadah["Wadah = Wadah + 1"] --> StepTara
    NextContainer -- "Selesai (Wadah == Total)" --> FinishW(["Order Penimbangan Selesai"])`
  },
  {
    id: '05_weighing_sequence',
    title: '5. Sequence Diagram: Weighing & Cetak Label',
    category: 'Weighing',
    code: `sequenceDiagram
    autonumber
    actor OP as Operator / Pengawas
    participant UI as ScaleWeighing UI
    participant Bloc as WeighingBloc / SubmitWeighingBloc
    participant Scale as Digital Scale (TCP Socket)
    participant SAP as SAP OData (WeighingSet)
    participant Printer as Zebra Label Printer (TCP 9100)

    Note over OP,Scale: 1. Koneksi & Pembacaan Timbangan
    OP->>UI: Scan Barcode Equipment Timbangan
    UI->>UI: Parse Equipment No & Ambil IP/Port Timbangan
    UI->>Scale: Socket.connect(ip, port, timeout: 5s)
    alt Socket Berhasil Konek
        Scale-->>UI: Socket Connected (Stream byte data)
        loop Pembacaan Kontinu
            Scale->>UI: Raw Data Stream (misal: "ST, GS, +0012.45 kg")
            UI->>UI: Regex parsing -> Ekstrak angka berat (12.45)
            UI->>UI: Tampilkan bobot live di layar timbang
        end
    else Koneksi Gagal / Timeout
        Scale-->>UI: Connection Refused / Timeout
        UI->>UI: Fallback ke mode Input Manual
    end

    Note over OP,UI: 2. Timbang Tara & Bruto
    OP->>UI: Letakkan wadah kosong -> Tekan "Set Tara"
    UI->>UI: tara = currentWeight (misal: 2.10 kg)
    OP->>UI: Tuang bahan ke wadah -> Tekan "Set Bruto"
    UI->>UI: bruto = currentWeight (misal: 25.50 kg)
    UI->>UI: netto = bruto - tara (23.40 kg)

    Note over OP,SAP: 3. Submit Hasil Penimbangan
    OP->>UI: Tekan Tombol "Submit Weighing"
    UI->>Bloc: add(SubmitWeighingEvent(OrderNo, Batch, Tara, Bruto, Netto, Operator, Pengawas, ExpiredDate))
    Bloc->>SAP: POST /ZDMP_POST_WEIGHT_SRV/WeighingSet (Header: X-CSRF-Token)
    SAP-->>Bloc: 201 Created (Weighing Doc No, Status: Success)
    Bloc-->>UI: State: SubmitWeighingSuccess

    Note over UI,Printer: 4. Cetak Label Identitas Wadah (ZPL)
    UI->>UI: Generate format ZPL (^XA^FO...^FD{Batch,Order,Netto}^FS^XZ)
    UI->>Printer: Socket.connect(printerIp, 9100)
    Printer-->>UI: Connected
    UI->>Printer: socket.add(utf8.encode(zplString))
    UI->>Printer: socket.flush() & socket.close()
    Printer-->>OP: Cetak Fisik Label Barcode Wadah
    UI-->>OP: Dialog "Penimbangan Berhasil, Label Dicetak!"`
  },
  {
    id: '06_handover_mixing_flowchart',
    title: '6. Flowchart: Modul Handover & Mixing',
    category: 'Handover & Mixing',
    code: `flowchart TD
    StartHM(["Mulai Handover & Mixing"]) --> SelectOrderHM["Pilih Plant, Material, Operation Type, & Batch"]
    SelectOrderHM --> MapOpApps["Mapping OperationType -> OperationApps (31, 32, 33, 34, 45)"]
    MapOpApps --> FetchWadah["Ambil Data Wadah: GetWadahSet(RoutingNo, ActivityNo)"]
    
    FetchWadah --> DisplayTongs["Tampilkan Daftar Wadah & Daftar Material/Fullpack"]
    DisplayTongs --> WaitScan["Menunggu Operator Scan Barcode"]
    
    WaitScan --> DetectType{"Jenis Barcode yang Discan?"}
    
    DetectType -- "Barcode Tong / Wadah" --> CheckTongFormat{"Format Tong Sesuai (Split length >= 4)?"}
    CheckTongFormat -- "Salah" --> ErrTong["Error: 'Format Barcode Tong Tidak Valid'"] --> WaitScan
    CheckTongFormat -- "Valid" --> MatchTong{"Tong Cocok dengan Daftar Order?"}
    MatchTong -- "Tidak" --> ErrMatchT["Error: 'Tong Bukan Bagian dari Order Ini'"] --> WaitScan
    MatchTong -- "Cocok" --> SetTongActive["Set Wadah Aktif & Tampilkan Komponen Bahan"] --> WaitScan
    
    DetectType -- "Barcode Bahan / Fullpack" --> CheckTongSelected{"Apakah Tong Sudah Dipilih?"}
    CheckTongSelected -- "Belum" --> WarnTongFirst["Peringatan: 'Silakan Scan Barcode Tong Terlebih Dahulu!'"] --> WaitScan
    CheckTongSelected -- "Sudah" --> CheckPriority{"Cek Urutan Prioritas BOM (Sequence)?"}
    
    CheckPriority -- "Melompat (Skip Priority)" --> ErrPrio["Error: 'Bahan Harus Discan Berurutan Sesuai Prioritas!'"] --> WaitScan
    CheckPriority -- "Urutan Benar" --> MatchBOM{"Cocok: BOMItem + Counter + Batch?"}
    
    MatchBOM -- "Tidak Cocok" --> ErrBOM["Error: 'Bahan Tidak Sesuai Spesifikasi Wadah Ini'"] --> WaitScan
    MatchBOM -- "Cocok" --> CheckFlagged{"Apakah Bahan Sudah Pernah Di-flag?"}
    CheckFlagged -- "Sudah (flag == 'X')" --> WarnFlagged["Peringatan: 'Bahan Ini Sudah Discan Sebelumnya'"] --> WaitScan
    
    CheckFlagged -- "Belum" --> SendFlagSAP["Kirim POST /ZDMP_POST_ORDER_SRV/MaterialFlagSet"]
    SendFlagSAP --> FlagResult{"Flag Berhasil (201)?"}
    FlagResult -- "Gagal" --> ErrFlag["Tampilkan Error & Rollback State"] --> WaitScan
    FlagResult -- "Sukses" --> ReloadWadah["Panggil Ulang GetWadahSet untuk Sinkronisasi State"]
    
    ReloadWadah --> UpdateUI["Update Checklist Material di Layar (Hijau / Centang)"]
    UpdateUI --> CheckAllItems{"Semua Bahan di Tong Ini Selesai?"}
    
    CheckAllItems -- "Belum" --> WaitScan
    CheckAllItems -- "Ya" --> MarkTongComplete["Tandai Tong Selesai"]
    
    MarkTongComplete --> CheckAllTongs{"Semua Tong dalam Order Sudah Selesai?"}
    CheckAllTongs -- "Belum" --> NextTongPrompt["Pindah ke Wadah / Tong Berikutnya"] --> WaitScan
    
    CheckAllTongs -- "Semua Selesai" --> ScanLineHM["Scan Barcode Line / Mesin Tujuan"]
    ScanLineHM --> CheckLineHM{"Line Terisi?"}
    CheckLineHM -- "Belum" --> DisableSubmit["Tombol Complete Disabled"] --> ScanLineHM
    CheckLineHM -- "Sudah" --> EnableSubmitHM["Aktifkan Tombol 'Complete'"]
    
    EnableSubmitHM --> ClickSubmitHM["Operator Tekan 'Complete'"]
    ClickSubmitHM --> PostOrderSet["Kirim POST /ZDMP_POST_ORDER_SRV/OrderSet"]
    
    PostOrderSet --> ResOrderSet{"Response SAP Selesai?"}
    ResOrderSet -- "Gagal" --> ErrOrderSet["Tampilkan Error Submit Handover"] --> EnableSubmitHM
    ResOrderSet -- "Sukses" --> FinishHM(["Handover & Mixing Selesai"])`
  },
  {
    id: '07_handover_mixing_sequence',
    title: '7. Sequence Diagram: Handover & Mixing',
    category: 'Handover & Mixing',
    code: `sequenceDiagram
    autonumber
    actor OP as Operator
    participant UI as ScanTong / ScanTongResults UI
    participant Cubit as HandoverCubit
    participant FlagBloc as HandoverFlagBloc
    participant WadahBloc as WadahSetBloc
    participant SubmitBloc as SubmitHandoverBloc
    participant SAP as SAP OData Gateway

    Note over OP,UI: 1. Inisialisasi Data Wadah & BOM
    UI->>WadahBloc: add(GetWadahSet(routingNo, activityNo, opType))
    WadahBloc->>SAP: GET /ZDMP_POST_ORDER_SRV/WadahSet?$filter=...
    SAP-->>WadahBloc: 200 OK (resultsTong, resultsFullPack)
    WadahBloc-->>UI: State: WadahSetLoaded
    UI->>Cubit: setResultTong(tongs) & setFullpack(fullpacks)

    Note over OP,UI: 2. Scan Barcode Wadah (Tong)
    OP->>UI: Scan Barcode Tong Fisik
    UI->>Cubit: setScannedTong(scannedBarcode)
    Cubit->>Cubit: Validasi segment barcode (length >= 4) & match activityNo
    alt Tong Valid & Match
        Cubit-->>UI: State Updated (tongActive = scannedTong, status = OK)
        UI-->>OP: Highlight Wadah Aktif & Tampilkan Komponen Bahan
    else Tong Invalid / Bukan Bagian Order
        Cubit-->>UI: State Updated (errorScanType = 'invalid_tong')
        UI-->>OP: Dialog: "Tong tidak sesuai dengan Order!"
    end

    Note over OP,UI: 3. Scan Barcode Fullpack Material
    OP->>UI: Scan Barcode Bahan / Fullpack
    UI->>Cubit: setScannedFullpack(scannedBarcode)
    Cubit->>Cubit: Cek Priority sequence & matching BOMItem + Batch
    alt Bahan Valid & Sesuai Urutan
        Cubit-->>UI: Siap Flagging ke SAP
        UI->>FlagBloc: add(SendFlagMaterial(materialBarcode, orderNo))
        FlagBloc->>SAP: POST /ZDMP_POST_ORDER_SRV/MaterialFlagSet
        SAP-->>FlagBloc: 201 Created (Material Flagged 'X')
        FlagBloc-->>UI: State: HandoverFlagLoaded
        
        Note over UI,WadahBloc: Auto Refresh Data Wadah
        UI->>WadahBloc: add(GetWadahSet(routingNo, activityNo, opType))
        WadahBloc->>SAP: GET /ZDMP_POST_ORDER_SRV/WadahSet...
        SAP-->>WadahBloc: 200 OK (data wadah terupdate, item.handoverFlag == 'X')
        WadahBloc-->>UI: State: WadahSetLoaded (Item tercentang hijau)
    else Urutan Salah (Skip Priority) / Bahan Tidak Match
        Cubit-->>UI: State: Error (Priority Mismatch / Invalid Material)
        UI-->>OP: Snackbar: "Bahan harus discan sesuai urutan prioritas!"
    end

    Note over OP,UI: 4. Finalisasi & Submit Handover
    OP->>UI: Scan Barcode Line Tujuan (Line.text != '')
    UI->>UI: Cek: (completedFullpacks == totalFullpacks) && line.isNotEmpty
    UI->>UI: Aktifkan Tombol "Complete"
    OP->>UI: Tekan Tombol "Complete"
    UI->>SubmitBloc: add(SubmitHandover(OrderSetData))
    SubmitBloc->>SAP: POST /ZDMP_POST_ORDER_SRV/OrderSet
    SAP-->>SubmitBloc: 201 Created (Handover Confirmed in SAP)
    SubmitBloc-->>UI: State: SubmitHandoverSuccess
    UI-->>OP: Tampilkan Dialog Sukses & Kembali ke Menu Utama`
  },
  {
    id: '08_confirmation_flowchart',
    title: '8. Flowchart: Modul Confirmation',
    category: 'Confirmation',
    code: `flowchart TD
    StartC(["Mulai Modul Confirmation"]) --> SelectOrderC["Pilih: Plant, Material Code, Operation Type, & Batch"]
    SelectOrderC --> FetchOps["Ambil List Operation (Activity No) dari SAP"]
    FetchOps --> SelectOp["Pilih Operation Target"]
    
    SelectOp --> OpenFormConf["Buka FormConfirmation"]
    
    OpenFormConf --> InputYield["Input Yield Qty & Satuan (UnitYield)"]
    InputYield --> InputTime["Input Tanggal & Jam Mulai / Selesai (Start-Finish Date/Time)"]
    InputTime --> InputMachine["Input Jam Mesin (Machine Hour) & Jumlah Tenaga Kerja (Labor Count)"]
    
    InputMachine --> CalcLabor["Sistem Otomatis Menghitung:<br/>Labor Hour = Machine Hour * Labor Count"]
    
    CalcLabor --> InputPostDate["Input Tanggal Posting (Default: Hari Ini)"]
    InputPostDate --> InputReason{"Ada Catatan / Reason Tambahan?"}
    
    InputReason -- "Ya" --> SplitReason["Bagi Catatan Tiap 132 Karakter ke YieldToLinesNav"]
    InputReason -- "Tidak" --> ScanLineC
    SplitReason --> ScanLineC["Scan Barcode Line Produksi"]
    
    ScanLineC --> ValidateAllFields{"Cek Validitas Data:<br/>1. Yield Qty > 0<br/>2. Machine Hour > 0<br/>3. Line Tidak Kosong<br/>4. Pengawas Terverifikasi"}
    
    ValidateAllFields -- "Ada Field Belum Lengkap" --> DisableConfirm["Tombol 'Confirm' Tetap Nonaktif"] --> ScanLineC
    ValidateAllFields -- "Lengkap & Valid" --> EnableConfirm["Aktifkan Tombol 'Confirm'"]
    
    EnableConfirm --> ClickConfirm["Pengguna Tekan 'Confirm'"]
    ClickConfirm --> BuildBody["Susun Payload JSON YieldSet"]
    BuildBody --> PostYield["Kirim POST /ZDMP_POST_WEIGHT_SRV/YieldSet"]
    
    PostYield --> CheckYieldResp{"Response SAP Status 201 Created?"}
    CheckYieldResp -- "Gagal / Error" --> ShowYieldErr["Tampilkan Pesan Error SAP di Layar"] --> EnableConfirm
    CheckYieldResp -- "Sukses" --> SuccessDialog["Tampilkan Dialog 'Confirmation Success'"]
    SuccessDialog --> ResetForm["Reset Form & Selesai"]
    ResetForm --> EndC(["Selesai Modul Confirmation"])`
  },
  {
    id: '09_confirmation_sequence',
    title: '9. Sequence Diagram: Modul Confirmation',
    category: 'Confirmation',
    code: `sequenceDiagram
    autonumber
    actor SPV as Pengawas / Operator
    participant UI as FormConfirmation UI
    participant Bloc as SubmitConfirmationBloc
    participant Repo as SubmitConfirmationProvider
    participant SAP as SAP OData (YieldSet)

    Note over SPV,UI: 1. Pengisian Data Hasil & Jam Operasi
    SPV->>UI: Input Yield Qty (misal: 1500) & Satuan (KG)
    SPV->>UI: Input Jam Kerja Mesin (MachineHour = 4.5)
    SPV->>UI: Input Jumlah Tenaga Kerja (NumberOfLabor = 3)
    UI->>UI: Hitung otomatis: laborHour = 4.5 * 3 = 13.5
    SPV->>UI: Input Catatan/Reason (jika ada)
    UI->>UI: Split Reason ke array per 132 char (YieldToLinesNav)
    SPV->>UI: Scan Barcode Line Produksi (Line = 'LINE-MIX-01')

    Note over UI: 2. Validasi Form
    UI->>UI: Validasi semua mandatory field terisi & Line tidak kosong
    UI->>UI: Enable tombol "Confirm"

    Note over SPV,SAP: 3. Submit Konfirmasi ke SAP
    SPV->>UI: Tekan Tombol "Confirm"
    UI->>Bloc: add(SubmitConfirmationEvent(payload))
    Bloc->>Repo: submitConfirmation(YieldSetBody)
    Repo->>SAP: POST /ZDMP_POST_WEIGHT_SRV/YieldSet
    Note right of SAP: Validasi Routing, OrderNo,<br/>ActivityNo, dan Posting Date
    alt Konfirmasi Sukses di SAP
        SAP-->>Repo: 201 Created (Yield Doc No, Msg: "Confirmation saved")
        Repo-->>Bloc: Response Success
        Bloc-->>UI: State: SubmitConfirmationLoaded
        UI-->>SPV: Tampilkan Alert "Confirmation Berhasil Disimpan"
        UI->>UI: Navigasi kembali ke HomeScreen
    else Validasi Gagal di SAP
        SAP-->>Repo: 400 Bad Request / 500 Error (Error Msg dari SAP)
        Repo-->>Bloc: Response Error
        Bloc-->>UI: State: SubmitConfirmationError(message)
        UI-->>SPV: Tampilkan SnackBar / Dialog Error
    end`
  }
];

// Helper to escape HTML
function escapeHtml(str) {
  return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

async function renderDiagrams() {
  console.log('🚀 Starting diagram image generation...');

  for (let i = 0; i < diagrams.length; i++) {
    const d = diagrams[i];
    console.log(`[${i + 1}/${diagrams.length}] Rendering ${d.id}...`);

    // Step 1: Render HTML with Mermaid
    const genHtmlPath = `/tmp/${d.id}_gen.html`;
    const genHtml = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 30px;
    background: #ffffff;
    display: inline-block;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  }
</style>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({
    startOnLoad: true,
    theme: 'default',
    themeVariables: {
      fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      fontSize: '14px',
      primaryColor: '#e0e7ff',
      primaryBorderColor: '#6366f1',
      primaryTextColor: '#1e1b4b',
      lineColor: '#4f46e5',
      secondaryColor: '#fef3c7',
      tertiaryColor: '#dcfce7'
    },
    flowchart: { curve: 'basis', padding: 15 },
    sequence: { mirrorActors: false, bottomMarginAdj: 10 }
  });
</script>
</head>
<body>
  <div id="container" class="mermaid">
${d.code}
  </div>
</body>
</html>`;

    fs.writeFileSync(genHtmlPath, genHtml);

    // Dump DOM to extract SVG
    const dom = execSync(
      `google-chrome-stable --headless=new --disable-gpu --no-sandbox --virtual-time-budget=3000 --dump-dom ${genHtmlPath}`
    ).toString();

    const svgMatch = dom.match(/<svg[\s\S]*?<\/svg>/i);
    if (!svgMatch) {
      console.error(`❌ Failed to extract SVG for ${d.id}`);
      continue;
    }

    let svg = svgMatch[0];
    const svgPath = path.join(OUTPUT_DIR, `${d.id}.svg`);
    fs.writeFileSync(svgPath, svg);

    // Parse viewBox to calculate dimensions
    const vbMatch = svg.match(/viewBox="([^"]+)"/);
    let width = 1200;
    let height = 800;
    if (vbMatch) {
      const parts = vbMatch[1].split(/\s+/).map(Number);
      if (parts.length === 4) {
        width = Math.ceil(parts[2] + 80);
        height = Math.ceil(parts[3] + 80);
      }
    }

    // Step 2: Render SVG to high-res PNG
    const renderHtmlPath = `/tmp/${d.id}_render.html`;
    const renderHtml = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 30px;
    background: #ffffff;
    display: flex;
    justify-content: center;
    align-items: center;
    width: 100vw;
    height: 100vh;
  }
  svg {
    max-width: 100%;
    max-height: 100%;
  }
</style>
</head>
<body>
${svg}
</body>
</html>`;

    fs.writeFileSync(renderHtmlPath, renderHtml);

    const pngPath = path.join(OUTPUT_DIR, `${d.id}.png`);
    execSync(
      `google-chrome-stable --headless=new --disable-gpu --no-sandbox --window-size=${width},${height} --force-device-scale-factor=2 --screenshot=${pngPath} ${renderHtmlPath}`
    );

    console.log(`✅ ${d.id}: Generated ${svgPath} & ${pngPath} (${width}x${height})`);
  }

  // Step 3: Generate Interactive HTML Viewer
  console.log('🎨 Generating Interactive Visual Diagrams Viewer...');
  generateHtmlViewer();

  console.log('🎉 All diagrams generated successfully!');
}

function generateHtmlViewer() {
  const viewerHtmlPath = path.join(__dirname, 'visual_diagrams_viewer.html');

  const navItems = diagrams.map((d, index) => `
    <button class="nav-item ${index === 0 ? 'active' : ''}" onclick="switchDiagram('${d.id}')">
      <span class="nav-num">${index + 1}</span>
      <div class="nav-info">
        <span class="nav-title">${escapeHtml(d.title)}</span>
        <span class="nav-cat">${d.category}</span>
      </div>
    </button>
  `).join('\n');

  const diagramPanels = diagrams.map((d, index) => `
    <div id="panel-${d.id}" class="diagram-panel ${index === 0 ? 'active' : ''}">
      <div class="panel-header">
        <div>
          <h2>${escapeHtml(d.title)}</h2>
          <span class="badge">${d.category}</span>
        </div>
        <div class="header-actions">
          <a href="images/${d.id}.svg" target="_blank" class="btn btn-outline" download>
            <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
            Download SVG
          </a>
          <a href="images/${d.id}.png" target="_blank" class="btn btn-primary" download>
            <svg width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
            Download PNG
          </a>
        </div>
      </div>
      <div class="canvas-viewport" id="viewport-${d.id}">
        <div class="canvas-controls">
          <button onclick="zoomIn('${d.id}')" title="Zoom In">+</button>
          <button onclick="zoomOut('${d.id}')" title="Zoom Out">−</button>
          <button onclick="resetZoom('${d.id}')" title="Reset">100%</button>
          <button onclick="toggleFit('${d.id}')" title="Fit to View">Fit</button>
        </div>
        <div class="canvas-content" id="content-${d.id}">
          <img src="images/${d.id}.svg" alt="${escapeHtml(d.title)}" class="diagram-image" />
        </div>
      </div>
    </div>
  `).join('\n');

  const htmlContent = `<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mobile Dumping System — Visual Flowcharts & Sequence Diagrams</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-main: #0b0f19;
      --bg-card: #111827;
      --bg-surface: #1f2937;
      --bg-hover: #374151;
      --border-color: #374151;
      --primary: #6366f1;
      --primary-hover: #4f46e5;
      --text-main: #f9fafb;
      --text-muted: #9ca3af;
      --accent: #10b981;
    }
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif;
      background-color: var(--bg-main);
      color: var(--text-main);
      display: flex;
      height: 100vh;
      overflow: hidden;
    }

    /* Sidebar Navigation */
    .sidebar {
      width: 360px;
      background-color: var(--bg-card);
      border-right: 1px solid var(--border-color);
      display: flex;
      flex-direction: column;
      flex-shrink: 0;
    }
    .sidebar-header {
      padding: 24px 20px;
      border-bottom: 1px solid var(--border-color);
    }
    .sidebar-header h1 {
      font-size: 17px;
      font-weight: 700;
      color: #fff;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .sidebar-header h1 span {
      background: linear-gradient(135deg, #6366f1, #a855f7);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .sidebar-header p {
      font-size: 12px;
      color: var(--text-muted);
      margin-top: 6px;
    }
    .nav-list {
      flex: 1;
      overflow-y: auto;
      padding: 12px 10px;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .nav-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 14px;
      border-radius: 10px;
      background: transparent;
      border: 1px solid transparent;
      color: var(--text-main);
      text-align: left;
      cursor: pointer;
      transition: all 0.2s ease;
      width: 100%;
    }
    .nav-item:hover {
      background: var(--bg-surface);
      border-color: var(--border-color);
    }
    .nav-item.active {
      background: rgba(99, 102, 241, 0.15);
      border-color: var(--primary);
      color: #fff;
    }
    .nav-num {
      width: 26px;
      height: 26px;
      border-radius: 6px;
      background: var(--bg-surface);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: 700;
      color: var(--text-muted);
      flex-shrink: 0;
    }
    .nav-item.active .nav-num {
      background: var(--primary);
      color: #fff;
    }
    .nav-info {
      display: flex;
      flex-direction: column;
      gap: 2px;
      overflow: hidden;
    }
    .nav-title {
      font-size: 13px;
      font-weight: 600;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .nav-cat {
      font-size: 11px;
      color: var(--text-muted);
    }

    /* Main Viewer Area */
    .main-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      background: #0f172a;
    }
    .diagram-panel {
      display: none;
      flex-direction: column;
      height: 100%;
    }
    .diagram-panel.active {
      display: flex;
    }
    .panel-header {
      padding: 16px 24px;
      background: var(--bg-card);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .panel-header h2 {
      font-size: 18px;
      font-weight: 700;
    }
    .badge {
      display: inline-block;
      margin-top: 4px;
      padding: 3px 8px;
      background: rgba(99, 102, 241, 0.2);
      color: #818cf8;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 600;
    }
    .header-actions {
      display: flex;
      gap: 10px;
    }
    .btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 14px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      text-decoration: none;
      cursor: pointer;
      transition: all 0.15s ease;
    }
    .btn-outline {
      background: var(--bg-surface);
      color: #fff;
      border: 1px solid var(--border-color);
    }
    .btn-outline:hover {
      background: var(--bg-hover);
    }
    .btn-primary {
      background: var(--primary);
      color: #fff;
      border: 1px solid var(--primary);
    }
    .btn-primary:hover {
      background: var(--primary-hover);
    }

    /* Canvas Viewport */
    .canvas-viewport {
      flex: 1;
      position: relative;
      overflow: auto;
      background: #ffffff;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px;
      cursor: grab;
      user-select: none;
    }
    .canvas-viewport:active {
      cursor: grabbing;
    }
    .canvas-controls {
      position: absolute;
      bottom: 24px;
      right: 24px;
      background: rgba(17, 24, 39, 0.85);
      backdrop-filter: blur(8px);
      border: 1px solid var(--border-color);
      border-radius: 10px;
      display: flex;
      gap: 4px;
      padding: 4px;
      z-index: 100;
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.3);
    }
    .canvas-controls button {
      background: transparent;
      border: none;
      color: #fff;
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.15s;
    }
    .canvas-controls button:hover {
      background: rgba(255, 255, 255, 0.1);
    }
    .canvas-content {
      transform-origin: center center;
      transition: transform 0.15s ease-out;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .diagram-image {
      max-width: 100%;
      height: auto;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      border-radius: 12px;
      background: #fff;
    }
  </style>
</head>
<body>

  <!-- Left Sidebar -->
  <aside class="sidebar">
    <div class="sidebar-header">
      <h1><span>Mobile Dumping</span> Diagrams</h1>
      <p>Koleksi Lengkap Flowchart & Sequence Diagram</p>
    </div>
    <div class="nav-list">
      ${navItems}
    </div>
  </aside>

  <!-- Right Viewer -->
  <main class="main-content">
    ${diagramPanels}
  </main>

  <script>
    const zoomStates = {};

    function switchDiagram(id) {
      document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
      document.querySelectorAll('.diagram-panel').forEach(el => el.classList.remove('active'));

      const targetBtn = Array.from(document.querySelectorAll('.nav-item')).find(btn => btn.getAttribute('onclick').includes(id));
      if (targetBtn) targetBtn.classList.add('active');

      const targetPanel = document.getElementById('panel-' + id);
      if (targetPanel) targetPanel.classList.add('active');
    }

    function getZoom(id) {
      if (!zoomStates[id]) zoomStates[id] = 1;
      return zoomStates[id];
    }

    function setZoom(id, factor) {
      zoomStates[id] = Math.max(0.2, Math.min(factor, 3.5));
      const content = document.getElementById('content-' + id);
      if (content) {
        content.style.transform = 'scale(' + zoomStates[id] + ')';
      }
    }

    function zoomIn(id) { setZoom(id, getZoom(id) + 0.15); }
    function zoomOut(id) { setZoom(id, getZoom(id) - 0.15); }
    function resetZoom(id) { setZoom(id, 1); }
    function toggleFit(id) { setZoom(id, 0.85); }
  </script>
</body>
</html>`;

  fs.writeFileSync(viewerHtmlPath, htmlContent);
  console.log(`✅ Interactive Viewer generated: ${viewerHtmlPath}`);
}

renderDiagrams().catch(console.error);
