@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Route Item'

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType: { serviceQuality: #X, sizeCategory: #S, dataClass: #MIXED }

define view entity ZR_ProgressPaymentRouteItem
  as select from ZR_ProgressPayment     as ProgressPayment

    inner join   I_Product              as Product             on Product.Product = ProgressPayment.Product
    inner join   ZI_VestingTypeMatching as VestingTypeMatching on VestingTypeMatching.Vestingmodel = Product.YY1_MMVestingModel_PRD

  association [0..1] to ZI_MMVEHICLECATEGORY                 as _VehicleCategory    on  _VehicleCategory.Vehiclecategory = $projection.VehicleCategory

  association [0..1] to ZI_MMVEHICLETYPE                     as _VehicleType        on  _VehicleType.VehicleType = $projection.VehicleType

  association [0..1] to ZI_MMVEHICLEBODY                     as _VehicleBody        on  _VehicleBody.Vehiclebody = $projection.VehicleBody

  association [0..1] to ZI_MmVestingModel                    as _VestingModel       on  _VestingModel.Vestingmodel = $projection.VestingModel

  //  association [0..1] to I_DistributionChannel         as _DistributionChannel
  //    on _DistributionChannel.DistributionChannel = $projection.operationtype

  association [0..1] to ZI_TemperatureRegimes                as _TemperatureRegimes on  _TemperatureRegimes.TemperatureRegime = $projection.HeatRegimeType

  association [0..1] to ZI_DEPARTUREPROVINCES                as _DepartureProvince  on  _DepartureProvince.DepartureProvince = $projection.DepartureProvince

  association [0..1] to ZI_DEPARTUREDISTRICTs                as _DepartureDistrict  on  _DepartureDistrict.DepartureDistrict = $projection.DepartureDistrict

  association [0..1] to ZI_OriginPoints                      as _DeparturePoint     on  _DeparturePoint.OriginPoint = $projection.DeparturePoint

  association [0..1] to ZI_ARRIVALPROVINCES                  as _ArrivalProvince    on  _ArrivalProvince.ArrivalProvince = $projection.ArrivalProvince

  association [0..1] to ZI_ArrivalDistricts                  as _ArrivalDistrict    on  _ArrivalDistrict.Arrivaldistrict = $projection.ArrivalDistrict

  association [0..1] to ZI_DestinationPoints                 as _ArrivalPoint       on  _ArrivalPoint.DestinationPoint = $projection.ArrivalPoint

  association        to parent ZR_ProgressPaymentRouteHeader as _Header             on  _Header.CalendarYear           = $projection.CalendarYear
                                                                                    and _Header.CalendarMonth          = $projection.CalendarMonth
                                                                                    and _Header.Supplier               = $projection.Supplier
                                                                                    and _Header.Product                = $projection.Product
                                                                                    and _Header.Customer               = $projection.Customer
                                                                                    and _Header.PurchasingOrganization = $projection.PurchasingOrganization

{
  key ProgressPayment.CalendarYear,
  key ProgressPayment.CalendarMonth,
  key ProgressPayment.Supplier,
  key ProgressPayment.Product,
  key ProgressPayment.Customer,
  key ProgressPayment.DepartureProvince,
  key ProgressPayment.DepartureDistrict,
  key ProgressPayment.DeparturePoint,
  key ProgressPayment.ArrivalProvince,
  key ProgressPayment.ArrivalDistrict,
  key ProgressPayment.ArrivalPoint,
  key ProgressPayment.HeatRegimeType,
  key ProgressPayment.PurchasingOrganization,

      //      ProgressPayment._Product.YY1_VehicleCategory_PRD                       as VehicleCategory,
      ProgressPayment._VehicleCategoryPurhasing.VehicleCategory          as VehicleCategory,
      ProgressPayment._Product.YY1_MMVehicleType_PRD                     as VehicleType,
      ProgressPayment._Product.YY1_VehicleBody_PRD                       as VehicleBody,
      ProgressPayment._Product.YY1_VehicleCapacity_PRD                   as VehicleCapacity,
      ProgressPayment._Product.YY1_MMVestingModel_PRD                    as VestingModel,
      //      ProgressPayment.OperationType,
      ProgressPayment.Currency,

      cast(sum(ProgressPayment.NumberOfTrips) as zmm_actual_trip_count)  as ActualTripCount,
      cast(sum(ProgressPayment.TotalKM) as zmm_total_km preserving type) as ActualKM,

      ProgressPayment._Product,
      ProgressPayment._Supplier,
      ProgressPayment._Customer,


      _VehicleCategory,
      _VehicleType,
      _VehicleBody,
      _VestingModel,
      //      _DistributionChannel,
      _TemperatureRegimes,
      _DepartureDistrict,
      _DeparturePoint,
      _DepartureProvince,
      _ArrivalDistrict,
      _ArrivalPoint,
      _ArrivalProvince,
      ProgressPayment._PurchasingOrganization,

      _Header
}

where
      ProgressPayment.IsDeleted                                 is initial
  //  and ProgressPayment._Product.YY1_MMVestingModel_PRD  = '03'
  and VestingTypeMatching.Vestingtype                           =  'T'
  and ProgressPayment._VehicleCategoryPurhasing.VehicleCategory <> '03'

group by
  ProgressPayment.CalendarYear,
  ProgressPayment.CalendarMonth,
  ProgressPayment.Supplier,
  ProgressPayment.Product,
  ProgressPayment.Customer,
  ProgressPayment.PurchasingOrganization,
  ProgressPayment.DepartureProvince,
  ProgressPayment.DepartureDistrict,
  ProgressPayment.DeparturePoint,
  ProgressPayment.ArrivalProvince,
  ProgressPayment.ArrivalDistrict,
  ProgressPayment.ArrivalPoint,
  ProgressPayment.HeatRegimeType,
  //         ProgressPayment._Product.YY1_VehicleCategory_PRD,
  ProgressPayment._VehicleCategoryPurhasing.VehicleCategory,
  ProgressPayment._Product.YY1_MMVehicleType_PRD,
  ProgressPayment._Product.YY1_VehicleBody_PRD,
  ProgressPayment._Product.YY1_VehicleCapacity_PRD,
  ProgressPayment._Product.YY1_MMVestingModel_PRD,
  //         ProgressPayment.OperationType,
  ProgressPayment.Currency;
