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
// Description: The Monitor BFM for the UVM I2C Agent
//==============================================================================

interface i2c_monitor_bfm (
    i2c_if i2c
);

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import i2c_agent_pkg::*;

    //----------------------------------------------------------------------
    // Members
    //----------------------------------------------------------------------
    // Config
    i2c_agent_config m_cfg;

    i2c_monitor proxy;

    i2c_seq_item i2c_frame;
    i2c_data_package i2c_data_pkg;
    logic [7:0] data;
    i2c_ack_e ack;

    //----------------------------------------------------------------------
    // i2c Monitor interface
    //----------------------------------------------------------------------

    task mon_i2c();
        i2c_frame = i2c_seq_item::type_id::create("i2c_frame");

        // Wait for the bus to be in the correct state
        wait_start_state();

        fork
            wait_stop();

            forever begin
                _mon_data_pkg();
            end
        join_any

        disable fork;

        if (i2c_frame.data_pkgs.size() >= 1)
            proxy.notify_transaction(i2c_frame);
    endtask

    task _mon_data_pkg();
        fork
            begin
                fork
                    wait_start_state();

                    begin

                        i2c_data_pkg = i2c_data_package::type_id::create("i2c_data_pkg");
                        i2c_frame.data_pkgs.push_back(i2c_data_pkg);

                        mon_byte(data, ack);

                        // TODO: Check for correct address
                        i2c_data_pkg.dir = data[0];

                        forever begin
                            mon_byte(data, ack);

                            i2c_data_pkg.data.push_back(data);
                        end
                    end
                join_any

                disable fork;
            end
        join

    endtask

    task wait_start_state();
        forever begin
            // Wait for the bus to be in the correct state
            while (i2c.scl !== 1'b1 || i2c.sda !== 1'b1) begin
                @(i2c.scl or i2c.sda);
            end

            @(i2c.sda);

            if (i2c.scl === 1'b1) begin
                @(i2c.scl);
                return;
            end

        end

    endtask

    task wait_stop();
        forever begin
            @(i2c.sda);
            if (i2c.sda == 1'b1 && i2c.scl == 1'b1) begin
                break;
            end
        end
    endtask

    task mon_byte(output logic[7:0] _byte, output i2c_ack_e ack);
        for (int idx = 7; idx >= 0; idx--) begin
            @(posedge i2c.scl);
            _byte[idx] = i2c.sda;
        end

        @(posedge i2c.scl);
        ack = i2c.sda;
    endtask

endinterface