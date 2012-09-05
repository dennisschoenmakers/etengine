module Qernel
  class ConverterApi
    # Used by the data/converter/show page
    ELECTRICITY_PRODUCTION_VALUES  =  {
      :technical => {
        :nominal_capacity_electricity_output_per_unit => ['Nominal electrical capacity','MW'],
        :average_effective_output_of_nominal_capacity_over_lifetime => ['Average effective output of nominal capacity over lifetime', '%'],
        :full_load_hours  => ['Full load hours', 'hour / year'],
        :electricity_output_conversion  => ['Electrical efficiency', '%'],
        :heat_output_conversion  => ['Heat efficiency', '%']
      },
      :cost => {
        :initial_investment_excl_ccs_per_mwe => ['Initial investment (excl CCS)', 'euro / MWe'],
        :additional_investment_ccs_per_mwe => ['Additional inititial investment for CCS', 'euro / MWe'],
        :decommissioning_costs_per_mwe => ['Decommissioning costs','euro / MWe'],
        :fixed_yearly_operation_and_maintenance_costs_per_mwe => ['Fixed operation and maintenance costs','euro / MWe / year'],
        :operation_and_maintenance_cost_variable_per_full_load_hour  => ['Variable operation and maintenance costs (excl CCS)', 'euro / full load hour'],
        :ccs_operation_and_maintenance_cost_per_full_load_hour  => ['Additional variable operation and maintenance costs for CCS', 'euro / full load hour'],
        :wacc  => ['Weighted average cost of capital', '%'],
        :part_ets  => ['Do emissions have to be paid for through the ETS?', 'yes=1 / no=0']
      },
      :other => {
        :land_use_per_unit  => ['Land use per unit', 'km2'],
        :construction_time  => ['Construction time', 'year'],
        :technical_lifetime  => ['Technical lifetime', 'year']
      }
    }

    HEAT_PRODUCTION_VALUES  =  {
      :technical => {
        :nominal_capacity_heat_output_per_unit => ['Nominal heat capacity','MW'],
        :average_effective_output_of_nominal_capacity_over_lifetime => ['Average effective output of nominal capacity over lifetime', '%'],
        :full_load_hours  => ['Full load hours', 'hour / year'],
        :heat_output_conversion  => ['Heat efficiency', '%']
      },
      :cost => {
        :purchase_price_per_unit => ['Initial purchase price', 'euro'],
        :installing_costs_per_unit => ['Cost of installing','euro'],
        :residual_value_per_unit => ['Residual value after lifetime','euro'],
        :decommissioning_costs_per_unit => ['Decommissioning costs','euro'],
        :fixed_yearly_operation_and_maintenance_costs_per_unit => ['Fixed operation and maintenance costs','euro / year'],
        :operation_and_maintenance_cost_variable_per_full_load_hour  => ['Variable operation and maintenance costs', 'euro / full load hour'],
        :wacc  => ['Weighted average cost of capital', '%'],
        :part_ets  => ['Do emissions have to be paid for through the ETS?', 'yes=1 / no=0']
      },
      :other => {
        :land_use_per_unit  => ['Land use per unit', 'km2'],
        :technical_lifetime  => ['Technical lifetime', 'year']
      }
    }

    HEAT_PUMP_VALUES  =  {
      :technical => {
        :nominal_capacity_heat_output_per_unit => ['Nominal heat capacity','MW'],
        :average_effective_output_of_nominal_capacity_over_lifetime => ['Average effective output of nominal capacity over lifetime', '%'],
        :full_load_hours  => ['Full load hours', 'hour / year'],
        :coefficient_of_performance => ['Coefficient of Performance', ''],
        :heat_and_cold_output_conversion  => ['Efficiency (after COP)', '%']
      },
      :cost => {
        :purchase_price_per_unit => ['Initial purchase price', 'euro'],
        :installing_costs_per_unit => ['Cost of installing','euro'],
        :residual_value_per_unit => ['Residual value after lifetime','euro'],
        :decommissioning_costs_per_unit => ['Decommissioning costs','euro'],
        :fixed_yearly_operation_and_maintenance_costs_per_unit => ['Fixed operation and maintenance costs','euro / year'],
        :operation_and_maintenance_cost_variable_per_full_load_hour  => ['Variable operation and maintenance costs', 'euro / full load hour'],
        :wacc  => ['Weighted average cost of capital', '%'],
        :part_ets  => ['Do emissions have to be paid for through the ETS?', 'yes=1 / no=0']
      },
      :other => {
        :land_use_per_unit  => ['Land use per unit', 'km2'],
        :technical_lifetime  => ['Technical lifetime', 'year']
      }
    }

    CHP_VALUES  =  {
      :technical => {
        :nominal_capacity_electricity_output_per_unit => ['Nominal electrical capacity','MW'],
        :nominal_capacity_heat_output_per_unit => ['Nominal heat capacity','MW'],
        :average_effective_output_of_nominal_capacity_over_lifetime => ['Average effective output of nominal capacity over lifetime', '%'],
        :full_load_hours  => ['Full load hours', 'hour / year'],
        :electricity_output_conversion  => ['Electrical efficiency', '%'],
        :heat_output_conversion  => ['Heat efficiency', '%']
      },
      :cost => {
        :initial_investment_excl_ccs_per_unit => ['Initial investment (excl CCS)', 'euro'],
        :additional_investment_ccs_per_unit => ['Additional inititial investment for CCS', 'euro'],
        :decommissioning_costs_per_unit => ['Decommissioning costs','euro'],
        :fixed_yearly_operation_and_maintenance_costs_per_unit => ['Fixed operation and maintenance costs','euro / year'],
        :operation_and_maintenance_cost_variable_per_full_load_hour  => ['Variable operation and maintenance costs (excl CCS)', 'euro / full load hour'],
        :ccs_operation_and_maintenance_cost_per_full_load_hour  => ['Additional variable operation and maintenance costs for CCS', 'euro / full load hour'],
        :wacc  => ['Weighted average cost of capital', '%'],
        :part_ets  => ['Do emissions have to be paid for through the ETS?', 'yes=1 / no=0']
      },
      :other => {
        :land_use_per_unit  => ['Land use per unit', 'km2'],
        :construction_time  => ['Construction time', 'year'],
        :technical_lifetime  => ['Technical lifetime', 'year']
      }
    }
  end
end