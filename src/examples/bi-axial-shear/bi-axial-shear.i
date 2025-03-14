# testing CappedMohrCoulomb with axial compressive loading under bi-axial test conditions
# 
# From analytical solution, the maximum pressure at the zmax-face is 6.4541 kN/m²
#
# for details on the problem see
# https://communities.bentley.com/cfs-file/__key/communityserver-wikis-components-files/00-00-00-05-58/PlxValidation_2D00_Bi_2D00_axial_5F00_compression_5F00_test_5F00_with_5F00_Mohr_2D00_Coulomb_5F00_model_2D00_2018.pdf

# ===== model units =====
# (m | s | Mg lead to [force] = kN  and [pressure] = kN/m²)
modelunit_length = 'm'
modelunit_time = 's' #s = seconds, h = hours, day = days
modelunit_mass = 'Mg' # kg = kilograms, Mg = tons; Gg = kilotons

# ===== derived units (this may be moved into a !include) =====
modelunit_area = '${raw ${modelunit_length} ^ 2}'
modelunit_force = '${raw ${modelunit_mass} * ${modelunit_length} / ${modelunit_time} ^ 2}'
modelunit_pressure = '${raw ${modelunit_force} / ${modelunit_area}}'

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 6
  ny = 6
  nz = 6
  xmin = 0.0
  xmax = 1.0
  ymin = 0.0
  ymax = 1.0
  zmin = 0.0
  zmax = 1.0
  elem_type = TET10
  # side sets:
  #   name     id   location
  #   back     0    z = zmin
  #   bottom   1    y = ymin
  #   right    2    x = xmax
  #   top      3    y = ymax
  #   left     4    x = xmin
  #   front    5    z = zmax
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        add_variables = true
        incremental = true
        generate_output = 'max_principal_stress mid_principal_stress min_principal_stress stress_xx stress_xy stress_xz stress_yy stress_yz stress_zz'
      []
    []
  []
[]

[BCs]
  [bottom_normal]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0
  []
  [top_normal]
    type = DirichletBC
    variable = disp_y
    boundary = 'top'
    value = 0
  []

  [left_normal]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
  []

  [back_normal]
    type = DirichletBC
    variable = disp_z
    boundary = 'back'
    value = 0
  []

  [Pressure]
    [right]
      boundary = right #xmax
      function = '${units 1.0 kN/m^2 -> ${modelunit_pressure} }'
    []
    [front]
      boundary = front #zmax
      function = '${units 1.0 kN/m^2 -> ${modelunit_pressure} } * t'
    []
  []
[]

[AuxVariables]
  [f0]
    order = CONSTANT
    family = MONOMIAL
  []
  [f1]
    order = CONSTANT
    family = MONOMIAL
  []
  [f2]
    order = CONSTANT
    family = MONOMIAL
  []
  [iter]
    order = CONSTANT
    family = MONOMIAL
  []
  [intnl]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [f0_auxk]
    type = MaterialStdVectorAux
    property = plastic_yield_function
    index = 0
    variable = f0
  []
  [f1_auxk]
    type = MaterialStdVectorAux
    property = plastic_yield_function
    index = 1
    variable = f1
  []
  [f2_auxk]
    type = MaterialStdVectorAux
    property = plastic_yield_function
    index = 2
    variable = f2
  []
  [iter]
    type = MaterialRealAux
    property = plastic_NR_iterations
    variable = iter
  []
  [intnl_auxk]
    type = MaterialStdVectorAux
    property = plastic_internal_parameter
    index = 1
    variable = intnl
  []
[]

[UserObjects]
  [ts]
    type = SolidMechanicsHardeningConstant
    value = '${units 1e6 N/m^2 -> ${modelunit_pressure} }'
  []
  [cs]
    type = SolidMechanicsHardeningConstant
    value =  '${units 1e6 N/m^2 -> ${modelunit_pressure} }'
  []
  [coh]
    type = SolidMechanicsHardeningConstant
    value = '${units 1 kN/m^2 -> ${modelunit_pressure} }'
  []
  [angphi]
    type = SolidMechanicsHardeningConstant
    value = 30
    convert_to_radians = true
  []
  [angpsi]
    type = SolidMechanicsHardeningConstant
    value = 0.001
    convert_to_radians = true
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${units 1000 kN/m^2 -> ${modelunit_pressure} }'
    poissons_ratio = 0.25
  []
  [tensile]
    type = CappedMohrCoulombStressUpdate
    tensile_strength = ts
    compressive_strength = cs
    cohesion = coh
    friction_angle = angphi
    dilation_angle = angpsi
    smoothing_tol = '${units 0.001 N/m^2 -> ${modelunit_pressure} }'
    yield_function_tol = 1.0E-12  #is this stress?
  []
  [stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = tensile
    perform_finite_strain_rotations = false
  []
[]

[Executioner]
  type = Transient
  #automatic_scaling = true
  #compute_scaling_once=false
  solve_type = 'PJFNK'

  petsc_options = '-snes_converged_reason'

  # best overall
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = ' lu       mumps'

  # best if you do not have mumps:
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = ' lu       superlu_dist'

  line_search = none

  # tolerances of the (nested) linear solve
  #l_abs_tol = 1e-50
  l_tol = 1e-5
  l_max_its = 10

  # tolerances of the (outer) nonlinear solve
  #nl_abs_tol = 5e-5
  nl_rel_tol = 1e-3
  nl_max_its = 5

  start_time = 0.0
  end_time = 10
  dt = .25
  dtmin = 0.001
[]

[Outputs]
  exodus = true
[]

[Debug]
  show_var_residual_norms = true
[]
