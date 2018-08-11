#ifndef TESTBENCH_H
#define TESTBENCH_H

#include <verilated.h>
#include <verilated_vcd_c.h>

template<class MODULE>	class TB_COMBINATIONAL {
public:
    MODULE *m_dut;
    VerilatedVcdC* m_trace;
    vluint64_t m_tickcount;

    TB_COMBINATIONAL(void) : m_trace(NULL), m_tickcount(0) {
        m_dut = new MODULE;
        Verilated::traceEverOn(true);
    }

    virtual ~TB_COMBINATIONAL(void) {
        closetrace();
        m_dut->final();
        delete m_dut;
        m_dut = NULL;
    }

    virtual	void opentrace(const char *vcdname) {
        if (!m_trace) {
            m_trace = new VerilatedVcdC;
            m_dut->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }

    virtual	void closetrace(void) {
        if (m_trace) {
            m_trace->close();
            delete m_trace;
            m_trace = NULL;
        }
    }

    virtual	void eval(void) {
        m_dut->eval();
    }

    virtual void dump_trace() {
        if (m_trace) {
            m_trace->dump(m_tickcount);
        }
    }

    virtual	void tick(void) {
        eval();
        dump_trace();
        m_tickcount++;
    }

    unsigned long tick_count(void) {
        return m_tickcount;
    }
};

template<class MODULE>	class TB_SEQUENTIAL {
public:
    MODULE *m_dut;
    VerilatedVcdC* m_trace;
    vluint64_t m_tickcount;

    TB_SEQUENTIAL(void) : m_trace(NULL), m_tickcount(0) {
        m_dut = new MODULE;
        Verilated::traceEverOn(true);
    }

    virtual ~TB_SEQUENTIAL(void) {
        closetrace();
        m_dut->final();
        delete m_dut;
        m_dut = NULL;
    }

    virtual	void opentrace(const char *vcdname) {
        if (!m_trace) {
            m_trace = new VerilatedVcdC;
            m_dut->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }

    virtual	void closetrace(void) {
        if (m_trace) {
            m_trace->close();
            delete m_trace;
            m_trace = NULL;
        }
    }

    virtual	void eval(void) {
        m_dut->eval();
    }

    virtual void dump_trace() {
        if (m_trace) {
            m_trace->dump(m_tickcount);
        }
    }

    virtual	void tick(void) {
        // Falling edge
        m_dut->clk = 0;
        eval();
        dump_trace();
        m_tickcount++;

        // Rising edge
        m_dut->clk = 1;
        eval();
        dump_trace();
        m_tickcount++;
    }

    unsigned long tick_count(void) {
        return m_tickcount;
    }
};

#endif // TESTBENCH_H