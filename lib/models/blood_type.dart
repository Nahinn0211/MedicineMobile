/// Enum định nghĩa các nhóm máu
enum BloodType {
  A_POSITIVE('A_POSITIVE'),
  A_NEGATIVE('A_NEGATIVE'),
  B_POSITIVE('B_POSITIVE'),
  B_NEGATIVE('B_NEGATIVE'),
  AB_POSITIVE('AB_POSITIVE'),
  AB_NEGATIVE('AB_NEGATIVE'),
  O_POSITIVE('O_POSITIVE'),
  O_NEGATIVE('O_NEGATIVE');

  final String value;

  const BloodType(this.value);

  static BloodType? fromString(String? value) {
    if (value == null) return null;

    // Đầu tiên thử khớp với giá trị chính xác
    try {
      return BloodType.values.firstWhere(
            (e) => e.value == value,
      );
    } catch (e) {
      // Thử khớp với định dạng người dùng thân thiện (A+, B-, v.v.)
      switch (value) {
        case 'A+': return BloodType.A_POSITIVE;
        case 'A-': return BloodType.A_NEGATIVE;
        case 'B+': return BloodType.B_POSITIVE;
        case 'B-': return BloodType.B_NEGATIVE;
        case 'AB+': return BloodType.AB_POSITIVE;
        case 'AB-': return BloodType.AB_NEGATIVE;
        case 'O+': return BloodType.O_POSITIVE;
        case 'O-': return BloodType.O_NEGATIVE;
        default: return null;
      }
    }
  }

  String toDisplayString() {
    switch (this) {
      case BloodType.A_POSITIVE: return 'A+';
      case BloodType.A_NEGATIVE: return 'A-';
      case BloodType.B_POSITIVE: return 'B+';
      case BloodType.B_NEGATIVE: return 'B-';
      case BloodType.AB_POSITIVE: return 'AB+';
      case BloodType.AB_NEGATIVE: return 'AB-';
      case BloodType.O_POSITIVE: return 'O+';
      case BloodType.O_NEGATIVE: return 'O-';
    }
  }

  @override
  String toString() => value;
}