// Remove ImageProcessingResponse and integrate its fromJson logic into FormFields

class FormFields {
  String name;
  int age;
  String gender;
  String maritalStatus;
  String address;
  String chiefComplaint;
  MedicalHistory medicalHistory;
  String pastSurgery;
  ExaminationVitals examinationVitals;
  String doctorsNotes;
  String signature;
  String signatureDate;
  bool isSaved; // Track if this data has been saved to database

  FormFields({
    required this.name,
    required this.age,
    required this.gender,
    required this.maritalStatus,
    required this.address,
    required this.chiefComplaint,
    required this.medicalHistory,
    required this.pastSurgery,
    required this.examinationVitals,
    required this.doctorsNotes,
    required this.signature,
    required this.signatureDate,
    this.isSaved = false, // Default to not saved
  });

  factory FormFields.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    final formFieldsJson = json['form_fields'] as Map<String, dynamic>? ?? {};

    return FormFields(
      name: formFieldsJson['name'] as String? ?? '',
      age: (formFieldsJson['age'] as num?)?.toInt() ?? 0,
      gender: formFieldsJson['gender'] as String? ?? 'Male',
      maritalStatus: formFieldsJson['marital_status'] as String? ?? 'Single',
      address: formFieldsJson['address'] as String? ?? '',
      chiefComplaint: formFieldsJson['chief_complaint'] as String? ?? '',
      medicalHistory: MedicalHistory.fromJson(formFieldsJson['medical_history'] as Map<String, dynamic>?),
      pastSurgery: formFieldsJson['past_surgery'] as String? ?? '',
      examinationVitals: ExaminationVitals.fromJson(formFieldsJson['examination_vitals'] as Map<String, dynamic>?),
      doctorsNotes: formFieldsJson['doctors_notes'] as String? ?? '',
      signature: formFieldsJson['signature'] as String? ?? '',
      signatureDate: formFieldsJson['signature_date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'marital_status': maritalStatus,
      'address': address,
      'chief_complaint': chiefComplaint,
      'medical_history': medicalHistory.toJson(),
      'past_surgery': pastSurgery,
      'examination_vitals': examinationVitals.toJson(),
      'doctors_notes': doctorsNotes,
      'signature': signature,
      'signature_date': signatureDate,
      'is_saved': isSaved,
    };
  }
}

class MedicalHistory {
  bool dm;
  bool htn;
  bool ba;
  bool cvd;
  bool ckd;

  MedicalHistory({
    required this.dm,
    required this.htn,
    required this.ba,
    required this.cvd,
    required this.ckd,
  });

  factory MedicalHistory.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return MedicalHistory(
      dm: json['DM'] as bool? ?? false,
      htn: json['HTN'] as bool? ?? false,
      ba: json['BA'] as bool? ?? false,
      cvd: json['CVD'] as bool? ?? false,
      ckd: json['CKD'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DM': dm,
      'HTN': htn,
      'BA': ba,
      'CVD': cvd,
      'CKD': ckd,
    };
  }
}

class ExaminationVitals {
  double rbs;
  int bpSystolic;
  int bpDiastolic;
  double spO2;

  ExaminationVitals({
    required this.rbs,
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.spO2,
  });

  factory ExaminationVitals.fromJson(Map<String, dynamic>? json) {
    json ??= {};
    return ExaminationVitals(
      rbs: (json['RBS'] as num?)?.toDouble() ?? 0.0,
      bpSystolic: (json['BP_systolic'] as num?)?.toInt() ?? 0,
      bpDiastolic: (json['BP_diastolic'] as num?)?.toInt() ?? 0,
      spO2: (json['SpO2'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RBS': rbs,
      'BP_systolic': bpSystolic,
      'BP_diastolic': bpDiastolic,
      'SpO2': spO2,
    };
  }
}

// Add enums and extensions at the end
enum Gender {
  male,
  female,
  other,
}

extension GenderExtension on Gender {
  String get value => switch (this) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.other => 'Other',
  };

  static Gender fromString(String str) => switch (str.toLowerCase()) {
    'male' => Gender.male,
    'female' => Gender.female,
    'other' => Gender.other,
    _ => Gender.male,
  };
}

enum MaritalStatus {
  single,
  married,
}

extension MaritalStatusExtension on MaritalStatus {
  String get value => switch (this) {
    MaritalStatus.single => 'Single',
    MaritalStatus.married => 'Married',
  };

  static MaritalStatus fromString(String str) => switch (str.toLowerCase()) {
    'single' => MaritalStatus.single,
    'married' => MaritalStatus.married,
    _ => MaritalStatus.single,
  };
}
