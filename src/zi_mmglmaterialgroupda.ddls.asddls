@AccessControl.authorizationCheck: #MANDATORY

@EndUserText.label: 'MM G/L Material Group Database Table'

@Metadata.allowExtensions: true

define view entity ZI_MmGLMaterialGroupDa
  as select from zmm_t_matl_grp

  association to parent ZI_MmGLMaterialGroupDa_S as _MmGLMaterialGrouAll on $projection.SingletonID = _MmGLMaterialGrouAll.SingletonID
  association [0..1] to I_CompanyCode            as _CompanyCode         on $projection.Companycode = _CompanyCode.CompanyCode
  association [0..*] to I_ProductGroupText_2     as _ProductGroupText    on $projection.Materialgroup = _ProductGroupText.ProductGroup
  association [0..*] to I_GLAccountText          as _GLAccountText       on $projection.Glaccount = _GLAccountText.GLAccount

{
      @ObjectModel.text.association: '_CompanyCode'
  key companycode           as Companycode,

      @ObjectModel.text.association: '_ProductGroupText'
  key materialgroup         as Materialgroup,

      @ObjectModel.text.association: '_GLAccountText'
      glaccount             as Glaccount,

      @Consumption.hidden: true
      1                     as SingletonID,

      _MmGLMaterialGrouAll,
      _CompanyCode,
      _ProductGroupText,
      _GLAccountText
}
