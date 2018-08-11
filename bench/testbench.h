#ifndef TESTBENCH_H
#define TESTBENCH_H

#include <verilated.h>
#include <verilated_vcd_c.h>

template <class MODULE>	class TB_COMBINATIONAL {
public:
    MODULE *m_core;
    VerilatedVcdC* m_trace;
    vluint64_t m_tickcount;

    TB_COMBINATIONAL(void) : m_trace(NULL), m_tickcount(0) {
        m_core = new MODULE;
        Verilated::traceEverOn(true);
    }

    virtual ~TB_COMBINATIONAL(void) {
        closetrace();
        m_core->final();
        delete m_core;
        m_core = NULL;
    }

    virtual	void opentrace(const char *vcdname) {
        if (!m_trace) {
            m_trace = new VerilatedVcdC;
            m_core->trace(m_trace, 99);
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
        m_core->eval();
    }

    virtual void dump_trace() {
        if (m_trace) {
            m_trace->dump(m_tickcount);
        }
    }

    virtual	void tick(void) {
        eval();
        m_tickcount++;
        dump_trace();
    }

    unsigned long tick_count(void) {
        return m_tickcount;
    }
};

#endif // TESTBENCH_H