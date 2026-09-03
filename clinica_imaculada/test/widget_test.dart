import 'package:clinica_imaculada/core/auth/password_hasher.dart';
import 'package:clinica_imaculada/core/auth/permissions.dart';
import 'package:clinica_imaculada/core/auth/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PasswordPolicy', () {
    test('rejeita senha curta', () {
      expect(PasswordPolicy.validate('Ab1'), isNotNull);
    });

    test('rejeita senha sem números', () {
      expect(PasswordPolicy.validate('apenasletras'), isNotNull);
    });

    test('aceita senha com letras e números e comprimento suficiente', () {
      expect(PasswordPolicy.validate('clinica2025'), isNull);
    });
  });

  group('Permissions', () {
    test('recepção não acede a relatórios', () {
      expect(Permissions.can(UserRole.recepcao, AppSection.relatorios), isFalse);
    });

    test('médico acede a anamnese', () {
      expect(Permissions.can(UserRole.medico, AppSection.anamnese), isTrue);
    });

    test('admin acede a tudo', () {
      for (final s in AppSection.values) {
        expect(Permissions.can(UserRole.admin, s), isTrue, reason: s.name);
      }
    });

    test('farmacêutico só vê farmácia e caixa', () {
      expect(
        Permissions.sectionsFor(UserRole.farmaceutico),
        {AppSection.farmacia, AppSection.caixa},
      );
    });
  });
}
