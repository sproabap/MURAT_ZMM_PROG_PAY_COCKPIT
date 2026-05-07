@EndUserText.label: 'Vehicle Category GL Account Matching Sin'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'VehicleCategoryGAll'
  }
}
define root view entity ZI_VehicleCategoryGlAc_S
  as select from I_Language
    left outer join ZMM_VEHC_GLACC on 0 = 0
  composition [0..*] of ZI_VehicleCategoryGlAc as _VehicleCategoryGlAc
{
  @UI.facet: [ {
    id: 'ZI_VehicleCategoryGlAc', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Vehicle Category GL Account Matching', 
    position: 1 , 
    targetElement: '_VehicleCategoryGlAc'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _VehicleCategoryGlAc,
  @UI.hidden: true
  max( ZMM_VEHC_GLACC.LAST_CHANGED_AT ) as LastChangedAtMax
}
where I_Language.Language = $session.system_language
