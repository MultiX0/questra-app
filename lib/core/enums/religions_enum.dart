enum Religions { christianity, islam, hinduism, buddhism, judaism, atheist }

String? religionToString(Religions? r) {
  return r?.name;
}

Religions? stringToReligion(String r) {
  final _r = r.toLowerCase().trim();
  switch (_r) {
    case 'christianity':
      return Religions.christianity;
    case 'islam':
      return Religions.islam;
    case 'hinduism':
      return Religions.hinduism;
    case 'buddhism':
      return Religions.buddhism;
    case 'judaism':
      return Religions.judaism;
    case 'atheist':
      return Religions.atheist;

    default:
      return null;
  }
}
