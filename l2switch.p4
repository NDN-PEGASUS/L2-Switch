/***************************************************************
    L2 SWITCH
 **************************************************************/
#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

// #define PORT_METADATA_SIZE 64

// ---------------------------------------------------------------------------
// Headers
// ---------------------------------------------------------------------------

/* Device IDs of switch ports */
#define SWITCH_PORT_03 152
#define SWITCH_PORT_04 160
#define SWITCH_PORT_05 168
#define SWITCH_PORT_06 176
/* MAC addresses of server adapters */
#define SERVER1_NIC2_1 0x0c42a13a6768
#define SERVER1_NIC2_2 0x0c42a13a6769
#define SERVER2_NIC2_1 0x1070fd31f3bc
#define SERVER2_NIC2_2 0x1070fd31f3bd

typedef bit<48> MacAddress;

header ethernet_h {
    MacAddress dst;
    MacAddress src;
    bit<16> etherType; 
}

// ---------------------------------------------------------------------------
// struct
// ---------------------------------------------------------------------------

struct headers { 
    ethernet_h ethernet;
}

// user defined metadata
struct ig_metadata_t {

}

struct eg_metadata_t {

}

// ---------------------------------------------------------------------------
// Ingress Parser
// ---------------------------------------------------------------------------

parser SwitchIngressParser(
        packet_in pkt,
        out headers hdr,
        out ig_metadata_t ig_md,
        out ingress_intrinsic_metadata_t ig_intr_md) {

    state start {
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);

        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);

        transition accept;
    }
}

// ---------------------------------------------------------------------------
// Ingress
// ---------------------------------------------------------------------------

control SwitchIngress(
        inout headers hdr,
        inout ig_metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {


    // action SetOutPort(PortId_t port) {
    //     ig_tm_md.ucast_egress_port = port;
    // }
    action SetToServerBySwitchPort03() {
        ig_tm_md.ucast_egress_port = SWITCH_PORT_03;
    }
    action SetToServerBySwitchPort04() {
        ig_tm_md.ucast_egress_port = SWITCH_PORT_04;
    }
    action SetToServerBySwitchPort05() {
        ig_tm_md.ucast_egress_port = SWITCH_PORT_05;
    }
    action SetToServerBySwitchPort06() {
        ig_tm_md.ucast_egress_port = SWITCH_PORT_06;
    }
    table forward_table {
        key = {
            hdr.ethernet.dst : exact;
        }
        actions = {
            SetToServerBySwitchPort03;
            SetToServerBySwitchPort04;
            SetToServerBySwitchPort05;
            SetToServerBySwitchPort06;
            NoAction;
        }
        default_action = NoAction;
        size = 4;
        const entries = {
            (SERVER1_NIC2_1) : SetToServerBySwitchPort03();
            (SERVER1_NIC2_2) : SetToServerBySwitchPort04();
            (SERVER2_NIC2_1) : SetToServerBySwitchPort05();
            (SERVER2_NIC2_2) : SetToServerBySwitchPort06();
        }
    }

    apply{
        forward_table.apply();
    }
}

// ---------------------------------------------------------------------------
// Ingress Deparser
// ---------------------------------------------------------------------------

control SwitchIngressDeparser(
        packet_out pkt,
        inout headers hdr,
        in ig_metadata_t ig_md,
        in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {

    apply {
        pkt.emit(hdr);
    }
}

// ---------------------------------------------------------------------------
// Egress Parser
// ---------------------------------------------------------------------------

parser SwitchEgressParser(
        packet_in pkt,
        out headers hdr,
        out eg_metadata_t eg_md,
        out egress_intrinsic_metadata_t eg_intr_md) {

    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}

// ---------------------------------------------------------------------------
// Egress
// ---------------------------------------------------------------------------

control SwitchEgress(
        /* User */
        inout headers p,
        inout eg_metadata_t meta,
        /* Intrinsic */
        in    egress_intrinsic_metadata_t eg_intr_md,
        in    egress_intrinsic_metadata_from_parser_t eg_prsr_md,
        inout egress_intrinsic_metadata_for_deparser_t eg_dprsr_md,
        inout egress_intrinsic_metadata_for_output_port_t eg_oport_md) {
    
    apply {
        // p.ipv4.dst = eg_prsr_md.global_tstamp[31:0];
        // p.ethernet.src = eg_prsr_md.global_tstamp;
    }
}

// ---------------------------------------------------------------------------
// Egress Deparser
// ---------------------------------------------------------------------------

control SwitchEgressDeparser(
        packet_out pkt,
        /* User */
        inout headers hdr,
        in eg_metadata_t meta,
        /* Intrinsic */
        in egress_intrinsic_metadata_for_deparser_t eg_dprsr_md)
{
    apply {
        pkt.emit(hdr);
    }
}

// ---------------------------------------------------------------------------
// Pipeline
// ---------------------------------------------------------------------------

Pipeline(SwitchIngressParser(),
         SwitchIngress(),
         SwitchIngressDeparser(),
         SwitchEgressParser(),
         SwitchEgress(),
         SwitchEgressDeparser()) pipe;

Switch(pipe) main;