CLASS zcl_mm_progresspayspot DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.



CLASS ZCL_MM_PROGRESSPAYSPOT IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF ZC_ProgressPaymentSpot WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
*      <fs_original_data>-AdditionalPromotion = 0.
*      <fs_original_data>-Deduction           = 0.
*      <fs_original_data>-TotalPrice          = <fs_original_data>-SpotPaymentPrice + <fs_original_data>-AdditionalPromotion - <fs_original_data>-Deduction.
      <fs_original_data>-PaymentMadeStatus = SWITCH #( <fs_original_data>-PaymentMade
                                                       WHEN abap_true
                                                       THEN 3
                                                       ELSE 2 ).
*      <fs_original_data>-POFilter          = COND #( WHEN <fs_original_data>-PurchaseOrder IS NOT INITIAL
*                                                     THEN abap_true
*                                                     ELSE abap_false ).
      <fs_original_data>-POStatus          = COND #( WHEN <fs_original_data>-POFilter = abap_true AND <fs_original_data>-PaymentMade = abap_true THEN
                                                       3
                                                     WHEN <fs_original_data>-POFilter = abap_true AND <fs_original_data>-PaymentMade = abap_false THEN
                                                       5
                                                     ELSE
                                                       0 ).
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
