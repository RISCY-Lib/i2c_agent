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
// Description: The UVM I2C Agent
//==============================================================================

class i2c_agent extends uvm_component;
    `uvm_component_utils(i2c_agent)

    //------------------------------------------------------------------------------
    // Members
    //------------------------------------------------------------------------------
    i2c_agent_config m_cfg;

    // Analysis ports
    uvm_analysis_port #(i2c_seq_item) ap;

    i2c_monitor m_monitor;
    i2c_sequencer m_sequencer;
    i2c_driver m_driver;

    //------------------------------------------------------------------------------
    // Methods
    //------------------------------------------------------------------------------

    // Standard UVM methods
    function new(string name = "i2c_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `get_config(i2c_agent_config, m_cfg, "i2c_agent_config")

        // Monitor is always present
        m_monitor = i2c_monitor::type_id::create("m_monitor", this);
        m_monitor.m_cfg = m_cfg;
        ap = new ("ap", this);

        // Only build the driver and sequencer if active
        if (m_cfg.active == UVM_ACTIVE) begin
            m_driver = i2c_driver::type_id::create("m_driver", this);
            m_driver.m_cfg = m_cfg;
            m_sequencer = i2c_sequencer::type_id::create("m_sequencer", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        // Only connect the driver and the sequencer if active
        if (m_cfg.active == UVM_ACTIVE) begin
            m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
        end

        // Connect the monitor to the analysis port
        m_monitor.ap.connect(ap);
    endfunction: connect_phase

endclass: i2c_agent