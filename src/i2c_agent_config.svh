//==============================================================================
// An I2C UVM Agent
// Copyright (C) 2023  RISCY-Lib Contributors
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; If not, see <https://www.gnu.org/licenses/>.
//==============================================================================

//==============================================================================
// Description: The Configuration Object for the UVM I2C Agent
//==============================================================================

`ifndef __I2C_AGENT_CONFIG_SVH__
`define __I2C_AGENT_CONFIG_SVH__

class i2c_agent_config extends uvm_object;

    localparam string s_my_config_id = "i2c_agent_config";

    // UVM Factory Registration Macro
    `uvm_object_utils(i2c_agent_config)

    //-------------------------------------------------------------------------
    // Members
    //-------------------------------------------------------------------------

    // BFM Virtual Interfaces
    virtual i2c_monitor_bfm mon_bfm;
    virtual i2c_driver_bfm  drv_bfm;

    // Timing Configuration
    i2c_timing_t timing = I2C_STANDARD_TIMING;

    // Transmission States
    logic high = 1'bZ;
    logic low = 1'b0;

    // Is the agent active or passive
    uvm_active_passive_enum active = UVM_ACTIVE;
    bit has_functional_coverage = 0;

    //------------------------------------------
    // Methods
    //------------------------------------------

    function new(string name = "i2c_agent_config");
        super.new(name);
    endfunction

    // Returns the global uart Agent Configuration
    static function i2c_agent_config get_config( uvm_component c );
        i2c_agent_config t;

        if (!uvm_config_db #(i2c_agent_config)::get(c, "", s_my_config_id, t) )
            `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

        return t;
    endfunction

    function bit check_timing(i2c_speed_e speed);
        i2c_timing_t speed_spec;

        check_timing = 1'b0;

        case (speed)
            I2C_STANDARD: speed_spec = I2C_STANDARD_TIMING;
            I2C_FAST: speed_spec = I2C_FAST_TIMING;
            I2C_FAST_PLUS: speed_spec = I2C_FAST_PLUS_TIMING;
            default:
                `uvm_fatal("I2C Agent Config", "I2C_HIGH_SPEED not currently supported")
        endcase

        if (this.timing.low_period < speed_spec.low_period) begin
            `uvm_warning("I2C Agent Config", $sformatf("Low Period Below Spec: %fns (spec %fns)", this.timing.low_period, speed_spec.low_period))
            check_timing = 1'b1;
        end

        // TODO: Finish

    endfunction

endclass: i2c_agent_config

`endif  // __I2C_AGENT_CONFIG_SVH__