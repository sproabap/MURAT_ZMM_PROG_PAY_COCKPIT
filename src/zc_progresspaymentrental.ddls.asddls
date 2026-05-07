@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Progress Payment Rental'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_ProgressPaymentRental
  provider contract transactional_query
  as projection on ZR_ProgressPaymentRental

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

//          @ObjectModel.text.element: [ 'DistributionChannelName' ]
//          OperationType,

          @ObjectModel.text.element: [ 'VehicleCategoryDescription' ]
          VehicleCategory,

          @ObjectModel.text.element: [ 'VehicleTypeDescription' ]
          VehicleType,

          @ObjectModel.text.element: [ 'VehicleBodyDescription' ]
          VehicleBody,

          VehicleCapacity,

          @ObjectModel.text.element: [ 'VestingModelDescription' ]
          VestingModel,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual TargetDays                : zmm_target_days,

          //          ActualDays,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual ActualDays                : zmm_actual_days,

          ActualTripCount,
          ActualKM,

          Currency,

          @Semantics.text: true
          _Supplier.SupplierName,

          @Semantics.text: true
          _Product._Text.ProductName                         : localized,

          @Semantics.text: true
          _Customer.CustomerName,
//          _DefaultCustomer.CustomerName,

          @Semantics.text: true
          _VehicleCategory.Vehiclecategorydesc                as VehicleCategoryDescription,

          @Semantics.text: true
          _VehicleType.VehicleTypeDesc                        as VehicleTypeDescription,

          @Semantics.text: true
          _VehicleBody.Vehiclebodydesc                        as VehicleBodyDescription,

          @Semantics.text: true
          _VestingModel.Vestingmodeldesc                      as VestingModelDescription,

//          _DistributionChannel._Text.DistributionChannelName : localized,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual TargetTripCount           : zmm_target_trips,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual TargetKM                  : zmm_target_km,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual TargetPrice               : zmm_target_price,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual VestingAmount             : zmm_progress_pay_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual AdditionalTripBonusAmount : zmm_additional_trip_bonus_amt,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual KMBonusAmount             : zmm_km_bonus_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual WageDeductionAmount       : zmm_wage_deduction_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual KMDeductionAmount         : zmm_km_deduction_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual TotalDeductionAmount      : zmm_total_deduction_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual BonusAmount               : zmm_additional_bonus_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual FuelVestingAmount         : zmm_fuel_vesting_amount,

//          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
//          @Semantics.amount.currencyCode: 'Currency'
//  virtual VehicleDeductionAmount    : zvestdeductamount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
          @Semantics.amount.currencyCode: 'Currency'
  virtual TotalVestingAmount        : zmm_total_progress_pay_amount,
          //  virtual TotalVestingAmount     : zmm_total_price,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual ScaleDetails : abap.string(0),

          @Semantics.text: true
          _PurchasingOrganization.PurchasingOrganizationName,

          PurchaseOrder,
          
          PurchasingHistoryDocument,

          POFilter,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual POStatus            : abap.int4,
   
  SupplierInvoiceReference,
  @Semantics.amount.currencyCode: 'TotalBonusCurrency'
  TotalBonus,
  TotalBonusCurrency,
  DieselPercentage,
  @ObjectModel.text.element: [ 'BusinessPartnerName1' ]
  OperationRegion,
  BusinessPartnerName1,
  
       @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual total_fuel_taken_liters : zmm_total_fuel_takenlt,
  
           @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual diff_liters             : zmm_diff_liters,
 
   @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  virtual earned_liter            : zmm_earned_liter,
  
  @Semantics.amount.currencyCode: 'TotalDeducamountC'
  TotalDeducamount,
  TotalDeducamountC,
  
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  @Semantics.amount.currencyCode: 'Currency'
  virtual total_fuel_ent_ex_vat : zmm_total_fuelexcvat,
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYRENTAL'
  @Semantics.amount.currencyCode: 'Currency'
  virtual total_fuel_cost_exc_vat : zmm_totalfuelcostexcvat,
  @Semantics.amount.currencyCode: 'Currency'
  AverageFuelAmountVehicle,
  
          /* Associations */
          _VehicleBody,
          _VehicleCategory,
          _VehicleType,
          _VestingDeduction,
          _VestingTypeMatching,
          _PurchasingOrganization
}
