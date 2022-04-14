//===-- RISCVInstrInfoF.td - RISC-V 'F' instructions -------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the RISC-V instructions from the standard 'F',
// Single-Precision Floating-Point instruction set extension.
//
// Remnants of original merge of Zfinx into this file remain. However Zfinx
// is now in a separate file RISCVInstrInfoZfinx.td
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// RISC-V specific DAG Nodes.
//===----------------------------------------------------------------------===//

//def SDT_RISCVFMV_W_X_RV64
//    : SDTypeProfile<1, 1, [SDTCisVT<0, f32>, SDTCisVT<1, i64>]>;
//def SDT_RISCVFMV_X_ANYEXTW_RV64
//    : SDTypeProfile<1, 1, [SDTCisVT<0, i64>, SDTCisVT<1, f32>]>;
//def SDT_RISCVFCVT_W_RV64
//    : SDTypeProfile<1, 2, [SDTCisVT<0, i64>, SDTCisFP<1>,
//                           SDTCisVT<2, i64>]>;
//def SDT_RISCVFCVT_X
//    : SDTypeProfile<1, 2, [SDTCisVT<0, XLenVT>, SDTCisFP<1>,
//                           SDTCisVT<2, XLenVT>]>;

/*
def riscv_fmv_w_x_rv64
    : SDNode<"RISCVISD::FMV_W_X_RV64", SDT_RISCVFMV_W_X_RV64>;
def riscv_fmv_x_anyextw_rv64
    : SDNode<"RISCVISD::FMV_X_ANYEXTW_RV64", SDT_RISCVFMV_X_ANYEXTW_RV64>;
def riscv_fcvt_w_rv64
    : SDNode<"RISCVISD::FCVT_W_RV64", SDT_RISCVFCVT_W_RV64>;
def riscv_fcvt_wu_rv64
    : SDNode<"RISCVISD::FCVT_WU_RV64", SDT_RISCVFCVT_W_RV64>;
def riscv_fcvt_x
    : SDNode<"RISCVISD::FCVT_X", SDT_RISCVFCVT_X>;
def riscv_fcvt_xu
    : SDNode<"RISCVISD::FCVT_XU", SDT_RISCVFCVT_X>;

def riscv_strict_fcvt_w_rv64
    : SDNode<"RISCVISD::STRICT_FCVT_W_RV64", SDT_RISCVFCVT_W_RV64,
             [SDNPHasChain]>;
def riscv_strict_fcvt_wu_rv64
    : SDNode<"RISCVISD::STRICT_FCVT_WU_RV64", SDT_RISCVFCVT_W_RV64,
             [SDNPHasChain]>;

def riscv_any_fcvt_w_rv64 : PatFrags<(ops node:$src, node:$frm),
                                     [(riscv_strict_fcvt_w_rv64 node:$src, node:$frm),
                                      (riscv_fcvt_w_rv64 node:$src, node:$frm)]>;
def riscv_any_fcvt_wu_rv64 : PatFrags<(ops node:$src, node:$frm),
                                      [(riscv_strict_fcvt_wu_rv64 node:$src, node:$frm),
                                       (riscv_fcvt_wu_rv64 node:$src, node:$frm)]>;
*/

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
//===----------------------------------------------------------------------===//

def GPRAsFPR : AsmOperandClass {
  let Name = "GPRAsFPR";
  let ParserMethod = "parseGPRAsFPR";
  let RenderMethod = "addRegOperands";
}

def FPR32INX : RegisterOperand<GPRF32> {
  let ParserMatchClass = GPRAsFPR;
  let DecoderMethod = "DecodeGPRRegisterClass";
}

// these definitions can be simplified to remove Suffix and Space, which are always
// empty string. However I found it too hard to remove these for now, so left them
// be for the time being. We can clean these up later.

// inx = 0 : f, d, zfh, zfhmin
class ExtInfoINX<bits<2> inx, list<Predicate> pres> {
  string Suffix = !cond(!eq(inx, 0): "INX");
  list<Predicate> Predicates = pres;
  string Space = !cond(!eq(inx, 0): "INX");
}

class ExtInfoINX_r<ExtInfoINX ext, DAGOperand reg> {
  string Suffix = ext.Suffix;
  list<Predicate> Predicates = ext.Predicates;
  string Space = ext.Space;
  DAGOperand Reg = reg;
}

class ExtInfoINX_rr<ExtInfoINX ext, DAGOperand rdty, DAGOperand rs1ty> {
  string Suffix = ext.Suffix;
  list<Predicate> Predicates = ext.Predicates;
  string Space = ext.Space;
  DAGOperand RdTy = rdty;
  DAGOperand Rs1Ty = rs1ty;
}

def FINXExt       : ExtInfoINX<0, [HasStdExtZfinx]>;
def F64INXExt     : ExtInfoINX<0, [HasStdExtZfinx, IsRV64]>;

def FINX      : ExtInfoINX_r<FINXExt,     FPR32INX>;

def FFINX        : ExtInfoINX_rr<FINXExt,       FPR32INX,    FPR32INX>;
def FXINX        : ExtInfoINX_rr<FINXExt,       FPR32INX,    GPR>;
def FX_64INX     : ExtInfoINX_rr<F64INXExt,     FPR32INX,    GPR>;
def XFINX        : ExtInfoINX_rr<FINXExt,       GPR,      FPR32INX>;
def XF_64INX     : ExtInfoINX_rr<F64INXExt,     GPR,      FPR32INX>;

// Floating-point rounding mode

/*
def FRMArg : AsmOperandClass {
  let Name = "FRMArg";
  let RenderMethod = "addFRMArgOperands";
  let DiagnosticType = "InvalidFRMArg";
}

def frmarg : Operand<XLenVT> {
  let ParserMatchClass = FRMArg;
  let PrintMethod = "printFRMArg";
  let DecoderMethod = "decodeFRMArg";
}
*/

//===----------------------------------------------------------------------===//
// Instruction class templates
//===----------------------------------------------------------------------===//

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
class FPLoadINX_r<bits<3> funct3, string opcodestr, RegisterClass rty,
               SchedWrite sw>
    : RVInstI<funct3, OPC_LOAD_FP, (outs rty:$rd),
              (ins GPR:$rs1, simm12:$imm12),
              opcodestr, "$rd, ${imm12}(${rs1})">,
      Sched<[sw, ReadFMemBase]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
class FPStoreINX_r<bits<3> funct3, string opcodestr, RegisterClass rty,
                SchedWrite sw>
    : RVInstS<funct3, OPC_STORE_FP, (outs),
              (ins rty:$rs2, GPR:$rs1, simm12:$imm12),
              opcodestr, "$rs2, ${imm12}(${rs1})">,
      Sched<[sw, ReadStoreData, ReadFMemBase]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, mayRaiseFPException = 1 in
class FPALU_rr<bits<7> funct7, bits<3> funct3, string opcodestr,
               DAGOperand rty>
    : RVInstR<funct7, funct3, OPC_OP_FP, (outs rty:$rd),
              (ins rty:$rs1, rty:$rs2), opcodestr, "$rd, $rs1, $rs2">;
multiclass FPALU_rr_m<bits<7> funct7, bits<3> funct3, string opcodestr,
                      list<ExtInfo_r> Exts> {
  foreach Ext = Exts in
    let Predicates = Ext.Predicates, DecoderNamespace = Ext.Space in
    def Ext.Suffix : FPALU_rr<funct7, funct3, opcodestr, Ext.Reg>;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, mayRaiseFPException = 1,
    UseNamedOperandTable = 1, hasPostISelHook = 1 in
class FPALU_rr_frm<bits<7> funct7, string opcodestr, DAGOperand rty>
    : RVInstRFrm<funct7, OPC_OP_FP, (outs rty:$rd),
                 (ins rty:$rs1, rty:$rs2, frmarg:$frm), opcodestr,
                  "$rd, $rs1, $rs2, $frm">;

multiclass FPALU_rr_frm_m<bits<7> funct7, string opcodestr,
                          list<ExtInfo_r> Exts> {
  foreach Ext = Exts in
    let Predicates = Ext.Predicates, DecoderNamespace = Ext.Space in
    def Ext.Suffix : FPALU_rr_frm<funct7, opcodestr, Ext.Reg>;
}

class FPALUDynFrmAlias<FPALU_rr_frm Inst, string OpcodeStr,
                       DAGOperand rty>
    : InstAlias<OpcodeStr#" $rd, $rs1, $rs2",
                (Inst rty:$rd, rty:$rs1, rty:$rs2, 0b111)>;
multiclass FPALUDynFrmAlias_m<FPALU_rr_frm Inst, string OpcodeStr,
                              list<ExtInfo_r> Exts> {
  foreach Ext = Exts in
    let Predicates = Ext.Predicates in
    def : FPALUDynFrmAlias<!cast<FPALU_rr_frm>(Inst#Ext.Suffix), OpcodeStr,
                           Ext.Reg>;
}

//===----------------------------------------------------------------------===//
// Instructions
//===----------------------------------------------------------------------===//

let Predicates = [HasStdExtFinx] in {
def LWINX : FPLoadINX_r<0b010, "lw", FPR32INX, WriteFLD32>;

// Operands for stores are in the order srcreg, base, offset rather than
// reflecting the order these fields are specified in the instruction
// encoding.
def SWINX : FPStoreINX_r<0b010, "sw", FPR32INX, WriteFST32>;
} // Predicates = [HasStdExtFinx]

let SchedRW = [WriteFALU32, ReadFALU32, ReadFALU32] in {
def FINXADD_S : FPALU_rr_frm<0b0000000, "fadd.s", FPR32INX>;
def FINXSUB_S : FPALU_rr_frm<0b0000100, "fsub.s", FPR32INX>;
}
let SchedRW = [WriteFMul32, ReadFMul32, ReadFMul32] in
def FINXMUL_S : FPALU_rr_frm<0b0001000, "fmul.s", FPR32INX>;

let SchedRW = [WriteFDiv32, ReadFDiv32, ReadFDiv32] in
def FINXDIV_S : FPALU_rr_frm<0b0001100, "fdiv.s", FPR32INX>;

def : FPINXALUDynFrmAlias<FADD_S, "fadd.s", FPR32INX>;
def : FPINXALUDynFrmAlias<FSUB_S, "fsub.s", FPR32INX>;
def : FPAINXLUDynFrmAlias<FMUL_S, "fmul.s", FPR32INX>;
def : FPAINXLUDynFrmAlias<FDIV_S, "fdiv.s", FPR32INX>;

//===----------------------------------------------------------------------===//
// Assembler Pseudo Instructions (User-Level ISA, Version 2.2, Chapter 20)
//===----------------------------------------------------------------------===//

let Predicates = [HasStdExtFinx] in {
def : InstAlias<"lw $rd, (${rs1})",  (LWINX FPR32INX:$rd,  GPR:$rs1, 0), 0>;
def : InstAlias<"sw $rs2, (${rs1})", (SWINX FPR32INX:$rs2, GPR:$rs1, 0), 0>;

def : InstAlias<"fneg.s $rd, $rs", (FSGNJNINX_S FPR32INX:$rd, FPR32INX:$rs, FPR32INX:$rs)>;

} // Predicates = [HasStdExtFinx]

//===----------------------------------------------------------------------===//
// Pseudo-instructions and codegen patterns
//===----------------------------------------------------------------------===//

/// Floating point constants
def fpimm0    : PatLeaf<(fpimm), [{ return N->isExactlyValue(+0.0); }]>;
def fpimmneg0 : PatLeaf<(fpimm), [{ return N->isExactlyValue(-0.0); }]>;

/// Generic pattern classes
class PatSetCC<RegisterClass Ty, SDPatternOperator OpNode, CondCode Cond, RVInst Inst>
    : Pat<(OpNode Ty:$rs1, Ty:$rs2, Cond), (Inst $rs1, $rs2)>;

class PatFprFpr<SDPatternOperator OpNode, RVInstR Inst,
                RegisterClass RegTy>
    : Pat<(OpNode RegTy:$rs1, RegTy:$rs2), (Inst $rs1, $rs2)>;

class PatFprFprDynFrm<SDPatternOperator OpNode, RVInstRFrm Inst,
                      RegisterClass RegTy>
    : Pat<(OpNode RegTy:$rs1, RegTy:$rs2), (Inst $rs1, $rs2, 0b111)>;

let Predicates = [HasStdExtF] in {

/// Float constants
def : Pat<(f32 (fpimm0)), (FMV_W_X X0)>;
def : Pat<(f32 (fpimmneg0)), (FSGNJN_S (FMV_W_X X0), (FMV_W_X X0))>;

/// Float arithmetic operations

def : PatFprFprDynFrm<any_fadd, FADD_S, FPR32>;
def : PatFprFprDynFrm<any_fsub, FSUB_S, FPR32>;
def : PatFprFprDynFrm<any_fmul, FMUL_S, FPR32>;
def : PatFprFprDynFrm<any_fdiv, FDIV_S, FPR32>;

/// Loads

defm : LdPat<load, LWINX, f32>;

/// Stores

defm : StPat<store, SWINX, FPR32INX, f32>;

} // Predicates = [HasStdExtF]
