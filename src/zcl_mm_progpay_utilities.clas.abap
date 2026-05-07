CLASS zcl_mm_progpay_utilities DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_transportation_document,
             transportation_document TYPE zsd_de_transportdocno,
           END OF ty_transportation_document.

    TYPES tt_transportation_document TYPE TABLE OF ty_transportation_document.

    CLASS-METHODS check_reconciliation_status
      CHANGING transportation_documents TYPE tt_transportation_document.
ENDCLASS.



CLASS ZCL_MM_PROGPAY_UTILITIES IMPLEMENTATION.


  METHOD check_reconciliation_status.
    DATA transportation_document_range TYPE RANGE OF zsd_de_transportdocno.

    SELECT FROM I_SalesDocument WITH
      PRIVILEGED ACCESS AS SalesDocument
     INNER JOIN @transportation_documents AS transportdoc ON transportdoc~transportation_document = SalesDocument~PurchaseOrderByCustomer
      FIELDS DISTINCT 'I'                                   AS sign,
                      'EQ'                                  AS option,
                      salesdocument~PurchaseOrderByCustomer AS low
      WHERE SalesDocument~overallsddocumentrejectionsts NOT IN ( 'B', 'C' )
        AND SalesDocument~SDDocumentCategory                 = 'C'
      INTO CORRESPONDING FIELDS OF TABLE @transportation_document_range.

    SELECT FROM ZI_SalesRecFixedRentSalesOrder WITH
      PRIVILEGED ACCESS AS FixedRent
     INNER JOIN @transportation_documents AS transportdoc ON transportdoc~transportation_document = FixedRent~TransportDocNo
      FIELDS DISTINCT 'I'                      AS sign,
                      'EQ'                     AS option,
                      FixedRent~TransportDocNo AS low
      APPENDING CORRESPONDING FIELDS OF TABLE @transportation_document_range.

    IF transportation_document_range IS NOT INITIAL.
      DELETE transportation_documents WHERE transportation_document IN transportation_document_range.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
