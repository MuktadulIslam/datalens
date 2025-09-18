import 'package:postgres/postgres.dart';

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

  Future<void> insertPatientRecord(Map<String, String> patientData) async {
    await connection.execute(
      '''
      INSERT INTO muktadul.patient_records (
        name, age, gender, is_married, address, chief_complaint,
        has_diabetes_mellitus, has_hypertension, has_bronchial_asthma,
        has_cardiovascular_disease, has_chronic_kidney_disease,
        past_surgery, random_blood_sugar, blood_pressure, spo2, doctors_notes
      ) VALUES (
        \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13, \$14, \$15, \$16
      )
      ''',
      parameters: [
        'Muktadul',
        23,
        'M',
        'Y',
        '123 Main Street, Dhaka',
        'Chest pain and shortness of breath',
        'N',
        'Y',
        'N',
        'Y',
        'N',
        'Appendectomy in 2015',
        120,
        140,
        98,
        'Patient shows signs of hypertension. Recommend lifestyle changes and medication.',
      ],
    );
  }

  Future<void> close() async {
    await connection.close();
  }
}
