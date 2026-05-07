@EndUserText.label: 'MM Material Group Database Table Singlet'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MmMaterialGroupDAll'
  }
}
define root view entity ZI_MmMaterialGroupData_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_MMMATERIALGROUPDATA'
//  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_MmMaterialGroupData as _MmMaterialGroupData
{
  @UI.facet: [ {
    id: 'ZI_MmMaterialGroupData', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'G/L Material Group Database Table', 
    position: 1 , 
    targetElement: '_MmMaterialGroupData'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MmMaterialGroupData,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax
//  @ObjectModel.text.association: '_ABAPTransportRequestText'
//  @UI.identification: [ {
//    position: 2 , 
//    type: #WITH_INTENT_BASED_NAVIGATION, 
//    semanticObjectAction: 'manage'
//  }, {
//    type: #FOR_ACTION, 
//    dataAction: 'SelectCustomizingTransptReq', 
//    label: 'Select Transport'
//  } ]
//  @Consumption.semanticObject: 'CustomizingTransport'
//  cast( '' as sxco_transport) as TransportRequestID,
//  _ABAPTransportRequestText,
//  @UI.hidden: true
//  cast( 'X' as abap_boolean preserving type) as HideTransport
  
}
where I_Language.Language = $session.system_language
