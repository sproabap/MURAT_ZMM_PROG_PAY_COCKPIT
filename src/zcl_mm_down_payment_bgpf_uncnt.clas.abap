CLASS zcl_mm_down_payment_bgpf_uncnt DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_bgmc_op_single_tx_uncontr.

    METHODS constructor
      IMPORTING journal_entry TYPE zcl_mm_down_payment_bgpf=>ty_je_deep.

  PRIVATE SECTION.
    DATA je_deep TYPE zcl_mm_down_payment_bgpf=>ty_je_deep.
ENDCLASS.



CLASS ZCL_MM_DOWN_PAYMENT_BGPF_UNCNT IMPLEMENTATION.


  METHOD constructor.
    je_deep = journal_entry.
  ENDMETHOD.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
    DATA(lo_wbs) = NEW zcl_mm_down_payment_bgpf( ).

    lo_wbs->add( je_deep ).

    lo_wbs->process( ).
  ENDMETHOD.
ENDCLASS.
