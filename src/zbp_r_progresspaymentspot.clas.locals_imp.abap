CLASS lhc_ProgPaySpot DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CLASS-DATA lt_je_deep       TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.
    CLASS-DATA transport_doc_no TYPE bstkd.

  PRIVATE SECTION.
    CONSTANTS company_hml TYPE bukrs VALUE '1000'.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ProgPaySpot RESULT result.

    METHODS createPurchaseOrder FOR MODIFY
      IMPORTING keys FOR ACTION ProgPaySpot~createPurchaseOrder RESULT result.
    METHODS paymentMade FOR MODIFY
      IMPORTING keys FOR ACTION ProgPaySpot~paymentMade RESULT result.

ENDCLASS.


CLASS lhc_ProgPaySpot IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD createPurchaseOrder.
    DATA header              TYPE TABLE FOR CREATE I_PurchaseOrderTP_2.
    DATA items               TYPE TABLE FOR CREATE I_PurchaseOrderTP_2\_PurchaseOrderItem.
    DATA account_assignments TYPE TABLE FOR CREATE I_PurchaseOrderItemTP_2\_PurOrdAccountAssignment.
    DATA notes               TYPE TABLE FOR CREATE I_PurchaseOrderTP_2\_PurchaseOrderNote.

    DATA(progress_pay_spot) = keys[ 1 ]-%param.

    DATA(progress_pay_spot_key) = keys[ 1 ]-%key.

*    IF keys[ 1 ]-%param-PostingDate IS INITIAL.
*      reported-progpayspot = VALUE #( ( %key = progress_pay_spot_key
*                                        %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
*                                                            number   = '010'
*                                                            severity = if_abap_behv_message=>severity-error
*                                                            v1       = progress_pay_spot_key-TransportDocNo ) ) ).
*      RETURN.
*    ENDIF.

*    READ ENTITIES OF ZR_ProgressPaymentSpot IN LOCAL MODE
*         ENTITY ProgPaySpot
*         ALL FIELDS WITH CORRESPONDING #( keys )
*         RESULT DATA(progress_pay_spots).
*
*    DATA(progress_pay_spot) = progress_pay_spots[ 1 ].

    IF progress_pay_spot-PurchaseOrder IS NOT INITIAL.
      reported-progpayspot = VALUE #( ( %key = progress_pay_spot_key
                                        %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
                                                            number   = '005'
                                                            severity = if_abap_behv_message=>severity-error
                                                            v1       = progress_pay_spot_key-TransportDocNo ) ) ).
      RETURN.
    ENDIF.

*    SELECT SINGLE
*      FROM I_EnterpriseProject AS proj
*           INNER JOIN
*           I_ProductText       AS text ON  ltrim( text~Product, '0' ) = proj~Project
*                                       AND text~ProductName           = proj~ProjectDescription
*      FIELDS text~Product,
*             proj~Project,
*             text~ProductName
*      WHERE text~Product = @progress_pay_spot_key-Product
*      INTO @DATA(products_wbs_element).
*    IF sy-subrc <> 0.
*      reported-progpayspot = VALUE #( ( %key = progress_pay_spot_key
*                                        %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
*                                                            number   = 001
*                                                            severity = if_abap_behv_message=>severity-error
*                                                            v1       = progress_pay_spot_key-Product ) ) ).
*      RETURN.
*    ENDIF.

    SELECT SINGLE FROM I_PurchasingOrganization WITH
      PRIVILEGED ACCESS
      FIELDS CompanyCode
      WHERE PurchasingOrganization = @progress_pay_spot-PurchasingOrganization
      INTO @DATA(company_code).

    SELECT SINGLE FROM ZI_MmSpotWbsDatabaseTa WITH
      PRIVILEGED ACCESS
      FIELDS Wbs
      WHERE CompanyCode = @company_code
      INTO @DATA(wbs_element).
    IF wbs_element IS INITIAL.
      reported-progpayspot = VALUE #( ( %key = progress_pay_spot_key
                                        %msg = new_message( id       = 'ZMM_PROG_PAY_COCKPIT'
                                                            number   = '004'
                                                            severity = if_abap_behv_message=>severity-error ) ) ).
      RETURN.
    ENDIF.

    SELECT SINGLE FROM I_ProductText
      FIELDS ProductName
      WHERE Product = @progress_pay_spot-Product
      INTO @DATA(product_name).

*    zcl_mm_prog_pay_helper=>get_gl_account( EXPORTING
**                                              company_code = company_hml
*                                              company_code = company_code
*                                              product      = progress_pay_spot-Product
*                                            IMPORTING
*                                              gl_account   = DATA(gl_account)
*                                              message      = DATA(gl_account_error) ).
    zcl_mm_prog_pay_helper=>get_gl_acc_vehicle_category(
      EXPORTING
        purchasing_organization = progress_pay_spot-PurchasingOrganization
        product                 = progress_pay_spot-Product
      IMPORTING
        gl_account              = DATA(gl_account)
        message                 = DATA(gl_account_error) ).
    IF gl_account_error IS NOT INITIAL.
      reported-progpayspot = VALUE #( ( %key = progress_pay_spot_key
                                        %msg = new_message( id       = gl_account_error-id
                                                            number   = gl_account_error-number
                                                            severity = CONV #( gl_account_error-type )
                                                            v1       = gl_account_error-message_v1
                                                            v2       = gl_account_error-message_v2
                                                            v3       = gl_account_error-message_v3
                                                            v4       = gl_account_error-message_v4 ) ) ).
      RETURN.
    ENDIF.

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

    SELECT SINGLE FROM ZR_ProgressPayment
      FIELDS TransportationStartDate
      WHERE TransportDocNo = @progress_pay_spot_key-TransportDocNo
      INTO @DATA(posting_date).

    header = VALUE #( ( %cid                        = header_cid
                        PurchaseOrderType           = 'NB'
                        PurchaseOrderDate           = posting_date
*                        CompanyCode                 = '1000'
                        CompanyCode                 = company_code
*                        PurchasingOrganization      = '1010'
                        PurchasingOrganization      = progress_pay_spot-PurchasingOrganization
                        PurchasingGroup             = '003'
                        Supplier                    = progress_pay_spot-Supplier
*                        YY1_TotalBonusAmount_PDH    = progress_pay_spot-AdditionalPromotion
                        YY1_TotalBonusAmount_PDHC   = progress_pay_spot-Currency
*                        YY1_TotalDeductionAmnt_PDH  = progress_pay_spot-Deduction
                        YY1_TotalDeductionAmnt_PDHC = progress_pay_spot-Currency
                        YY1_PaymentUUID_PDH         = payment_uuid
                        %control                    = VALUE #(
                            PurchaseOrderType           = cl_abap_behv=>flag_changed
                            PurchaseOrderDate           = cl_abap_behv=>flag_changed
                            CompanyCode                 = cl_abap_behv=>flag_changed
                            PurchasingOrganization      = cl_abap_behv=>flag_changed
                            PurchasingGroup             = cl_abap_behv=>flag_changed
                            Supplier                    = cl_abap_behv=>flag_changed
                            YY1_PaymentUUID_PDH         = cl_abap_behv=>flag_changed
                            YY1_TotalBonusAmount_PDH    = cl_abap_behv=>flag_changed
                            YY1_TotalBonusAmount_PDHC   = cl_abap_behv=>flag_changed
                            YY1_TotalDeductionAmnt_PDH  = cl_abap_behv=>flag_changed
                            YY1_TotalDeductionAmnt_PDHC = cl_abap_behv=>flag_changed ) ) ).

    items = VALUE #( ( %cid_ref = header_cid
                       %target  = VALUE #( ( %cid                      = items_cid
                                             PurchaseOrderItem         = '00010'
*                                             Plant                     = '1000'
                                             Plant                     = CONV #( company_code )
                                             Material                  = progress_pay_spot-Product
*                                             PurchaseOrderItemText     = |{ products_wbs_element-ProductName } - Nakliye Bedeli|
                                             PurchaseOrderItemText     = |{ product_name } - Nakliye Bedeli|
                                             OrderQuantity             = 1
                                             NetPriceAmount            = progress_pay_spot-TotalPrice
                                             AccountAssignmentCategory = 'P'
                                             DocumentCurrency          = progress_pay_spot-Currency
                                             GoodsReceiptIsExpected    = abap_false
                                             TaxCode                   = space
*                                             DownPaymentType           = 'M'
*                                             DownPaymentAmount         = progress_pay_spot-SpotFuelAmount
*                                             DownPaymentDueDate        = cl_abap_context_info=>get_system_date( )
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
                                                 TaxCode                   = cl_abap_behv=>flag_changed
*                                                 DownPaymentType           = cl_abap_behv=>flag_changed
*                                                 DownPaymentAmount         = cl_abap_behv=>flag_changed
*                                                 DownPaymentDueDate        = cl_abap_behv=>flag_changed
                                                  ) ) ) ) ).

    account_assignments = VALUE #(
        ( %cid_ref          = items_cid
          PurchaseOrderItem = '00010'
          %target           = VALUE #( ( %cid                    = account_assignments_cid
                                         PurchaseOrderItem       = '00010'
                                         AccountAssignmentNumber = '01'
*                                         GLAccount               = '7400501001'
                                         GLAccount               = gl_account
*                                         WBSElementExternalID    = progress_pay_spot-ProductName
*                                         WBSElementExternalID    = |{ progress_pay_spot_key-Product ALPHA = OUT }|
*                                         WBSElementExternalID    = products_wbs_element-Project
                                         WBSElementExternalID    = wbs_element
                                         %control                = VALUE #(
                                             PurchaseOrderItem       = cl_abap_behv=>flag_changed
                                             AccountAssignmentNumber = cl_abap_behv=>flag_changed
                                             GLAccount               = cl_abap_behv=>flag_changed
                                             WBSElementExternalID    = cl_abap_behv=>flag_changed ) ) ) ) ).

    DATA(long_text) = |Navlun Tutarı: { progress_pay_spot-SpotPaymentPrice } TRY + KDV { cl_abap_char_utilities=>newline }| &&
                      |Yapılan Yakıt Ödemesi: { progress_pay_spot-SpotFuelAmount } TRY { cl_abap_char_utilities=>newline }| &&
                      |Ek Prim: { progress_pay_spot-AdditionalPromotion }{ cl_abap_char_utilities=>newline }| &&
                      |Kesinti: { progress_pay_spot-Deduction }|.

*    DATA(date_where) = |TransportationStartdate LIKE '{ progress_pay_spot-CalendarYear }{ progress_pay_spot-CalendarMonth }%'|.
*    SELECT FROM zr_mm_prog_pay as prog
    SELECT FROM ZR_ProgressPayment
      FIELDS transportdocno
*      WHERE Product                 = @progress_pay_spot_key-Product
*      AND   Supplier                = @progress_pay_spot_key-Supplier
*      AND   Customer                = @progress_pay_spot_key-Customer
*      AND   PurchasingOrganization  = @progress_pay_spot_key-PurchasingOrganization
      WHERE TransportDocNo    = @progress_pay_spot_key-TransportDocNo
        AND SpotPaymentPrice IS NOT INITIAL
*      AND   (date_where)
      INTO TABLE @DATA(progress_payments_ids).

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

    MODIFY ENTITIES OF I_PurchaseOrderTP_2 FORWARDING PRIVILEGED
           ENTITY PurchaseOrder
           CREATE FIELDS ( PurchaseOrderType
                           PurchaseOrderDate
                           CompanyCode
                           PurchasingOrganization
                           PurchasingGroup
                           Supplier
                           YY1_TotalBonusAmount_PDH
                           YY1_TotalBonusAmount_PDHC
                           YY1_TotalDeductionAmnt_PDH
                           YY1_TotalDeductionAmnt_PDHC
                           YY1_PaymentUUID_PDH ) WITH header
           CREATE BY \_PurchaseOrderNote FIELDS ( TextObjectType
                                                  Language
                                                  PlainLongText ) WITH notes
           CREATE BY \_PurchaseOrderItem FIELDS ( PurchaseOrderItem
                                                  Plant
                                                  Material
                                                  PurchaseOrderItemText
                                                  OrderQuantity
                                                  NetPriceAmount
                                                  AccountAssignmentCategory
                                                  DocumentCurrency
                                                  GoodsReceiptIsExpected
                                                  TaxCode
*                                                  DownPaymentType
*                                                  DownPaymentAmount
*                                                  DownPaymentDueDate
                                                   ) WITH items
           ENTITY PurchaseOrderItem
           CREATE BY \_PurOrdAccountAssignment FIELDS ( PurchaseOrderItem
                                                        AccountAssignmentNumber
                                                        GLAccount
                                                        WBSElementExternalID ) WITH account_assignments
    " TODO: variable is assigned but never used (ABAP cleaner)
           REPORTED DATA(reported_create)
           FAILED   DATA(failed_create)
           " TODO: variable is assigned but never used (ABAP cleaner)
           MAPPED   DATA(mapped_create).
    IF failed_create IS INITIAL.
*      DATA(date_where) = |TransportationStartdate LIKE '{ progress_pay_spot_key-CalendarYear }{ progress_pay_spot_key-CalendarMonth }%'|.
*      SELECT FROM zr_mm_prog_pay
*        FIELDS transportdocno
*        WHERE Product = @progress_pay_spot_key-Product
*        AND   Supplier = @progress_pay_spot_key-Supplier
*        AND   Customer = @progress_pay_spot_key-Customer
*        AND   SpotPaymentPrice IS NOT INITIAL
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
        reported-progpayspot = VALUE #( ( %key = progress_pay_spot_key
                                          %msg = new_message(
                                                     id       = 'ZMM_PROG_PAY_COCKPIT'
                                                     number   = 002
                                                     severity = if_abap_behv_message=>severity-success
                                                     v1       = |{ progress_pay_spot-Supplier ALPHA = OUT }|
                                                     v2       = |{ progress_pay_spot-Product ALPHA = OUT }| ) ) ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD paymentMade.
*    DATA(payment_made) = keys[ 1 ]-%key.

*    READ ENTITIES OF zr_mm_prg_pay_pymt
*         ENTITY ProgressPaymentSpotPayment
*         ALL FIELDS WITH CORRESPONDING #( keys )
*         RESULT DATA(spot_payments).

*    DELETE spot_payments WHERE PaymentMade IS NOT INITIAL.
*    DELETE spot_payments WHERE P
*
*    IF spot_payments IS INITIAL.
*      MODIFY ENTITIES OF zr_mm_prg_pay_pymt
*             ENTITY ProgressPaymentSpotPayment
*             CREATE AUTO FILL CID FIELDS ( Calendaryear
*                                           Calendarmonth
*                                           Supplier
*                                           Product
*                                           Customer
*                                           PurchasingOrganization
*                                           PaymentMade )
*             WITH VALUE #( ( %data    = VALUE #( %key        = CORRESPONDING #( payment_made )
*                                                 PaymentMade = abap_true )
*                             %control = VALUE #( Calendaryear           = cl_abap_behv=>flag_changed
*                                                 Calendarmonth          = cl_abap_behv=>flag_changed
*                                                 Supplier               = cl_abap_behv=>flag_changed
*                                                 Product                = cl_abap_behv=>flag_changed
*                                                 Customer               = cl_abap_behv=>flag_changed
*                                                 PurchasingOrganization = cl_abap_behv=>flag_changed
*                                                 PaymentMade            = cl_abap_behv=>flag_changed ) ) )
*                                              " TODO: variable is assigned but never used (ABAP cleaner)
*             REPORTED DATA(reported_create).
*    ELSE.
*      MODIFY ENTITIES OF zr_mm_prg_pay_pymt
*             ENTITY ProgressPaymentSpotPayment
*             UPDATE FIELDS ( PaymentMade )
*             WITH VALUE #( ( %data    = VALUE #( %key        = CORRESPONDING #( payment_made )
*                                                 PaymentMade = abap_true )
*                             %control = VALUE #( PaymentMade = cl_abap_behv=>flag_changed ) ) )
*                                              " TODO: variable is assigned but never used (ABAP cleaner)
*             REPORTED DATA(reported_update).
*    ENDIF.

    DATA lv_cid TYPE abp_behv_cid.

    CLEAR lt_je_deep.

    READ ENTITIES OF ZR_ProgressPaymentSpot IN LOCAL MODE
         ENTITY ProgPaySpot
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(progress_payments).

*    DELETE progress_payments WHERE PurchaseOrder IS INITIAL.
*    DELETE progress_payments WHERE PaymentMade IS NOT INITIAL.
*    DELETE progress_payments WHERE SpotFuelAmount IS INITIAL.
*
*    IF progress_payments IS INITIAL.
*      RETURN.
*    ENDIF.

    DATA(progress_payment) = progress_payments[ 1 ].

    IF progress_payment-PurchaseOrder IS INITIAL.
      reported-progpayspot = VALUE #( ( %key-TransportDocNo = progress_payment-%key-TransportDocNo
                                        %msg                = new_message(
                                                                  id       = 'ZMM_PROG_PAY_COCKPIT'
                                                                  number   = 007
                                                                  severity = if_abap_behv_message=>severity-error
                                                                  v1       = progress_payment-%key-TransportDocNo ) ) ).
      RETURN.
    ENDIF.

    IF progress_payment-SpotFuelAmount IS INITIAL.
      reported-progpayspot = VALUE #( ( %key-TransportDocNo = progress_payment-%key-TransportDocNo
                                        %msg                = new_message(
                                                                  id       = 'ZMM_PROG_PAY_COCKPIT'
                                                                  number   = 009
                                                                  severity = if_abap_behv_message=>severity-error
                                                                  v1       = progress_payment-%key-TransportDocNo ) ) ).
      RETURN.
    ENDIF.

    IF progress_payment-PaymentMade IS NOT INITIAL.
      reported-progpayspot = VALUE #( ( %key-TransportDocNo = progress_payment-%key-TransportDocNo
                                        %msg                = new_message(
                                                                  id       = 'ZMM_PROG_PAY_COCKPIT'
                                                                  number   = 008
                                                                  severity = if_abap_behv_message=>severity-error
                                                                  v1       = progress_payment-%key-TransportDocNo ) ) ).
      RETURN.
    ENDIF.

    SELECT SINGLE COUNT( * ) FROM I_JournalEntry WITH
      PRIVILEGED ACCESS
      WHERE DocumentReferenceID     = @progress_payment-PurchaseOrder
        AND ReverseDocument        IS INITIAL
        AND AccountingDocumentType  = 'KZ'.
    IF sy-subrc = 0.
      reported-progpayspot = VALUE #( ( %key-TransportDocNo = progress_payment-%key-TransportDocNo
                                        %msg                = new_message(
                                                                  id       = 'ZMM_PROG_PAY_COCKPIT'
                                                                  number   = 008
                                                                  severity = if_abap_behv_message=>severity-error
                                                                  v1       = progress_payment-%key-TransportDocNo ) ) ).
      RETURN.
    ENDIF.

    TRY.
        lv_cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.

    SELECT SINGLE FROM I_PurchasingOrganization WITH
      PRIVILEGED ACCESS
      FIELDS CompanyCode
      WHERE PurchasingOrganization = @progress_payment-PurchasingOrganization
      INTO @DATA(company_code).

    SELECT SINGLE FROM I_ProductText
      FIELDS ProductName
      WHERE Product  = @progress_payment-Product
        AND Language = 'T'
      INTO @DATA(product_name).

    SELECT SINGLE FROM ZR_ProgressPayment
      FIELDS TransportationStartDate
      WHERE TransportDocNo = @progress_payment-TransportDocNo
      INTO @DATA(posting_date).

    CLEAR lt_je_deep.

    APPEND INITIAL LINE TO lt_je_deep ASSIGNING FIELD-SYMBOL(<je_deep>).
    <je_deep>-%cid   = lv_cid.
    <je_deep>-%param = VALUE #(
        companycode                  = company_code
        documentreferenceid          = progress_payment-PurchaseOrder
        createdbyuser                = cl_abap_context_info=>get_user_technical_name( )
*        businesstransactiontype      = 'AZAF'
        businesstransactiontype      = 'RFBU'
        accountingdocumenttype       = 'KZ'
        documentdate                 = posting_date
        postingdate                  = posting_date
*        accountingdocumentheadertext = |{ progress_payment-PurchaseOrder } Yakıt Ödemesi|
        accountingdocumentheadertext = |{ progress_payment-TransportDocNo }_{ progress_payment-PurchaseOrder }|
        _apitems                     = VALUE #(
            ( glaccountlineitem = |001|
              Supplier          = progress_payment-Supplier
*              DueCalculationBaseDate = cl_abap_context_info=>get_system_date( )
*              SpecialGLCode     = 'F'
              DocumentItemText  = |{ progress_payment-TransportDocNo } { progress_payment-PurchaseOrder } { product_name } Yakıt Avans Ödemesi|
              _currencyamount   = VALUE #( ( CurrencyRole           = '00'
                                             JournalEntryItemAmount = progress_payment-SpotFuelAmount * ( 116 / 100 )
                                             Currency               = progress_payment-Currency ) ) ) )
        _glitems                     = VALUE #(
            ( GLAccountLineItem = |002|
              GLAccount         = '3290201001'
              DocumentItemText  = |{ progress_payment-TransportDocNo } { progress_payment-PurchaseOrder } { product_name } Yakıt Avans Ödemesi|
              _currencyamount   = VALUE #(
                  ( CurrencyRole           = '00'
                    JournalEntryItemAmount = progress_payment-SpotFuelAmount * ( 116 / 100 ) * ( -1 )
                    Currency               = progress_payment-Currency ) ) ) ) ).

    transport_doc_no = progress_payment-TransportDocNo.

    result = VALUE #( ( %key-TransportDocNo = progress_payment-TransportDocNo ) ).
  ENDMETHOD.
ENDCLASS.


CLASS lsc_ZR_PROGRESSPAYMENTSPOT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.


CLASS lsc_ZR_PROGRESSPAYMENTSPOT IMPLEMENTATION.
  METHOD save_modified.
    DATA lo_operation TYPE REF TO if_bgmc_op_single_tx_uncontr.

    IF lhc_progpayspot=>lt_je_deep IS INITIAL.
      RETURN.
    ENDIF.

    lo_operation = NEW zcl_mm_down_payment_bgpf_uncnt( lhc_progpayspot=>lt_je_deep ).
    TRY.
        DATA(lo_process) = cl_bgmc_process_factory=>get_default( )->create( ).
        lo_process->set_name( 'Uncontrolled Process Create Down Payment' )->set_operation_tx_uncontrolled( lo_operation ).
        lo_process->save_for_execution( ).
      CATCH cx_bgmc INTO DATA(lx_bgmc).
        reported-progpayspot = VALUE #( ( %key-TransportDocNo = lhc_progpayspot=>transport_doc_no
                                          %msg                = new_message_with_text(
                                                                    severity = if_abap_behv_message=>severity-error
                                                                    text     = CONV #( lx_bgmc->get_longtext( ) ) ) ) ).

    ENDTRY.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
