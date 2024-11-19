class ErrorResponse {
  Error? error;

  ErrorResponse({this.error});

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'] != null ? Error.fromJson(json['error']) : null;
  }
}

class Error {
  String? code;
  Message? message;
  Innererror? innererror;

  Error({this.code, this.message, this.innererror});

  Error.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
    innererror = json['innererror'] != null
        ? Innererror.fromJson(json['innererror'])
        : null;
  }
}

class Message {
  String? lang;
  String? value;

  Message({this.lang, this.value});

  Message.fromJson(Map<String, dynamic> json) {
    lang = json['lang'];
    value = json['value'];
  }
}

class Innererror {
  String? transactionid;
  String? timestamp;
  ErrorResolution? errorResolution;

  Innererror({this.transactionid, this.timestamp, this.errorResolution});

  Innererror.fromJson(Map<String, dynamic> json) {
    transactionid = json['transactionid'];
    timestamp = json['timestamp'];
    errorResolution = json['Error_Resolution'] != null
        ? ErrorResolution.fromJson(json['Error_Resolution'])
        : null;
  }
}

class ErrorResolution {
  String? sAPTransaction;
  String? sAPNote;

  ErrorResolution({this.sAPTransaction, this.sAPNote});

  ErrorResolution.fromJson(Map<String, dynamic> json) {
    sAPTransaction = json['SAP_Transaction'];
    sAPNote = json['SAP_Note'];
  }
}
