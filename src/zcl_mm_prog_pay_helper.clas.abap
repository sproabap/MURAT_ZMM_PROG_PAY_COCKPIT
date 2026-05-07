CLASS zcl_mm_prog_pay_helper DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS
      get_gl_account
        IMPORTING company_code TYPE bukrs DEFAULT '1000'
                  !product     TYPE matnr
        EXPORTING gl_account   TYPE saknr
                  !message     TYPE bapiret2.

    CLASS-METHODS
      get_gl_acc_vehicle_category
        IMPORTING purchasing_organization TYPE ekorg DEFAULT '1010'
                  !product                TYPE matnr
        EXPORTING gl_account              TYPE saknr
                  !message                TYPE bapiret2.

ENDCLASS.



CLASS ZCL_MM_PROG_PAY_HELPER IMPLEMENTATION.


  METHOD get_gl_account.
    SELECT SINGLE FROM I_Product
      FIELDS ProductGroup
      WHERE Product = @product
      INTO @DATA(product_group).

    SELECT SINGLE FROM zmm_t_matl_grp
      FIELDS glaccount
      WHERE companycode   = @company_code
        AND materialgroup = @product_group
      INTO @gl_account.
    IF sy-subrc <> 0 OR gl_account IS INITIAL.
      message = VALUE #( id         = 'ZMM_PROG_PAY_COCKPIT'
                         number     = 003
                         type       = 'E'
                         message_v1 = product_group  ).
    ENDIF.
  ENDMETHOD.


  METHOD get_gl_acc_vehicle_category.
    SELECT SINGLE FROM I_PurchasingOrganization WITH
      PRIVILEGED ACCESS
      FIELDS CompanyCode
      WHERE PurchasingOrganization = @purchasing_organization
      INTO @DATA(company_code).

    SELECT SINGLE FROM I_Plant WITH
      PRIVILEGED ACCESS
      FIELDS Plant
      WHERE ValuationArea = @company_code
      INTO @DATA(plant).

    SELECT SINGLE FROM I_ProductPlantBasic WITH
      PRIVILEGED ACCESS
      FIELDS YY1_PlantVehcCategory_PLT
      WHERE Product = @product
        AND Plant   = @plant
      INTO @DATA(vehicle_category).

    SELECT SINGLE FROM ZI_VehicleCategoryGlAc WITH
      PRIVILEGED ACCESS
      FIELDS GlAccount
      WHERE CompanyCode     = @company_code
        AND VehicleCategory = @vehicle_category
      INTO @gl_account.
    IF sy-subrc <> 0 OR gl_account IS INITIAL.
      message = VALUE #( id         = 'ZMM_PROG_PAY_COCKPIT'
                         number     = 013
                         type       = 'E'
                         message_v1 = company_code
                         message_v2 = vehicle_category  ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
