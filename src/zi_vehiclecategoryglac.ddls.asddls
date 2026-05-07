@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: 'Vehicle Category GL Account Matching'

@Metadata.allowExtensions: true

define view entity ZI_VehicleCategoryGlAc
  as select from zmm_vehc_glacc

  association [0..1] to        I_CompanyCode            as _CompanyCode         on $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to        ZI_MMVEHICLECATEGORY     as _VehicleCategory     on $projection.VehicleCategory = _VehicleCategory.Vehiclecategory

  association [0..1] to        I_GLAccount              as _GLAccount           on  $projection.GlAccount   = _GLAccount.GLAccount
                                                                                and $projection.CompanyCode = _GLAccount.CompanyCode

  association        to parent ZI_VehicleCategoryGlAc_S as _VehicleCategoryGAll on $projection.SingletonID = _VehicleCategoryGAll.SingletonID

{
      @ObjectModel.text.association: '_CompanyCode'
  key company_code          as CompanyCode,

      @ObjectModel.text.association: '_VehicleCategory'
  key vehicle_category      as VehicleCategory,

      @ObjectModel.text.association: '_GLAccount'
      gl_account            as GlAccount,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      @Consumption.hidden: true
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      @Consumption.hidden: true
      1                     as SingletonID,

      _VehicleCategoryGAll,
      _CompanyCode,
      _VehicleCategory,
      _GLAccount
}
