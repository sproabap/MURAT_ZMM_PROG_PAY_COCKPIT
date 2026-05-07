CLASS zcl_mm_progresspayrental DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.

    DATA lt_post   TYPE zmm_tt_imp_fuelvesting_calc.
    DATA lt_result TYPE zmm_tt_exp_fuelvesting_calc.

ENDCLASS.



CLASS ZCL_MM_PROGRESSPAYRENTAL IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data        TYPE STANDARD TABLE OF zc_progresspaymentrental WITH DEFAULT KEY.
    DATA macro_km_prices         TYPE zcl_mm_calc_macrokmbsd=>tt_kokpit.   " 01
    DATA micro_trip_prices       TYPE zcl_mm_calc_mictripbsd=>tt_kokpit.   " 02
    DATA micro_km_bonuses        TYPE zcl_mm_calc_miclkmbonus=>tt_mm_recn. " 04
    DATA micro_scale_bonuses     TYPE zcl_mm_calc_micltbonus=>tt_kokpit.   " 05
    DATA micro_km_trip_bonuses   TYPE zcl_mm_calc_miclatbns=>tt_kokpit.    " 06
    DATA micro_km_trip_bonus_kms TYPE zcl_mm_micladdtripkmbns=>tt_mm_recn. " 07
    DATA fuel_progress_products  TYPE zmm_tt_imp_fuelvesting_calc.

    lt_original_data = CORRESPONDING #( it_original_data ).

*    SELECT SINGLE
*     FROM ZI_MmDefaultCustomer
*     FIELDS Customer
*     INTO @DATA(default_customer).

*    SELECT
*      FROM zmm_vestdeduct    AS vestdeduct
*           INNER JOIN
*           @lt_original_data AS kokpit       ON kokpit~Product = vestdeduct~material
*           INNER JOIN
*           i_calendardate    AS calendardate ON calendardate~calendardate = concat( concat( kokpit~CalendarYear, kokpit~CalendarMonth ), '01' )
*      FIELDS DISTINCT vestdeduct~material,
*                      vestdeduct~deductionamount
*      WHERE calendardate~firstdayofmonthdate BETWEEN vestdeduct~validfrom AND vestdeduct~validto
*        AND calendardate~lastdayofmonthdate  BETWEEN vestdeduct~validfrom AND vestdeduct~validto
*      INTO TABLE @DATA(material_deductions).

    SELECT
      FROM zr_mm_prg_pay_days AS days
           INNER JOIN
           @lt_original_data  AS kokpit ON  kokpit~CalendarYear           = days~CalendarYear
                                        AND kokpit~CalendarMonth          = days~CalendarMonth
                                        AND kokpit~Supplier               = days~Supplier
                                        AND kokpit~Product                = days~Product
                                        AND kokpit~Customer               = days~Customer
                                        AND kokpit~PurchasingOrganization = days~PurchasingOrganization
      FIELDS days~CalendarYear,
             days~CalendarMonth,
             days~Supplier,
             days~Product,
             days~Customer,
             days~PurchasingOrganization,
             days~ActualDays
      ORDER BY days~CalendarYear,
               days~CalendarMonth,
               days~Supplier,
               days~Product,
               days~Customer,
               days~PurchasingOrganization,
               days~ActualDays
      INTO TABLE @DATA(actual_days_log).

    SELECT
      FROM ZR_ProgressPayment AS progpay
           INNER JOIN
           @lt_original_data  AS kokpit  ON  kokpit~CalendarYear           = progpay~CalendarYear
                                         AND kokpit~CalendarMonth          = progpay~CalendarMonth
                                         AND kokpit~Supplier               = progpay~Supplier
                                         AND kokpit~Product                = progpay~Product
*                                         AND kokpit~Customer      = progpay~Customer
                                         AND kokpit~PurchasingOrganization = progpay~PurchasingOrganization
      FIELDS progpay~CalendarYear,
             progpay~CalendarMonth,
             progpay~Supplier,
             progpay~Product,
             progpay~Customer,
*             @default_customer AS Customer,
             progpay~PurchasingOrganization,
             CAST( COUNT( DISTINCT progpay~TransportationStartDate ) AS INT4 ) AS ActualDays
      GROUP BY progpay~CalendarYear,
               progpay~CalendarMonth,
               progpay~Supplier,
               progpay~Product,
               progpay~Customer,
               progpay~PurchasingOrganization
      ORDER BY progpay~CalendarYear,
               progpay~CalendarMonth,
               progpay~Supplier,
               progpay~Product,
               progpay~Customer,
               progpay~PurchasingOrganization
      INTO TABLE @DATA(actual_days).

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
      TRY.
          <fs_original_data>-ActualDays = actual_days_log[
              CalendarYear           = <fs_original_data>-CalendarYear
              CalendarMonth          = <fs_original_data>-CalendarMonth
              Supplier               = <fs_original_data>-Supplier
              Product                = <fs_original_data>-Product
              Customer               = <fs_original_data>-Customer
              PurchasingOrganization = <fs_original_data>-PurchasingOrganization ]-ActualDays.
        CATCH cx_sy_itab_line_not_found.
          <fs_original_data>-ActualDays = VALUE #( actual_days[
                                                       CalendarYear           = <fs_original_data>-CalendarYear
                                                       CalendarMonth          = <fs_original_data>-CalendarMonth
                                                       Supplier               = <fs_original_data>-Supplier
                                                       Product                = <fs_original_data>-Product
                                                       Customer               = <fs_original_data>-Customer
                                                       PurchasingOrganization = <fs_original_data>-PurchasingOrganization ]-ActualDays OPTIONAL ).
      ENDTRY.

*      <fs_original_data>-FuelVestingAmount = VALUE #( fuel_vestings[
*                                                          CalendarYear  = <fs_original_data>-CalendarYear
*                                                          CalendarMonth = <fs_original_data>-CalendarMonth
*                                                          Product       = <fs_original_data>-Product ]-VestingFuelAmount OPTIONAL ).
    ENDLOOP.
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    macro_km_prices = VALUE #( FOR ls_original_data IN lt_original_data
                               WHERE ( vestingmodel = '01' )
                               ( supplier               = ls_original_data-supplier
                                 plate                  = ls_original_data-product
                                 customer               = ls_original_data-customer
                                 month                  = ls_original_data-calendarmonth
                                 year                   = ls_original_data-calendaryear
                                 targetdays             = ls_original_data-targetdays
                                 targetkm               = ls_original_data-targetkm
                                 targetprice            = ls_original_data-targetprice
                                 realiseddayscount      = ls_original_data-actualdays
                                 realisedkmcount        = ls_original_data-actualkm
                                 realisedtripcount      = ls_original_data-actualtripcount
                                 purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_calc_macrokmbsd( )->get_price( CHANGING ct_kokpit = macro_km_prices ).

    micro_trip_prices = VALUE #( FOR ls_original_data IN lt_original_data
                                 WHERE ( vestingmodel = '02' )
                                 ( supplier               = ls_original_data-supplier
                                   plate                  = ls_original_data-product
                                   customer               = ls_original_data-customer
                                   month                  = ls_original_data-calendarmonth
                                   year                   = ls_original_data-calendaryear
                                   realisedtripcount      = ls_original_data-actualtripcount
                                   purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_calc_mictripbsd( )->get_price( CHANGING ct_kokpit = micro_trip_prices ).

    micro_km_bonuses = VALUE #( FOR ls_original_data IN lt_original_data
                                WHERE ( vestingmodel = '04' )
                                ( supplier               = ls_original_data-supplier
                                  material               = ls_original_data-product
                                  customer               = ls_original_data-customer
                                  month                  = ls_original_data-calendarmonth
                                  year                   = ls_original_data-calendaryear
                                  actualdaysworked       = ls_original_data-actualdays
                                  actualkm               = ls_original_data-actualkm
                                  purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_calc_miclkmbonus( )->get_price( CHANGING cockpit_data = micro_km_bonuses ).

    micro_scale_bonuses = VALUE #( FOR ls_original_data IN lt_original_data
                                   WHERE ( vestingmodel = '05' )
                                   ( supplier               = ls_original_data-supplier
                                     plate                  = ls_original_data-product
                                     customer               = ls_original_data-customer
                                     month                  = ls_original_data-calendarmonth
                                     year                   = ls_original_data-calendaryear
                                     actual_days            = ls_original_data-actualdays
                                     actual_trips           = ls_original_data-actualtripcount
                                     purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_calc_micltbonus( )->get_price( CHANGING ct_kokpit = micro_scale_bonuses ).

    micro_km_trip_bonuses = VALUE #( FOR ls_original_data IN lt_original_data
                                     WHERE ( vestingmodel = '06' )
                                     ( supplier               = ls_original_data-supplier
                                       plate                  = ls_original_data-product
                                       customer               = ls_original_data-customer
                                       month                  = ls_original_data-calendarmonth
                                       year                   = ls_original_data-calendaryear
                                       actualdays             = ls_original_data-actualdays
                                       actualtripcount        = ls_original_data-actualtripcount
                                       purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_calc_miclatbns( )->get_price( CHANGING ct_kokpit = micro_km_trip_bonuses ).

    micro_km_trip_bonus_kms = VALUE #( FOR ls_original_data IN lt_original_data
                                       WHERE ( vestingmodel = '07' )
                                       ( supplier               = ls_original_data-supplier
                                         material               = ls_original_data-product
                                         customer               = ls_original_data-customer
                                         month                  = ls_original_data-calendarmonth
                                         year                   = ls_original_data-calendaryear
                                         actualdaysworked       = ls_original_data-actualdays
                                         actualtripcount        = ls_original_data-actualtripcount
                                         actualkm               = ls_original_data-actualkm
                                         purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_micladdtripkmbns( )->get_price( CHANGING cockpit_data = micro_km_trip_bonus_kms ).

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
      CASE <fs_original_data>-vestingmodel.
        WHEN '01'.
          READ TABLE macro_km_prices INTO DATA(macro_km_price) WITH KEY supplier               = <fs_original_data>-supplier
                                                                        plate                  = <fs_original_data>-product
                                                                        month                  = <fs_original_data>-calendarmonth
                                                                        year                   = <fs_original_data>-calendaryear
                                                                        realiseddayscount      = <fs_original_data>-actualdays
                                                                        realisedkmcount        = <fs_original_data>-actualkm
                                                                        realisedtripcount      = <fs_original_data>-actualtripcount
                                                                        purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-targetdays           = macro_km_price-targetdays.
            <fs_original_data>-targetkm             = macro_km_price-targetkm.
            <fs_original_data>-targetprice          = macro_km_price-targetprice.
            <fs_original_data>-vestingamount        = macro_km_price-vestingamount.
            <fs_original_data>-totaldeductionamount = macro_km_price-totaldeductionamount.
            <fs_original_data>-WageDeductionAmount  = macro_km_price-wagedeductionamount.
            <fs_original_data>-KMDeductionAmount    = macro_km_price-totalkmdeductionamount.
          ENDIF.
        WHEN '02'.
          READ TABLE micro_trip_prices INTO DATA(micro_trip_price) WITH KEY supplier               = <fs_original_data>-supplier
                                                                            plate                  = <fs_original_data>-product
                                                                            month                  = <fs_original_data>-calendarmonth
                                                                            year                   = <fs_original_data>-calendaryear
                                                                            realisedtripcount      = <fs_original_data>-actualtripcount
                                                                            purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-vestingamount = micro_trip_price-vestingamount.
          ENDIF.
        WHEN '04'.
          READ TABLE micro_km_bonuses INTO DATA(micro_km_bonus) WITH KEY supplier               = <fs_original_data>-supplier
                                                                         material               = <fs_original_data>-product
                                                                         month                  = <fs_original_data>-calendarmonth
                                                                         year                   = <fs_original_data>-calendaryear
                                                                         actualdaysworked       = <fs_original_data>-actualdays
                                                                         actualkm               = <fs_original_data>-actualkm
                                                                         purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-vestingamount        = micro_km_bonus-vestingamount.
            <fs_original_data>-totaldeductionamount = micro_km_bonus-totaldeductionamount.
            <fs_original_data>-TargetDays           = micro_km_bonus-targetdays.
            <fs_original_data>-TargetPrice          = micro_km_bonus-targetprice.
            <fs_original_data>-KMBonusAmount        = micro_km_bonus-kmbonusamount.
            <fs_original_data>-WageDeductionAmount  = micro_km_bonus-wagedeductionamount.
          ENDIF.
        WHEN '05'.
          READ TABLE micro_scale_bonuses INTO DATA(micro_scale_bonus) WITH KEY supplier               = <fs_original_data>-supplier
                                                                               plate                  = <fs_original_data>-product
                                                                               month                  = <fs_original_data>-calendarmonth
                                                                               year                   = <fs_original_data>-calendaryear
                                                                               actual_days            = <fs_original_data>-actualdays
                                                                               actual_trips           = <fs_original_data>-actualtripcount
                                                                               purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-vestingamount             = micro_scale_bonus-vesting_amount.
            <fs_original_data>-totaldeductionamount      = micro_scale_bonus-total_deduction_amount.
            <fs_original_data>-targetdays                = micro_scale_bonus-target_days.
            <fs_original_data>-targetprice               = micro_scale_bonus-target_amount.
            <fs_original_data>-AdditionalTripBonusAmount = micro_scale_bonus-additional_trip_bonus_amount.
            <fs_original_data>-WageDeductionAmount       = micro_scale_bonus-wage_deduction_amount.
            <fs_original_data>-ScaleDetails              = micro_scale_bonus-calculation_detail.
          ENDIF.
        WHEN '06'.
          READ TABLE micro_km_trip_bonuses INTO DATA(micro_km_trip_bonus) WITH KEY supplier               = <fs_original_data>-supplier
                                                                                   plate                  = <fs_original_data>-product
                                                                                   month                  = <fs_original_data>-calendarmonth
                                                                                   year                   = <fs_original_data>-calendaryear
                                                                                   actualdays             = <fs_original_data>-actualdays
                                                                                   actualtripcount        = <fs_original_data>-actualtripcount
                                                                                   purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-targetdays                = micro_km_trip_bonus-targetdays.
            <fs_original_data>-TargetTripCount           = micro_km_trip_bonus-targettripcount.
            <fs_original_data>-targetprice               = micro_km_trip_bonus-targetprice.
            <fs_original_data>-vestingamount             = micro_km_trip_bonus-vestingamount.
            <fs_original_data>-totaldeductionamount      = micro_km_trip_bonus-totaldeductionprice.
            <fs_original_data>-AdditionalTripBonusAmount = micro_km_trip_bonus-addtripprice.
            <fs_original_data>-WageDeductionAmount       = micro_km_trip_bonus-dailywagedeductamount.
          ENDIF.
        WHEN '07'.
          READ TABLE micro_km_trip_bonus_kms INTO DATA(micro_km_trip_bonus_km) WITH KEY supplier               = <fs_original_data>-supplier
                                                                                        material               = <fs_original_data>-product
                                                                                        month                  = <fs_original_data>-calendarmonth
                                                                                        year                   = <fs_original_data>-calendaryear
                                                                                        actualdaysworked       = <fs_original_data>-actualdays
                                                                                        actualkm               = <fs_original_data>-actualkm
                                                                                        actualtripcount        = <fs_original_data>-actualtripcount
                                                                                        purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-vestingamount             = micro_km_trip_bonus_km-vestingamount.
            <fs_original_data>-totaldeductionamount      = micro_km_trip_bonus_km-totaldeductionamount.
            <fs_original_data>-TargetDays                = micro_km_trip_bonus_km-targetdays.
            <fs_original_data>-TargetPrice               = micro_km_trip_bonus_km-targetprice.
            <fs_original_data>-TargetTripCount           = micro_km_trip_bonus_km-targettripcount.
            <fs_original_data>-AdditionalTripBonusAmount = micro_km_trip_bonus_km-addtripbonusamount.
            <fs_original_data>-KMBonusAmount             = micro_km_trip_bonus_km-kmbonusamount.
            <fs_original_data>-WageDeductionAmount       = micro_km_trip_bonus_km-wagedeductionamount.
          ENDIF.
      ENDCASE.

*      READ TABLE material_deductions INTO DATA(material_deduction) WITH KEY material = <fs_original_data>-Product.
*      IF sy-subrc = 0.
*        <fs_original_data>-VehicleDeductionAmount = material_deduction-deductionamount.
*      ENDIF.

      <fs_original_data>-FuelVestingAmount  = VALUE #( fuel_progress_amounts[
                                                           Matnr         = <fs_original_data>-Product
                                                           CalendarYear  = <fs_original_data>-CalendarYear
                                                           CalendarMonth = <fs_original_data>-CalendarMonth ]-diff_amount OPTIONAL ).

      <fs_original_data>-totalvestingamount = <fs_original_data>-vestingamount -
                                                      <fs_original_data>-totaldeductionamount +
                                                      <fs_original_data>-bonusamount.
*                                                      <fs_original_data>-vehicledeductionamount.

*      IF <fs_original_data>-fuelvestingamount < 0.
*        <fs_original_data>-totalvestingamount += <fs_original_data>-fuelvestingamount.
*      ENDIF.

      IF <fs_original_data>-totalvestingamount < 0.
        <fs_original_data>-totalvestingamount = 0.
      ENDIF.

      <fs_original_data>-POStatus = COND #( WHEN <fs_original_data>-POFilter = abap_true
                                            THEN 3
                                            ELSE 0 ).
    ENDLOOP.

     DATA(lo_calculation) = NEW zcl_mm_fuelvesting_calculation( ).

    FREE lt_post.
    lt_post = VALUE #( FOR ls_data IN lt_original_data
                       ( matnr         = ls_data-Product
                         calendaryear  = ls_data-CalendarYear
                         CalendarMonth = ls_data-CalendarMonth
                         total_km      = ls_data-ActualKM ) ).

    lo_calculation->calculate_fuel_vesting( EXPORTING
                                              it_data = lt_post
                                            IMPORTING
                                              et_data = lt_result ).

   LOOP AT lt_original_data ASSIGNING <fs_original_data>.
   READ TABLE lt_result INTO DATA(ls_Result) WITH KEY matnr = <fs_original_data>-Product
                                                      calendaryear = <fs_original_data>-CalendarYear
                                                      calendarmonth = <fs_original_data>-CalendarMonth.
    IF sy-subrc = 0.
      <fs_original_data>-total_fuel_taken_liters  = ls_result-total_fuel_taken_liters.
      <fs_original_data>-diff_liters = ls_result-diff_liters.
      <fs_original_data>-earned_liter = ls_result-earned_liter.
*      <fs_original_data>-total_fuel_ent_ex_vat = ( <fs_original_data>-earned_liter *  ls_Result-avg_fuel_amt_vehicle ) * ( 80 / 100 ).
*      <fs_original_data>-total_fuel_cost_exc_vat = ( <fs_original_data>-total_fuel_taken_liters * ls_Result-avg_fuel_amt_vehicle ) * ( 80 / 100 ).
    <fs_original_data>-total_fuel_ent_ex_vat = ls_Result-total_fuel_ent_ex_vat.
    <fs_original_data>-total_fuel_cost_exc_vat = ls_Result-total_fuel_cost_exc_vat.
    ENDIF.
   ENDLOOP.
    ct_calculated_data = CORRESPONDING #( lt_original_data ).


  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
