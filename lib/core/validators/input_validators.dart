typedef Validator = String? Function(String? value);

class InputValidators {
  static Validator requiredField(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static Validator email() {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final trimmedValue = value.trim();
      final atIndex = trimmedValue.indexOf('@');
      if (atIndex < 1) return 'Correo inválido';
      final domainPart = trimmedValue.substring(atIndex + 1);
      if (!domainPart.contains('.')) return 'Correo inválido';
      return null;
    };
  }

  static Validator onlyNumbers() {
    final regex = RegExp(r'^[0-9]+$');
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      if (!regex.hasMatch(value.trim())) return 'Solo números permitidos';
      return null;
    };
  }


}

String? composeValidators(List<Validator> validators, String? value) {
  for (final validator in validators) {
    final result = validator(value);
    if (result != null) return result;
  }
  return null;
}
