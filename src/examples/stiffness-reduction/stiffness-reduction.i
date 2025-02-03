# This test loads a saturated block

# ===== model units =====
# (m | s | Mg lead to [force] = kN  and [pressure] = kN/m²)
modelunit_length = 'm'
modelunit_time = 's' #s = seconds, h = hours, day = days
modelunit_mass = 'Mg' # kg = kilograms, Mg = tons; Gg = kilotons

# ===== derived units (this may be moved into a !include) ===== 
modelunit_area = '${raw ${modelunit_length} ^ 2}'
modelunit_volume = '${raw ${modelunit_length} ^ 3}'
modelunit_force = '${raw ${modelunit_mass} * ${modelunit_length} / ${modelunit_time} ^ 2}'
modelunit_pressure = '${raw ${modelunit_force} / ${modelunit_area}}'
modelunit_acceleration = '${raw ${modelunit_length} / ${modelunit_time} ^ 2}'
modelunit_density = '${raw ${modelunit_mass} / ${modelunit_volume}}'

# ===== Some constants =====
gravitational_acceleration = '${units 9.81 m/s^2 -> ${modelunit_acceleration}}'

material_density = '${units 2500 kg/m^3 -> ${modelunit_density} }'

# ===== General model setup =====
[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  use_displaced_mesh = false
[]

[Problem]
  solve = true
[]

# ===== Mesh =====
[Mesh]
  [BaseMesh]
    type = GeneratedMeshGenerator
    subdomain_name = 'BaseMesh'
    elem_type = 'TET10'
    dim = 3
    nx = 6
    ny = 6
    nz = 6
    xmin = -0.5
    xmax = +0.5
    ymin = -0.5
    ymax = +0.5
    zmin = -0.5
    zmax = +0.5
  []
[]

# ===== Variables =====
[Variables]
  [disp_x]
    family = LAGRANGE
    order = SECOND
  []
  [disp_y]
    family = LAGRANGE
    order = SECOND
  []
  [disp_z]
    family = LAGRANGE
    order = SECOND
  []
[]

# ===== SolidMechanics =====
[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL
        incremental = true
        add_variables = false
        eigenstrain_names = 'ini_stress'
      []
    []
  []
[]

# ===== Kernels: Gravity =====
[Kernels]
  [gravity]
    type = Gravity
    variable = disp_z
    value = -${gravitational_acceleration}
  []
[]

# ===== AuxVariable & AuxKernel: stress =====
# for demonstration: stress_zz is defined as second order
[AuxVariables]
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zz]
    order = SECOND
    family = MONOMIAL
  []
  [stress_xy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_xz]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yz]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_maxprincipal]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_minprincipal]
    order = CONSTANT
    family = MONOMIAL
  []
[]
[AuxKernels]
  [stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    variable = stress_xx
  []
  [stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    variable = stress_yy
  []
  [stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 2
    variable = stress_zz
  []
  [stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 1
    variable = stress_xy
  []
  [stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 2
    variable = stress_yz
  []
  [stress_xz]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 0
    variable = stress_xz
  []
  [stress_maxprincipal]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = stress_maxprincipal
    scalar_type = MaxPrincipal
  []
  [stress_minprincipal]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = stress_minprincipal
    scalar_type = MinPrincipal
  []
[]

# ===== AuxVariable & AuxKernel: p & q =====
[AuxVariables]
  [p]
    order = CONSTANT
    family = MONOMIAL
  []
  [q]
    order = CONSTANT
    family = MONOMIAL
  []
[]
[AuxKernels]
  [p]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = p
    scalar_type = hydrostatic
  []
  [q]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = q
    scalar_type = vonMisesStress
  []
[]

# ===== fix the model boundaries (displacement = 0) =====
# no BC for 'front' - this is where we apply a pressure
  [BCs]

  [left_fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0.0
  []
  [right_fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0.0
  []

  [top_fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'top'
    value = 0.0
  []
  [bottom_fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0.0
  []

  [back_fix_z]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0.0
  []
[]

# apply a pressure at ZMax
[BCs]
  [front_Pressure]
    type = Pressure
    variable = disp_z
    boundary = 'front'
    factor = '${units 1 kN/m^2 -> ${modelunit_pressure} }'
  []
[]

# ===== Initial Conditions: Initial Stress Field =====
# due to gravity, the initial stress field is geostatic
[Functions]
  sig_top = '${units -1.0 kN/m^2 -> ${modelunit_pressure} }'
  z_top = 0.5
  K0 = 0.5
  buoyantDensity = ${material_density}
  [ini_xx]
    type = ParsedFunction
    expression = '(sig_top - rho * g * (z_top - z)) * K0'
    symbol_names = 'sig_top     z_top      rho                   g                              K0   '
    symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}  ${K0}'
  []
  [ini_yy]
    type = ParsedFunction
    expression = '(sig_top - rho * g * (z_top - z)) * K0'
    symbol_names = 'sig_top     z_top      rho                   g                              K0   '
    symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}  ${K0}'
  []
  [ini_zz]
    type = ParsedFunction
    expression = '(sig_top - rho * g * (z_top - z))'
    symbol_names = 'sig_top     z_top      rho                   g                               K0  '
    symbol_values = '${sig_top}  ${z_top}   ${buoyantDensity}   ${gravitational_acceleration}   ${K0}'
  []
[]

# ===== Function: Youngs modulus over time =====
[Functions]
  E_t0 = '${units 1000 kN/m^2 -> ${modelunit_pressure} }'
  E_t1 = '${units  500 kN/m^2 -> ${modelunit_pressure} }'
  [func_YoungsModulus]
    type = ParsedFunction
    expression = 'E_t0 + (E_t1 - E_t0) * max(min(t - 0.1,1),0)'
    symbol_names = 'E_t0       E_t1'
    symbol_values = '${E_t0}  ${E_t1}'
  []
[]

# ===== Material: Volume Elements =====
[Materials]

  # just a linear-elastic material
  [YoungsModulusParsedMaterial]
    type = ParsedMaterial
    property_name = YoungsModulusParsedMaterial
    functor_names  = 'func_YoungsModulus'
    functor_symbols  = 'E'
    expression = 'E'
    outputs = 'exodus'
  []
  [elasticity_tensor]
    type = ComputeVariableIsotropicElasticityTensor
    youngs_modulus = 'YoungsModulusParsedMaterial'
    poissons_ratio = 0.0
    args = ''
  []
  [stress]
    type = ComputeFiniteStrainElasticStress
  []

  # initial stresses
  [eigenstrain]
    type = ComputeEigenstrainFromInitialStress
    eigenstrain_name = 'ini_stress'
    initial_stress = 'ini_xx 0 0  0 ini_yy 0  0 0 ini_zz'
  []

  # material density
  [density_0]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = '${material_density}'
  []

[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true

    petsc_options = '-ksp_snes_ew'
    petsc_options_iname = '-ksp_type -pc_type -pc_hypre_type -sub_pc_type -sub_pc_factor_shift_type -sub_pc_factor_levels -ksp_gmres_restart'
    petsc_options_value = ' gmres     hypre    boomeramg      lu           NONZERO                   4                     301'

  []
[]

[Executioner]
  type = Transient
  verbose = true

  solve_type = 'NEWTON'

  line_search = none

  l_max_its = 20
  nl_max_its = 5

  start_time = 0.0
  end_time = 1.1
  dtmin = 1e-2
  [TimeSteppers]
    [TimeSequenceStepper1]
      type = TimeSequenceStepper
      time_sequence = '0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1'
    []
  []

  [Quadrature]
    type = SIMPSON
    order = SECOND
  []
[]

[Postprocessors]
  [top_disp_z]
    type = PointValue
    variable = disp_z
    point = '0.0 0.0 0.5'
    outputs = 'csv'
  []
  [top_stress_zz]
    type = PointValue
    variable = stress_zz
    point = '0.0 0.0 0.5'
    outputs = 'csv'
  []
[]

[Outputs]
  perf_graph = true

  exodus = true

  [csv]
    type = CSV
    execute_on = 'TIMESTEP_END FINAL'
    align = true
  []
[]

[Debug]
  show_var_residual_norms = true
[]
