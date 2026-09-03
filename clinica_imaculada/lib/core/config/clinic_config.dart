/// Dados fixos da clínica, usados em cabeçalhos de PDF (recibos, exames).
///
/// Estes valores são provisórios. O utilizador vai fornecer os dados oficiais
/// (nome, morada, contactos, NIF, logótipo). Quando existir o módulo de
/// configuração (admin), estes campos passam a ser editáveis e guardados na
/// base de dados; por agora ficam como constantes.
class ClinicConfig {
  const ClinicConfig._();

  static const String nome = 'Clínica Imaculada';
  static const String morada = '—';
  static const String telefone = '—';
  static const String email = '—';
  static const String nif = '—';

  /// Caminho do logótipo dentro de assets (a definir quando existir o ficheiro).
  static const String? logoAssetPath = null;
}
