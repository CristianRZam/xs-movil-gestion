typedef Validator<T> = String? Function(T? value);

class InputValidators {
  static Validator<String> requiredField(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static Validator<T> requiredSelect<T>(String errorMessage) {
    return (value) {
      if (value == null) {
        return errorMessage;
      }
      return null;
    };
  }

  static Validator<String> email() {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;

      final trimmedValue = value.trim();
      final atIndex = trimmedValue.indexOf('@');

      if (atIndex < 1) return 'Correo inválido';

      final domainPart = trimmedValue.substring(atIndex + 1);

      if (!domainPart.contains('.')) {
        return 'Correo inválido';
      }

      return null;
    };
  }

  static Validator<String> onlyNumbers() {
    final regex = RegExp(r'^[0-9]+$');

    return (value) {
      if (value == null || value.trim().isEmpty) return null;

      if (!regex.hasMatch(value.trim())) {
        return 'Solo números permitidos';
      }

      return null;
    };
  }

  static Validator<String> decimalNumber() {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;

      final number = double.tryParse(value.trim());

      if (number == null) {
        return 'Ingrese un número válido';
      }

      if (number < 0) {
        return 'El valor debe ser mayor o igual a 0';
      }

      return null;
    };
  }
}

String? composeValidators<T>(
    List<Validator<T>> validators,
    T? value,
    ) {
  for (final validator in validators) {
    final result = validator(value);

    if (result != null) {
      return result;
    }
  }

  return null;
}