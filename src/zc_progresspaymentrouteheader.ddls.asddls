@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Route Header'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_ProgressPaymentRouteHeader
  //  provider contract transactional_query
  as projection on ZR_ProgressPaymentRouteHeader
 
{
  key     CalendarYear,
  key     CalendarMonth,

          @ObjectModel.text.element: [ 'SupplierName' ]
  key     Supplier,

          @ObjectModel.text.element: [ 'ProductName' ]
  key     Product,

          @ObjectModel.text.element: [ 'CustomerName' ]
  key     Customer,

          @ObjectModel.text.element: [ 'PurchasingOrganizationName' ]
  key     PurchasingOrganization,

          @ObjectModel.text.element: [ 'Vehiclecategorydesc' ]
          VehicleCategory,

          @ObjectModel.text.element: [ 'VehicleTypeDesc' ]
          VehicleType,

          @ObjectModel.text.element: [ 'Vehiclebodydesc' ]
          VehicleBody,

          VehicleCapacity,

          @ObjectModel.text.element: [ 'Vestingmodeldesc' ]
          VestingModel,

//          @ObjectModel.text.element: [ 'DistributionChannelName' ]
//          OperationType,

          Currency,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  virtual ActualTripCount        : zmm_actual_trip_count,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  virtual ActualKM               : zmm_total_km,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
          @Semantics.amount.currencyCode: 'Currency'
  virtual VestingAmount          : zmm_progress_pay_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
          @Semantics.amount.currencyCode: 'Currency'
  virtual TotalDeductionAmount   : zmm_total_deduction_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
          @Semantics.amount.currencyCode: 'Currency'
  virtual BonusAmount            : zmm_additional_bonus_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
          @Semantics.amount.currencyCode: 'Currency'
  virtual FuelVestingAmount      : zmm_fuel_vesting_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
          @Semantics.amount.currencyCode: 'Currency'
  virtual VehicleDeductionAmount : zmm_deduction,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
          @Semantics.amount.currencyCode: 'Currency'
  virtual TotalVestingAmount     : zmm_total_progress_pay_amount,

          @Semantics.text: true
          _Customer.CustomerName,

//          @Semantics.text: true
//          _DistributionChannel._Text.DistributionChannelName : localized,

          @Semantics.text: true
          _Product._Text.ProductName                         : localized,

          @Semantics.text: true
          _Supplier.SupplierName,

          @Semantics.text: true
          _VehicleBody.Vehiclebodydesc,

          @Semantics.text: true
          _VehicleCategory.Vehiclecategorydesc,

          @Semantics.text: true
          _VehicleType.VehicleTypeDesc,

          @Semantics.text: true
          _VestingModel.Vestingmodeldesc,

          @Semantics.text: true
          _PurchasingOrganization.PurchasingOrganizationName,

          PurchaseOrder,
          
          PurchasingHistoryDocument,

          POFilter,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual POStatus               : abap.int4,
  
  SupplierInvoiceReference,
  @Semantics.amount.currencyCode: 'TotalBonusCurrency'
  TotalBonus,
  TotalBonusCurrency,
  DieselPercentage,
  @ObjectModel.text.element: [ 'BusinessPartnerName1' ]
  OperationRegion,
  BusinessPartnerName1,
  
   @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  virtual total_fuel_taken_liters : zmm_total_fuel_takenlt,
  
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  virtual diff_liters             : zmm_diff_liters,
 
   @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  virtual earned_liter            : zmm_earned_liter,
 
   @Semantics.amount.currencyCode: 'TotalDeducamountC'
  TotalDeducamount,
  TotalDeducamountC,
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  @Semantics.amount.currencyCode: 'Currency'
  virtual total_fuel_ent_ex_vat : zmm_total_fuelexcvat,
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_HEADER'
  @Semantics.amount.currencyCode: 'Currency'
  virtual total_fuel_cost_exc_vat : zmm_totalfuelcostexcvat,
  @Semantics.amount.currencyCode: 'Currency'
  AverageFuelAmountVehicle,
  

          /* Associations */
          _Customer,
//          _DistributionChannel,
          _Product,
          _Supplier,
          _VehicleBody,
          _VehicleCategory,
          _VehicleType,
          _VestingModel,
          _PurchasingOrganization,

          _Item : redirected to composition child ZC_ProgressPaymentRouteItem
}
