@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Route Item'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define view entity ZC_ProgressPaymentRouteItem
  //  provider contract transactional_query
  as projection on ZR_ProgressPaymentRouteItem
 
{
  key     CalendarYear,
  key     CalendarMonth,

          @ObjectModel.text.element: [ 'SupplierName' ]
  key     Supplier,

          @ObjectModel.text.element: [ 'ProductName' ]
  key     Product,

          @ObjectModel.text.element: [ 'CustomerName' ]
  key     Customer,

          @ObjectModel.text.element: [ 'DepartureProvinceDesc' ]
  key     DepartureProvince,

          @ObjectModel.text.element: [ 'departuredistrictDesc' ]
  key     DepartureDistrict,

          @ObjectModel.text.element: [ 'OriginDesc' ]
  key     DeparturePoint,

          @ObjectModel.text.element: [ 'Arrivalprovincedesc' ]
  key     ArrivalProvince,

          @ObjectModel.text.element: [ 'Arrivaldistrictdesc' ]
  key     ArrivalDistrict,

          @ObjectModel.text.element: [ 'DestDesc' ]
  key     ArrivalPoint,

          @ObjectModel.text.element: [ 'TemperatureRegimeDesc' ]
  key     HeatRegimeType,

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
          ActualTripCount,
          ActualKM,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_ITEM'
          @Semantics.amount.currencyCode: 'Currency'
  virtual VestingAmount          : zmm_progress_pay_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_ITEM'
          @Semantics.amount.currencyCode: 'Currency'
  virtual TotalDeductionAmount   : zmm_total_deduction_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_ITEM'
          @Semantics.amount.currencyCode: 'Currency'
  virtual BonusAmount            : zmm_additional_bonus_amount,

//          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_ITEM'
//          @Semantics.amount.currencyCode: 'Currency'
//  virtual FuelVestingAmount      : zmm_fuel_vesting_amount,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_ITEM'
          @Semantics.amount.currencyCode: 'Currency'
  virtual VehicleDeductionAmount : zmm_deduction,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGPAY_ROUTE_ITEM'
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
          _DepartureDistrict.departuredistrictDesc,

          @Semantics.text: true
          _DeparturePoint.OriginDesc,

          @Semantics.text: true
          _DepartureProvince.DepartureProvinceDesc,

          @Semantics.text: true
          _ArrivalDistrict.Arrivaldistrictdesc,

          @Semantics.text: true
          _ArrivalPoint.DestDesc,

          @Semantics.text: true
          _ArrivalProvince.Arrivalprovincedesc,

          @Semantics.text: true
          _TemperatureRegimes.TemperatureRegimeDesc,

          @Semantics.text: true
          _PurchasingOrganization.PurchasingOrganizationName,
          

          /* Associations */
          _Customer,
//          _DistributionChannel,
          _Product,
          _Supplier,
          _TemperatureRegimes,
          _VehicleBody,
          _VehicleCategory,
          _VehicleType,
          _VestingModel,
          _DepartureDistrict,
          _DeparturePoint,
          _DepartureProvince,
          _ArrivalDistrict,
          _ArrivalPoint,
          _ArrivalProvince,
          _PurchasingOrganization,

          _Header : redirected to parent ZC_ProgressPaymentRouteHeader
}
