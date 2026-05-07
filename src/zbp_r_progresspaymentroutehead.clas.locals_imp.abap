CLASS lhc_ProgPayHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS company_hml TYPE bukrs VALUE '1000'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ProgPayHeader RESULT result.

    METHODS createPurchaseOrder FOR MODIFY
      IMPORTING keys FOR ACTION ProgPayHeader~createPurchaseOrder RESULT result.

    METHODS updateActualDays FOR MODIFY
      IMPORTING keys FOR ACTION ProgPayHeader~updateActualDays RESULT result.

ENDCLASS.


CLASS lhc_ProgPayHeader IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD createPurchaseOrder.
    " TODO: variable is assigned but only used in commented-out code (ABAP cleaner)
    DATA transportation_documents TYPE zcl_mm_progpay_utilities=>tt_transportation_document.
    DATA header                   TYPE TABLE FOR CREATE I_PurchaseOrderTP_2.
    DATA notes                    TYPE TABLE FOR CREATE I_PurchaseOrderTP_2\_PurchaseOrderNote.
    DATA items                    TYPE TABLE FOR CREATE I_PurchaseOrderTP_2\_PurchaseOrderItem.
    DATA account_assignments      TYPE TABLE FOR CREATE I_PurchaseOrderItemTP_2\_PurOrdAccountAssignment.

    DATA(progress_pay_route) = keys[ 1 ]-%param.
    DATA(progress_pay_route_key) = keys[ 1 ]-%key.

    IF progress_pay_route-PurchaseOrder IS NOT INITIAL.
      reported-progpayheader = VALUE #( ( %key = progress_pay_route_key
                                          %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
                                                              number   = '006'
                                                              severity = if_abap_behv_message=>severity-error
                                                              v1       = progress_pay_route_key-Supplier
                                                              v2       = progress_pay_route_key-Product ) ) ).
      RETURN.
    ENDIF.

    SELECT SINGLE FROM I_PurchasingOrganization
      FIELDS CompanyCode
      WHERE PurchasingOrganization = @progress_pay_route_key-PurchasingOrganization
      INTO @DATA(company_code).

    IF company_code <> company_hml.
      DATA(where_wbs_company_code) = |proj~Project LIKE '%_{ company_code }'|.
    ENDIF.

    SELECT SINGLE
      FROM I_EnterpriseProject      AS proj
           INNER JOIN I_ProductText AS text ON  ltrim( text~Product, '0' ) = left( proj~Project, 8 )
                                            AND text~ProductName           = proj~ProjectDescription
      FIELDS text~Product,
             proj~Project,
             text~ProductName,
             concat_with_space( text~\_Product\_YY1_operationRegion_PRD-BusinessPartnerName1, text~\_Product\_YY1_operationRegion_PRD-BusinessPartnerName2, 1 ) AS YY1_operationRegion_PRD
      WHERE text~Product = @progress_pay_route_key-Product
      AND   proj~CompanyCode = @company_code
      AND   (where_wbs_company_code)
      INTO @DATA(products_wbs_element).
    IF sy-subrc <> 0.
      reported-progpayheader = VALUE #( ( %key = progress_pay_route_key
                                          %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
                                                              number   = 001
                                                              severity = if_abap_behv_message=>severity-error
                                                              v1       = progress_pay_route_key-Product ) ) ).
      RETURN.
    ENDIF.

*    zcl_mm_prog_pay_helper=>get_gl_account( EXPORTING
*                                              company_code = company_code
*                                              product      = progress_pay_route_key-Product
*                                            IMPORTING
*                                              gl_account   = DATA(gl_account)
*                                              message      = DATA(gl_account_error) ).
    zcl_mm_prog_pay_helper=>get_gl_acc_vehicle_category(
      EXPORTING
        purchasing_organization = progress_pay_route_key-PurchasingOrganization
        product                 = progress_pay_route_key-Product
      IMPORTING
        gl_account              = DATA(gl_account)
        message                 = DATA(gl_account_error) ).
    IF gl_account_error IS NOT INITIAL.
      reported-progpayheader = VALUE #( ( %key = progress_pay_route_key
                                          %msg = new_message( id       = gl_account_error-id
                                                              number   = gl_account_error-number
                                                              severity = CONV #( gl_account_error-type )
                                                              v1       = gl_account_error-message_v1
                                                              v2       = gl_account_error-message_v2
                                                              v3       = gl_account_error-message_v3
                                                              v4       = gl_account_error-message_v4 ) ) ).
      RETURN.
    ENDIF.

    DATA(date_where) = |TransportationStartdate LIKE '{ progress_pay_route_key-CalendarYear }{ progress_pay_route_key-CalendarMonth }%'|.
*    SELECT FROM zr_mm_prog_pay
    SELECT FROM ZR_ProgressPayment
      FIELDS transportdocno
      WHERE Product = @progress_pay_route_key-Product
      AND   Supplier = @progress_pay_route_key-Supplier
      AND   Customer = @progress_pay_route_key-Customer
      AND   PurchasingOrganization = @progress_pay_route_key-PurchasingOrganization
      AND   (date_where)
      INTO TABLE @DATA(progress_payments_ids).

    transportation_documents = CORRESPONDING #( progress_payments_ids MAPPING transportation_document = Transportdocno ).

*    zcl_mm_progpay_utilities=>check_reconciliation_status(
*      CHANGING transportation_documents = transportation_documents ).
*
*    LOOP AT transportation_documents INTO DATA(transportation_document).
*      reported-progpayheader = VALUE #(
*          ( %key = progress_pay_route_key
*            %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
*                                number   = 012
*                                severity = if_abap_behv_message=>severity-error
*                                v1       = transportation_document-transportation_document ) ) ).
*    ENDLOOP.
*    IF sy-subrc = 0.
*      RETURN.
*    ENDIF.

    TRY.
        DATA(header_cid) = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        DATA(items_cid) = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        DATA(account_assignments_cid) = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        DATA(payment_uuid) = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        DATA(note_uuid) = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        DATA(note_transport_uuid) = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    header = VALUE #( ( %cid                        = header_cid
                        PurchaseOrderType           = 'NB'
*                        CompanyCode                 = '1000'
                        CompanyCode                 = company_code
*                        PurchasingOrganization      = '1010'
                        PurchasingOrganization      = progress_pay_route_key-PurchasingOrganization
*                        PurchasingGroup             = '003'
                        PurchasingGroup             = '002'
                        Supplier                    = progress_pay_route_key-Supplier
                        YY1_PaymentUUID_PDH         = payment_uuid
                        YY1_TotalBonusAmount_PDH    = progress_pay_route-BonusAmount
                        YY1_TotalBonusAmount_PDHC   = progress_pay_route-Currency
                        YY1_TotalDeductionAmnt_PDH  = progress_pay_route-TotalDeductionAmount
                        YY1_TotalDeductionAmnt_PDHC = progress_pay_route-Currency
                        YY1_TotalDistance_PDH       = progress_pay_route-ActualKM
                        YY1_TotalShipmentCount_PDH  = progress_pay_route-ActualTripCount
                        %control                    = VALUE #(
                            PurchaseOrderType           = cl_abap_behv=>flag_changed
                            CompanyCode                 = cl_abap_behv=>flag_changed
                            PurchasingOrganization      = cl_abap_behv=>flag_changed
                            PurchasingGroup             = cl_abap_behv=>flag_changed
                            Supplier                    = cl_abap_behv=>flag_changed
                            YY1_PaymentUUID_PDH         = cl_abap_behv=>flag_changed
                            YY1_TotalBonusAmount_PDH    = cl_abap_behv=>flag_changed
                            YY1_TotalBonusAmount_PDHC   = cl_abap_behv=>flag_changed
                            YY1_TotalDeductionAmnt_PDH  = cl_abap_behv=>flag_changed
                            YY1_TotalDeductionAmnt_PDHC = cl_abap_behv=>flag_changed
                            YY1_TotalDistance_PDH       = cl_abap_behv=>flag_changed
                            YY1_TotalShipmentCount_PDH  = cl_abap_behv=>flag_changed ) ) ).

    DATA(long_text) = |Operasyon Bölgesi: { products_wbs_element-yy1_operationregion_prd } { cl_abap_char_utilities=>newline }| &&
                      |Hak Ediş Tutarı: { progress_pay_route-VestingAmount } TRY { cl_abap_char_utilities=>newline }| &&
                      |Toplam Kesinti Tutarı: { progress_pay_route-TotalDeductionAmount } TRY { cl_abap_char_utilities=>newline }| &&
                      |Toplam Prim Tutarı: { progress_pay_route-BonusAmount } TRY { cl_abap_char_utilities=>newline }| &&
                      |Yakıt Bakiyesi: { progress_pay_route-FuelVestingAmount } TRY { cl_abap_char_utilities=>newline }|.
*                      |Araç Sabit Kesinti: { progress_pay_route-VehicleDeductionAmount }|.

    DATA(long_text_transport_doc) = |Hak Ediş Seferleri: { cl_abap_char_utilities=>newline }|.

    LOOP AT progress_payments_ids ASSIGNING FIELD-SYMBOL(<progress_payments_id>).
      long_text_transport_doc = |{ long_text_transport_doc }{ <progress_payments_id>-Transportdocno }{ cl_abap_char_utilities=>newline }|. "#EC CI_NOORDER
    ENDLOOP.

    notes = VALUE #( ( %cid_ref = header_cid
                       %target  = VALUE #( Language = 'T'
                                           %control = VALUE #( TextObjectType = cl_abap_behv=>flag_changed
                                                               Language       = cl_abap_behv=>flag_changed
                                                               PlainLongText  = cl_abap_behv=>flag_changed )
                                           ( %cid           = note_uuid
                                             TextObjectType = 'F01'
                                             PlainLongText  = long_text )
                                           ( %cid           = note_transport_uuid
                                             TextObjectType = 'F02'
                                             PlainLongText  = long_text_transport_doc ) ) ) ).

    items = VALUE #(
        ( %cid_ref = header_cid
          %target  = VALUE #( ( %cid                      = items_cid
                                PurchaseOrderItem         = '00010'
*                                Plant                     = '1000'
                                Plant                     = CONV #( company_code )
                                Material                  = progress_pay_route_key-Product
                                PurchaseOrderItemText     = |{ products_wbs_element-ProductName } - Nakliye Bedeli|
                                OrderQuantity             = 1
                                NetPriceAmount            = progress_pay_route-TotalVestingAmount
                                AccountAssignmentCategory = 'P'
                                DocumentCurrency          = progress_pay_route-Currency
                                GoodsReceiptIsExpected    = abap_false
                                TaxCode                   = space
                                %control                  = VALUE #(
                                    PurchaseOrderItem         = cl_abap_behv=>flag_changed
                                    Plant                     = cl_abap_behv=>flag_changed
                                    Material                  = cl_abap_behv=>flag_changed
                                    PurchaseOrderItemText     = cl_abap_behv=>flag_changed
                                    OrderQuantity             = cl_abap_behv=>flag_changed
                                    NetPriceAmount            = cl_abap_behv=>flag_changed
                                    AccountAssignmentCategory = cl_abap_behv=>flag_changed
                                    DocumentCurrency          = cl_abap_behv=>flag_changed
                                    GoodsReceiptIsExpected    = cl_abap_behv=>flag_changed
                                    TaxCode                   = cl_abap_behv=>flag_changed ) ) ) ) ).

    account_assignments = VALUE #(
        ( %cid_ref          = items_cid
          PurchaseOrderItem = '00010'
          %target           = VALUE #( ( %cid                    = account_assignments_cid
                                         PurchaseOrderItem       = '00010'
                                         AccountAssignmentNumber = '01'
*                                         GLAccount               = '7400501001'
                                         GLAccount               = gl_account
                                         WBSElementExternalID    = products_wbs_element-Project
                                         %control                = VALUE #(
                                             PurchaseOrderItem       = cl_abap_behv=>flag_changed
                                             AccountAssignmentNumber = cl_abap_behv=>flag_changed
                                             GLAccount               = cl_abap_behv=>flag_changed
                                             WBSElementExternalID    = cl_abap_behv=>flag_changed ) ) ) ) ).

    IF progress_pay_route-FuelVestingAmount > 0.
      TRY.
          items_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        CATCH cx_uuid_error.
          RETURN.
      ENDTRY.

      items[ 1 ]-%target = VALUE #(
          BASE items[ 1 ]-%target
          ( %cid                      = items_cid
            PurchaseOrderItem         = '00020'
*            Plant                     = '1000'
            Plant                     = CONV #( company_code )
            Material                  = progress_pay_route_key-Product
            PurchaseOrderItemText     = 'Mazot Yansıtma Bedeli'
            OrderQuantity             = 1
            NetPriceAmount            = progress_pay_route-FuelVestingAmount
            AccountAssignmentCategory = 'P'
            DocumentCurrency          = progress_pay_route-Currency
            GoodsReceiptIsExpected    = abap_false
            TaxCode                   = space
            %control                  = VALUE #( PurchaseOrderItem         = cl_abap_behv=>flag_changed
                                                 Plant                     = cl_abap_behv=>flag_changed
                                                 Material                  = cl_abap_behv=>flag_changed
                                                 PurchaseOrderItemText     = cl_abap_behv=>flag_changed
                                                 OrderQuantity             = cl_abap_behv=>flag_changed
                                                 NetPriceAmount            = cl_abap_behv=>flag_changed
                                                 AccountAssignmentCategory = cl_abap_behv=>flag_changed
                                                 DocumentCurrency          = cl_abap_behv=>flag_changed
                                                 GoodsReceiptIsExpected    = cl_abap_behv=>flag_changed
                                                 TaxCode                   = cl_abap_behv=>flag_changed ) ) ).

      TRY.
          account_assignments_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        CATCH cx_uuid_error.
          RETURN.
      ENDTRY.

      account_assignments = VALUE #( BASE account_assignments
                                     ( %cid_ref          = items_cid
                                       PurchaseOrderItem = '00020'
                                       %target           = VALUE #(
                                           ( %cid                    = account_assignments_cid
                                             PurchaseOrderItem       = '00020'
                                             AccountAssignmentNumber = '01'
*                                             GLAccount               = '7400501001'
                                             GLAccount               = gl_account
                                             WBSElementExternalID    = products_wbs_element-Project
                                             %control                = VALUE #(
                                                 PurchaseOrderItem       = cl_abap_behv=>flag_changed
                                                 AccountAssignmentNumber = cl_abap_behv=>flag_changed
                                                 GLAccount               = cl_abap_behv=>flag_changed
                                                 WBSElementExternalID    = cl_abap_behv=>flag_changed ) ) ) ) ).
    ENDIF.

    MODIFY ENTITIES OF I_PurchaseOrderTP_2 FORWARDING PRIVILEGED
           ENTITY PurchaseOrder
           CREATE FIELDS ( PurchaseOrderType
                           CompanyCode
                           PurchasingOrganization
                           PurchasingGroup
                           Supplier
                           YY1_PaymentUUID_PDH
                           YY1_TotalBonusAmount_PDH
                           YY1_TotalBonusAmount_PDHC
                           YY1_TotalDeductionAmnt_PDH
                           YY1_TotalDeductionAmnt_PDHC
                           YY1_TotalDistance_PDH
                           YY1_TotalShipmentCount_PDH ) WITH header
           CREATE BY \_PurchaseOrderNote
           FIELDS ( TextObjectType
                    Language
                    PlainLongText ) WITH notes
           CREATE BY \_PurchaseOrderItem
           FIELDS ( PurchaseOrderItem
                    Plant
                    Material
                    PurchaseOrderItemText
                    OrderQuantity
                    NetPriceAmount
                    AccountAssignmentCategory
                    DocumentCurrency
                    GoodsReceiptIsExpected
                    TaxCode ) WITH items
           ENTITY PurchaseOrderItem
           CREATE BY \_PurOrdAccountAssignment
           FIELDS ( PurchaseOrderItem
                    AccountAssignmentNumber
                    GLAccount
                    WBSElementExternalID ) WITH account_assignments
    " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED DATA(reported_create)
           FAILED   DATA(failed_create)
           " TODO: variable is assigned but never used (ABAP cleaner)
           MAPPED   DATA(mapped_create).
    IF failed_create IS INITIAL.
*      DATA(date_where) = |TransportationStartdate LIKE '{ progress_pay_route_key-CalendarYear }{ progress_pay_route_key-CalendarMonth }%'|.
*      SELECT FROM zr_mm_prog_pay
*        FIELDS transportdocno
*        WHERE Product = @progress_pay_route_key-Product
*        AND   Supplier = @progress_pay_route_key-Supplier
*        AND   Customer = @progress_pay_route_key-Customer
*        AND   (date_where)
*        INTO TABLE @DATA(progress_payments_ids).
*      IF sy-subrc = 0.
      IF progress_payments_ids IS NOT INITIAL.
        MODIFY ENTITIES OF zr_mm_prg_pay_log
               ENTITY PaymentLog
               CREATE AUTO FILL CID FIELDS ( Transportdocno
                                             PaymentUuid )
               WITH VALUE #( FOR progress_payments_id IN progress_payments_ids
                             ( %data-%key = VALUE #( Transportdocno = progress_payments_id-Transportdocno
                                                     PaymentUuid    = payment_uuid )
                               %control   = VALUE #( Transportdocno = cl_abap_behv=>flag_changed
                                                     PaymentUuid    = cl_abap_behv=>flag_changed ) ) )
                                                                         " TODO: variable is assigned but never used (ABAP cleaner)
               REPORTED DATA(reported_log)
               " TODO: variable is assigned but never used (ABAP cleaner)
               FAILED DATA(failed_log)
               " TODO: variable is assigned but never used (ABAP cleaner)
               MAPPED DATA(mapped_log).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD updateActualDays.
  ENDMETHOD.
ENDCLASS.


CLASS lsc_ZR_PROGRESSPAYMENTROUTEHEA DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.


CLASS lsc_ZR_PROGRESSPAYMENTROUTEHEA IMPLEMENTATION.
  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
