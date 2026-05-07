CLASS zcl_mm_progpay_route_header DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

    DATA lt_post   TYPE zmm_tt_imp_fuelvesting_calc.
    DATA lt_result TYPE zmm_tt_exp_fuelvesting_calc.
ENDCLASS.



CLASS ZCL_MM_PROGPAY_ROUTE_HEADER IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data       TYPE STANDARD TABLE OF ZC_ProgressPaymentRouteHeader WITH DEFAULT KEY.
    DATA items                  TYPE STANDARD TABLE OF ZC_ProgressPaymentRouteItem WITH DEFAULT KEY.
    DATA fuel_progress_products TYPE zmm_tt_imp_fuelvesting_calc.

    lt_original_data = CORRESPONDING #( it_original_data ).

    SELECT
      FROM ZC_ProgressPaymentRouteItem AS item
           INNER JOIN
           @lt_original_data           AS header ON  header~CalendarYear           = item~CalendarYear
                                                 AND header~CalendarMonth          = item~CalendarMonth
                                                 AND header~Supplier               = item~Supplier
                                                 AND header~Product                = item~Product
                                                 AND header~Customer               = item~Customer
                                                 AND header~PurchasingOrganization = item~PurchasingOrganization
      FIELDS item~*
      INTO CORRESPONDING FIELDS OF TABLE @items.

    TRY.
        NEW zcl_mm_progpay_route_item( )->if_sadl_exit_calc_element_read~calculate(
              EXPORTING
                it_original_data           = items
                it_requested_calc_elements = VALUE #( ( ) )
              CHANGING
                ct_calculated_data         = items ).
      CATCH cx_sadl_exit ##NO_HANDLER.
    ENDTRY.

*    SELECT
*      FROM zr_mm_fuelvesting AS fuel
*           INNER JOIN
*           @lt_original_data AS kokpit ON  kokpit~CalendarYear  = fuel~Calendaryear
*                                       AND kokpit~CalendarMonth = fuel~Calendarmonth
*                                       AND kokpit~Product       = fuel~Product
*      FIELDS DISTINCT fuel~Calendaryear,
*                      fuel~Calendarmonth,
*                      fuel~Product,
*                      fuel~VestingFuelAmount,
*                      fuel~Currency
*      ORDER BY fuel~Calendaryear,
*               fuel~Calendarmonth,
*               fuel~Product
*      INTO TABLE @DATA(fuel_vestings).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      LOOP AT items INTO DATA(item) WHERE     CalendarYear           = <fs_original_data>-CalendarYear
                                          AND CalendarMonth          = <fs_original_data>-CalendarMonth
                                          AND Supplier               = <fs_original_data>-Supplier
                                          AND Product                = <fs_original_data>-Product
                                          AND Customer               = <fs_original_data>-Customer
                                          AND PurchasingOrganization = <fs_original_data>-PurchasingOrganization.
        <fs_original_data>-ActualTripCount        += item-ActualTripCount.
        <fs_original_data>-ActualKM               += item-ActualKM.
        <fs_original_data>-BonusAmount            += item-BonusAmount.
*        <fs_original_data>-FuelVestingAmount      += item-FuelVestingAmount.
        <fs_original_data>-TotalDeductionAmount   += item-TotalDeductionAmount.
        <fs_original_data>-TotalVestingAmount     += item-TotalVestingAmount.
        <fs_original_data>-VehicleDeductionAmount += item-VehicleDeductionAmount.
        <fs_original_data>-VestingAmount          += item-VestingAmount.
      ENDLOOP.

*      <fs_original_data>-FuelVestingAmount = VALUE #( fuel_vestings[
*                                                          CalendarYear  = <fs_original_data>-CalendarYear
*                                                          CalendarMonth = <fs_original_data>-CalendarMonth
*                                                          Product       = <fs_original_data>-Product ]-VestingFuelAmount OPTIONAL ).

*      IF <fs_original_data>-fuelvestingamount < 0.
*        <fs_original_data>-TotalVestingAmount += <fs_original_data>-FuelVestingAmount.
*      ENDIF.
    ENDLOOP.

    fuel_progress_products = VALUE #( FOR ls_original_data IN lt_original_data
                                      ( matnr         = ls_original_data-Product
                                        calendaryear  = ls_original_data-CalendarYear
                                        calendarmonth = ls_original_data-CalendarMonth
                                        total_km      = ls_original_data-ActualKM ) ).

    NEW zcl_mm_fuelvesting_calculation( )->calculate_fuel_vesting( EXPORTING
                                                                     it_data = fuel_progress_products
                                                                   IMPORTING
                                                                     et_data = DATA(fuel_progress_amounts) ).

    LOOP AT lt_original_data ASSIGNING <fs_original_data>.
      <fs_original_data>-FuelVestingAmount = VALUE #( fuel_progress_amounts[
                                                          Matnr         = <fs_original_data>-Product
                                                          CalendarYear  = <fs_original_data>-CalendarYear
                                                          CalendarMonth = <fs_original_data>-CalendarMonth ]-diff_amount OPTIONAL ).
    ENDLOOP.

    LOOP AT lt_original_data ASSIGNING <fs_original_data>.
   READ TABLE lt_result INTO DATA(ls_Result) WITH KEY matnr = <fs_original_data>-Product
                                                      calendaryear = <fs_original_data>-CalendarYear
                                                      calendarmonth = <fs_original_data>-CalendarMonth.
    IF sy-subrc = 0.
      <fs_original_data>-total_fuel_taken_liters  = ls_result-total_fuel_taken_liters.
      <fs_original_data>-diff_liters = ls_result-diff_liters.
      <fs_original_data>-earned_liter = ls_result-earned_liter.
      <fs_original_data>-total_fuel_ent_ex_vat = ( <fs_original_data>-earned_liter *  ls_Result-avg_fuel_amt_vehicle ) * ( 80 / 100 ).
      <fs_original_data>-total_fuel_cost_exc_vat = ( <fs_original_data>-total_fuel_taken_liters * ls_Result-avg_fuel_amt_vehicle ) * ( 80 / 100 ).
    ENDIF.
   ENDLOOP.
    MOVE-CORRESPONDING lt_original_data TO ct_calculated_data.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
