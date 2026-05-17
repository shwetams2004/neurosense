class CurrentPatient {
  static String? patientId;
  static String? patientName;

  static void setPatient({
    required String id,
    required String name,
  }) {
    patientId = id;
    patientName = name;
  }

  static void clear() {
    patientId = null;
    patientName = null;
  }
}