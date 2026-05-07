@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: 'G/L Material Group Database Table'

@Metadata.allowExtensions: true

define view entity ZI_MmMaterialGroupData
  as select from zmm_t_matl_grp

  association to parent ZI_MmMaterialGroupData_S as _MmMaterialGroupDAll on $projection.SingletonID = _MmMaterialGroupDAll.SingletonID
  association [0..1] to I_CompanyCode            as _CompanyCode         on $projection.Companycode = _CompanyCode.CompanyCode

{
      @ObjectModel.text.reference.association: '_CompanyCode'
  key companycode           as Companycode,

  key materialgroup         as Materialgroup,

      glaccount             as Glaccount,

      @Consumption.hidden: true
      1                     as SingletonID,

      _MmMaterialGroupDAll,
      _CompanyCode
}
