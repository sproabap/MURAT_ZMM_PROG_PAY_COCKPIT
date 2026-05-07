CLASS zcl_mm_progpay_route_item DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.



CLASS ZCL_MM_PROGPAY_ROUTE_ITEM IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data         TYPE STANDARD TABLE OF ZC_ProgressPaymentRouteItem WITH DEFAULT KEY.
    DATA micro_lease_route_prices TYPE zcl_mm_calc_micltroute=>tt_kokpit.

    lt_original_data = CORRESPONDING #( it_original_data ).

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

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    micro_lease_route_prices = VALUE #( FOR ls_original_data IN lt_original_data
                                        WHERE ( vestingmodel = '03' )
                                        ( supplier               = ls_original_data-supplier
                                          product                = ls_original_data-product
                                          customer               = ls_original_data-customer
                                          month                  = ls_original_data-calendarmonth
                                          year                   = ls_original_data-calendaryear
                                          departure_province     = ls_original_data-DepartureProvince
                                          departure_district     = ls_original_data-DepartureDistrict
                                          departure_point        = ls_original_data-DeparturePoint
                                          arrival_province       = ls_original_data-ArrivalProvince
                                          arrival_district       = ls_original_data-ArrivalDistrict
                                          arrival_point          = ls_original_data-ArrivalPoint
                                          tempature_regime       = ls_original_data-HeatRegimeType
                                          actual_trip_count      = ls_original_data-ActualTripCount
                                          purchasingorganization = ls_original_data-PurchasingOrganization ) ).

    NEW zcl_mm_calc_micltroute( )->get_price( CHANGING ct_kokpit = micro_lease_route_prices ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      CASE <fs_original_data>-VestingModel.
        WHEN '03'.
          READ TABLE micro_lease_route_prices INTO DATA(micro_lease_route_price) WITH KEY supplier               = <fs_original_data>-Supplier
                                                                                          product                = <fs_original_data>-Product
                                                                                          customer               = <fs_original_data>-Customer
                                                                                          month                  = <fs_original_data>-CalendarMonth
                                                                                          year                   = <fs_original_data>-CalendarYear
                                                                                          departure_province     = <fs_original_data>-DepartureProvince
                                                                                          departure_district     = <fs_original_data>-DepartureDistrict
                                                                                          departure_point        = <fs_original_data>-DeparturePoint
                                                                                          arrival_province       = <fs_original_data>-ArrivalProvince
                                                                                          arrival_district       = <fs_original_data>-ArrivalDistrict
                                                                                          arrival_point          = <fs_original_data>-ArrivalPoint
                                                                                          tempature_regime       = <fs_original_data>-HeatRegimeType
                                                                                          purchasingorganization = <fs_original_data>-PurchasingOrganization.
          IF sy-subrc = 0.
            <fs_original_data>-VestingAmount = micro_lease_route_price-vesting_amount.
          ENDIF.
      ENDCASE.

*      READ TABLE material_deductions INTO DATA(material_deduction) WITH KEY material = <fs_original_data>-Product.
*      IF sy-subrc = 0.
*        <fs_original_data>-VehicleDeductionAmount = material_deduction-deductionamount.
*      ENDIF.

      <fs_original_data>-totalvestingamount = <fs_original_data>-vestingamount -
                                                      <fs_original_data>-totaldeductionamount +
                                                      <fs_original_data>-bonusamount.

*      IF <fs_original_data>-fuelvestingamount < 0.
*        <fs_original_data>-totalvestingamount += <fs_original_data>-fuelvestingamount.
*      ENDIF.

      IF <fs_original_data>-totalvestingamount < 0.
        <fs_original_data>-totalvestingamount = 0.
      ENDIF.
    ENDLOOP.

    MOVE-CORRESPONDING lt_original_data TO ct_calculated_data.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
