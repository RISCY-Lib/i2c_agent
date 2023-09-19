//==============================================================================
// A I2C UVM Agent
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
// Description: The Defines for the UVM I2C Agent
//==============================================================================

`ifndef __I2C_DEFINES_SVH__
`define __I2C_DEFINES_SVH__

//------------------------------------------------------------------------------
// I2C Bus Parameters
//------------------------------------------------------------------------------
typedef enum {
    I2C_7_BIT_ADDR = 7,
    I2C_10_BIT_ADDR = 10
} i2c_addr_size_e;

typedef enum {
    I2C_READ = 1,
    I2C_WRITE = 0
} i2c_dir_e;

typedef enum {
    I2C_ACK = 0,
    I2C_NACK = 1
} i2c_ack_e;

typedef enum {
    I2C_STANDARD = 0,
    I2C_FAST = 1,
    I2C_FAST_PLUS = 2,
    I2C_HIGH_SPEED = 3
} i2c_speed_e;

//------------------------------------------------------------------------------
// I2C Timing Parameters
//------------------------------------------------------------------------------
typedef struct packed {
    realtime low_period;
    realtime high_period;

    realtime start_hold;
    realtime start_setup;

    realtime data_hold;
    realtime data_setup;

    realtime stop_setup;

    realtime bus_free;

    realtime data_valid;
    realtime data_ack;
} i2c_timing_t;

const i2c_timing_t I2C_STANDARD_TIMING = '{
    low_period:4.7us,
    high_period:4.0us,

    start_hold:4.0us,
    start_setup:4.7us,

    data_hold:0ns,
    data_setup:250ns,

    stop_setup:4.0us,

    bus_free:4.7us,

    data_valid:3.45us,
    data_ack:3.45us
};

const i2c_timing_t I2C_FAST_TIMING = '{
    low_period:1.3us,
    high_period:0.6us,

    start_hold:0.6us,
    start_setup:0.6us,

    data_hold:0ns,
    data_setup:100ns,

    stop_setup:0.6us,

    bus_free:1.3us,

    data_valid:0.9us,
    data_ack:0.9us
};

const i2c_timing_t I2C_FAST_PLUS_TIMING = '{
    low_period:0.5us,
    high_period:0.26us,

    start_hold:0.26us,
    start_setup:0.26us,

    data_hold:0ns,
    data_setup:50ns,

    stop_setup:0.26us,

    bus_free:0.5us,

    data_valid:0.35us,
    data_ack:0.35us
};

`endif // __I2C_DEFINES_SVH__