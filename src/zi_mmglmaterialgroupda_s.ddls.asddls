@EndUserText.label: 'MM G/L Material Group Database Table Sin'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MmGLMaterialGrouAll'
  }
}
define root view entity ZI_MmGLMaterialGroupDa_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_MMGLMATERIALGROUPDA'
  composition [0..*] of ZI_MmGLMaterialGroupDa as _MmGLMaterialGroupDa
{
  @UI.facet: [ {
    id: 'ZI_MmGLMaterialGroupDa', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'MM G/L Material Group Database Table', 
    position: 1 , 
    targetElement: '_MmGLMaterialGroupDa'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MmGLMaterialGroupDa,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
  
}
where I_Language.Language = $session.system_language
