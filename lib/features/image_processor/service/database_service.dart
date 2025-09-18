import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:datalens/features/image_processor/model/image_processing_response.dart';

class DatabaseService {
  late Connection connection;

  Future<void> connect() async {
    connection = await Connection.open(
      Endpoint(
        host: '202.4.127.189',
        database: 'bracmne_brac_mne_data',
        username: 'devuser',
        password: 'rLJOp3rjMsfmQHE',
        port: 5434,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
  }

  Future<void> insertPatientRecord(FormFields patientData) async {
    String genderCode = patientData.gender.toLowerCase() == 'male' ? 'M' : (patientData.gender.toLowerCase() == 'female' ? 'F' : 'O');
    String isMarried = patientData.maritalStatus.toLowerCase() == 'married' ? 'Y' : 'N';
    
    // Generate answer JSON from patient data
    String answerJson = _generateAnswerJson(patientData);

    await connection.execute(
      '''
      insert into public.heath_care_hospital (id, item_id, create_time, reporting_date, last_modified_time, last_sync_time,
                                        is_deleted, created_by, last_modified_by, answer, name, age, gender, is_married,
                                        address, chief_complaint, has_diabetes_mellitus, has_hypertension,
                                        has_bronchial_asthma, has_cardiovascular_disease, has_chronic_kidney_disease,
                                        past_surgery, random_blood_sugar, blood_pressure, spo2, doctors_notes)
select get_guid(),
       get_guid(),
       now(),
       now(),
       now(),
       now(),
       false,
       'stream_fresh',
       'stream_fresh',
       \$1,
       \$2,
       \$3,
       \$4,
       \$5,
       \$6,
       \$7,
       \$8,
       \$9,
       \$10,
       \$11,
       \$12,
       \$13,
       \$14,
       \$15,
       \$16,
       \$17;
      ''',
      parameters: [
        answerJson,                                                        // answer
        patientData.name,                                                  // name
        patientData.age,                                                   // age
        genderCode,                                                        // gender
        isMarried,                                                         // is_married
        patientData.address,                                               // address
        patientData.chiefComplaint,                                        // chief_complaint
        patientData.medicalHistory.dm ? '1' : '0',                        // has_diabetes_mellitus
        patientData.medicalHistory.htn ? '1' : '0',                       // has_hypertension
        patientData.medicalHistory.ba ? '1' : '0',                        // has_bronchial_asthma
        patientData.medicalHistory.cvd ? '1' : '0',                       // has_cardiovascular_disease
        patientData.medicalHistory.ckd ? '1' : '0',                       // has_chronic_kidney_disease
        patientData.pastSurgery,                                          // past_surgery
        patientData.examinationVitals.rbs.toInt(),                        // random_blood_sugar
        patientData.examinationVitals.bpSystolic,                         // blood_pressure (using systolic)
        patientData.examinationVitals.spO2.toInt(),                       // spo2
        patientData.doctorsNotes,                                         // doctors_notes
      ],
    );
  }

  /// Generate answer JSON from patient data
  String _generateAnswerJson(FormFields patientData) {
    final answerData = {
      "": "",
      "name": patientData.name,
      "age": patientData.age,
      "gender": patientData.gender.toLowerCase() == 'male' ? '1' : (patientData.gender.toLowerCase() == 'female' ? '2' : '3'),
      "is_married": patientData.maritalStatus.toLowerCase() == 'married' ? '1' : '0',
      "address": patientData.address,
      "chief_complaint": patientData.chiefComplaint,
      "has_diabetes_mellitus": patientData.medicalHistory.dm ? '1' : '0',
      "has_hypertension": patientData.medicalHistory.htn ? '1' : '0',
      "has_bronchial_asthma": patientData.medicalHistory.ba ? '1' : '0',
      "has_cardiovascular_disease": patientData.medicalHistory.cvd ? '1' : '0',
      "has_chronic_kidney_disease": patientData.medicalHistory.ckd ? '1' : '0',
      "past_surgery": patientData.pastSurgery,
      "random_blood_sugar": patientData.examinationVitals.rbs.toInt(),
      "blood_pressure": patientData.examinationVitals.bpSystolic,
      "spo2": patientData.examinationVitals.spO2.toInt(),
      "doctors_notes": patientData.doctorsNotes,
    };
    
    return jsonEncode(answerData);
  }

  Future<void> close() async {
    await connection.close();
  }
}
