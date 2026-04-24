class Subject {
  final String name;
  final int price;
  final String imageUrl;

  const Subject(this.name, this.price, this.imageUrl);
}

class AppData {
  static const Map<String, List<Subject>> curriculum = {
    'First Year': [
      Subject('Anatomy', 299, 'assets/images/subjects/anatomy.jpg'),
      Subject('Physiology', 299, 'assets/images/subjects/physiology.jpg'),
      Subject('Tarika-e-Tibb', 149, 'assets/images/subjects/history.jpg'),
      Subject('Umoor-e-Tabiya', 149, 'assets/images/subjects/history.jpg'),
      Subject('Mantiq wa Falsafa', 99, 'assets/images/subjects/history.jpg'),
      Subject('Urdu & Arabic', 150, 'assets/images/subjects/urdu_arabic.jpg'),
      Subject('First Year Package (Full)', 800, 'assets/images/subjects/library.jpg'),
    ],
    'Second Year': [
      Subject('Community Medicine', 150, 'assets/images/subjects/library.jpg'),
      Subject('Pathology', 399, 'assets/images/subjects/pathology.jpg'),
      Subject('Sariyath', 199, 'assets/images/subjects/anatomy.jpg'),
      Subject('Forensic & Toxicology', 149, 'assets/images/subjects/history.jpg'),
      Subject('Ilmul Advia', 99, 'assets/images/subjects/materia_medica.jpg'),
      Subject('Mufradat', 99, 'assets/images/subjects/herbs_bowl.jpg'),
      Subject('Saidla', 99, 'assets/images/subjects/pharmacy.jpg'),
      Subject('Murakkabat', 99, 'assets/images/subjects/materia_medica.jpg'),
      Subject('Microbiology', 49, 'assets/images/subjects/microbiology.jpg'),
      Subject('Full Second Year Combo', 999, 'assets/images/subjects/library.jpg'),
    ],
    'Final Year': [
      Subject('Moalijat', 599, 'assets/images/subjects/gynecology_bp.jpg'),
      Subject('Gynecology', 199, 'assets/images/subjects/gynecology_bp.jpg'),
      Subject('Obstruction', 199, 'assets/images/subjects/physiology.jpg'),
      Subject('ENT & Ophthalmology', 199, 'assets/images/subjects/ent_eye.jpg'),
      Subject('Pediatric', 199, 'assets/images/subjects/pediatric.jpg'),
      Subject('Research Methodology', 99, 'assets/images/subjects/research_writing.jpg'),
      Subject('IBT', 149, 'assets/images/subjects/pharmacy.jpg'),
      Subject('Skin', 99, 'assets/images/subjects/skin.jpg'),
      Subject('Surgery 1', 199, 'assets/images/subjects/surgery.jpg'),
      Subject('Surgery 2', 199, 'assets/images/subjects/surgery.jpg'),
      Subject('Complete Final Year Combo', 1500, 'assets/images/subjects/library.jpg'),
    ],
  };

  static List<String> get years => curriculum.keys.toList();

  static List<Subject> getSubjectsByYear(String year) {
    return curriculum[year] ?? [];
  }
}
