import 'package:workin_fit/models/enums.dart';

class MuscleDatabase {
  static final Map<String, Muscle> muscles = {
    // NECK
    'sternocleidomastoid': Muscle(
      id: 'sternocleidomastoid',
      name: 'Sternocleidomastoid',
      commonName: 'Neck',
      category: MuscleCategory.neck,
      isPrimary: true,
    ),
    'trapezius_upper': Muscle(
      id: 'trapezius_upper',
      name: 'Upper Trapezius',
      commonName: 'Upper Traps',
      category: MuscleCategory.neck,
    ),
    
    // CHEST
    'pectoralis_major': Muscle(
      id: 'pectoralis_major',
      name: 'Pectoralis Major',
      commonName: 'Chest',
      category: MuscleCategory.chest,
      isPrimary: true,
    ),
    'pectoralis_minor': Muscle(
      id: 'pectoralis_minor',
      name: 'Pectoralis Minor',
      commonName: 'Inner Chest',
      category: MuscleCategory.chest,
    ),
    'serratus_anterior': Muscle(
      id: 'serratus_anterior',
      name: 'Serratus Anterior',
      commonName: 'Rib Cage Muscles',
      category: MuscleCategory.chest,
    ),
    
    // SHOULDERS
    'deltoid_anterior': Muscle(
      id: 'deltoid_anterior',
      name: 'Anterior Deltoid',
      commonName: 'Front Shoulder',
      category: MuscleCategory.shoulders,
      isPrimary: true,
    ),
    'deltoid_lateral': Muscle(
      id: 'deltoid_lateral',
      name: 'Lateral Deltoid',
      commonName: 'Side Shoulder',
      category: MuscleCategory.shoulders,
    ),
    'deltoid_posterior': Muscle(
      id: 'deltoid_posterior',
      name: 'Posterior Deltoid',
      commonName: 'Rear Shoulder',
      category: MuscleCategory.shoulders,
    ),
    'rotator_cuff': Muscle(
      id: 'rotator_cuff',
      name: 'Rotator Cuff',
      commonName: 'Shoulder Stabilizers',
      category: MuscleCategory.shoulders,
    ),
    
    // BACK
    'latissimus_dorsi': Muscle(
      id: 'latissimus_dorsi',
      name: 'Latissimus Dorsi',
      commonName: 'Lats',
      category: MuscleCategory.back,
      isPrimary: true,
    ),
    'trapezius_middle': Muscle(
      id: 'trapezius_middle',
      name: 'Middle Trapezius',
      commonName: 'Mid Back',
      category: MuscleCategory.back,
    ),
    'trapezius_lower': Muscle(
      id: 'trapezius_lower',
      name: 'Lower Trapezius',
      commonName: 'Lower Back',
      category: MuscleCategory.back,
    ),
    'rhomboids': Muscle(
      id: 'rhomboids',
      name: 'Rhomboids',
      commonName: 'Between Shoulder Blades',
      category: MuscleCategory.back,
    ),
    'erector_spinae': Muscle(
      id: 'erector_spinae',
      name: 'Erector Spinae',
      commonName: 'Lower Back',
      category: MuscleCategory.back,
    ),
    
    // BICEPS
    'biceps_brachii': Muscle(
      id: 'biceps_brachii',
      name: 'Biceps Brachii',
      commonName: 'Biceps',
      category: MuscleCategory.biceps,
      isPrimary: true,
    ),
    'brachialis': Muscle(
      id: 'brachialis',
      name: 'Brachialis',
      commonName: 'Upper Arm',
      category: MuscleCategory.biceps,
    ),
    
    // TRICEPS
    'triceps_brachii': Muscle(
      id: 'triceps_brachii',
      name: 'Triceps Brachii',
      commonName: 'Triceps',
      category: MuscleCategory.triceps,
      isPrimary: true,
    ),
    
    // FOREARMS
    'brachioradialis': Muscle(
      id: 'brachioradialis',
      name: 'Brachioradialis',
      commonName: 'Forearm',
      category: MuscleCategory.forearms,
      isPrimary: true,
    ),
    'forearm_flexors': Muscle(
      id: 'forearm_flexors',
      name: 'Forearm Flexors',
      commonName: 'Inner Forearm',
      category: MuscleCategory.forearms,
    ),
    'forearm_extensors': Muscle(
      id: 'forearm_extensors',
      name: 'Forearm Extensors',
      commonName: 'Outer Forearm',
      category: MuscleCategory.forearms,
    ),
    
    // ABS
    'rectus_abdominis': Muscle(
      id: 'rectus_abdominis',
      name: 'Rectus Abdominis',
      commonName: 'Abs',
      category: MuscleCategory.abs,
      isPrimary: true,
    ),
    'obliques_external': Muscle(
      id: 'obliques_external',
      name: 'External Obliques',
      commonName: 'Side Abs',
      category: MuscleCategory.abs,
    ),
    'obliques_internal': Muscle(
      id: 'obliques_internal',
      name: 'Internal Obliques',
      commonName: 'Deep Side Abs',
      category: MuscleCategory.abs,
    ),
    'transverse_abdominis': Muscle(
      id: 'transverse_abdominis',
      name: 'Transverse Abdominis',
      commonName: 'Deep Core',
      category: MuscleCategory.abs,
    ),
    
    // GLUTES
    'gluteus_maximus': Muscle(
      id: 'gluteus_maximus',
      name: 'Gluteus Maximus',
      commonName: 'Glutes',
      category: MuscleCategory.glutes,
      isPrimary: true,
    ),
    'gluteus_medius': Muscle(
      id: 'gluteus_medius',
      name: 'Gluteus Medius',
      commonName: 'Side Glute',
      category: MuscleCategory.glutes,
    ),
    'gluteus_minimus': Muscle(
      id: 'gluteus_minimus',
      name: 'Gluteus Minimus',
      commonName: 'Deep Glute',
      category: MuscleCategory.glutes,
    ),
    
    // QUADS
    'quadriceps': Muscle(
      id: 'quadriceps',
      name: 'Quadriceps Femoris',
      commonName: 'Quads',
      category: MuscleCategory.quads,
      isPrimary: true,
    ),
    'rectus_femoris': Muscle(
      id: 'rectus_femoris',
      name: 'Rectus Femoris',
      commonName: 'Middle Quad',
      category: MuscleCategory.quads,
    ),
    'vastus_lateralis': Muscle(
      id: 'vastus_lateralis',
      name: 'Vastus Lateralis',
      commonName: 'Outer Quad',
      category: MuscleCategory.quads,
    ),
    'vastus_medialis': Muscle(
      id: 'vastus_medialis',
      name: 'Vastus Medialis',
      commonName: 'Inner Quad',
      category: MuscleCategory.quads,
    ),
    
    // HAMSTRINGS
    'hamstrings': Muscle(
      id: 'hamstrings',
      name: 'Hamstrings',
      commonName: 'Hamstrings',
      category: MuscleCategory.hamstrings,
      isPrimary: true,
    ),
    'biceps_femoris': Muscle(
      id: 'biceps_femoris',
      name: 'Biceps Femoris',
      commonName: 'Outer Hamstring',
      category: MuscleCategory.hamstrings,
    ),
    'semitendinosus': Muscle(
      id: 'semitendinosus',
      name: 'Semitendinosus',
      commonName: 'Inner Hamstring',
      category: MuscleCategory.hamstrings,
    ),
    
    // CALVES
    'gastrocnemius': Muscle(
      id: 'gastrocnemius',
      name: 'Gastrocnemius',
      commonName: 'Calves',
      category: MuscleCategory.calves,
      isPrimary: true,
    ),
    'soleus': Muscle(
      id: 'soleus',
      name: 'Soleus',
      commonName: 'Lower Calf',
      category: MuscleCategory.calves,
    ),
    
    // CORE (compound muscles that belong to multiple categories)
    'core_stabilizers': Muscle(
      id: 'core_stabilizers',
      name: 'Core Stabilizers',
      commonName: 'Deep Core',
      category: MuscleCategory.core,
      isPrimary: true,
    ),
    
    // CARDIO (special category)
    'cardiovascular': Muscle(
      id: 'cardiovascular',
      name: 'Cardiovascular System',
      commonName: 'Heart & Lungs',
      category: MuscleCategory.cardio,
      isPrimary: true,
    ),
    'respiratory': Muscle(
      id: 'respiratory',
      name: 'Respiratory Muscles',
      commonName: 'Breathing Muscles',
      category: MuscleCategory.cardio,
    ),
  };
  
  // Helper methods
  static List<Muscle> getMusclesByCategory(MuscleCategory category) {
    return muscles.values
        .where((muscle) => muscle.category == category)
        .toList();
  }
  
  static List<Muscle> getPrimaryMusclesByCategory(MuscleCategory category) {
    return muscles.values
        .where((muscle) => muscle.category == category && muscle.isPrimary)
        .toList();
  }
  
  static List<Muscle> getPrimaryMuscles() {
    return muscles.values
        .where((muscle) => muscle.isPrimary)
        .toList();
  }
  
  static Muscle? getMuscleById(String id) {
    return muscles[id];
  }
  
  // Get muscles that are commonly trained together
  static Map<MuscleCategory, List<MuscleCategory>> getRelatedCategories() {
    return {
      MuscleCategory.chest: [MuscleCategory.shoulders, MuscleCategory.triceps],
      // MuscleCategory.back: [MuscleCategory.biceps, MuscleCategory.rearShoulders],
      MuscleCategory.shoulders: [MuscleCategory.triceps, MuscleCategory.chest],
      MuscleCategory.quads: [MuscleCategory.glutes, MuscleCategory.hamstrings],
      // MuscleCategory.abs: [MuscleCategory.core, MuscleCategory.obliques],
    };
  }
}