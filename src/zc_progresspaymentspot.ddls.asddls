@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Progress Payment Spot'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_ProgressPaymentSpot
  provider contract transactional_query
  as projection on ZR_ProgressPaymentSpot
 
{
  key     TransportDocNo,

          CalendarYear,


          CalendarMonth,

          @ObjectModel.text.element: [ 'SupplierName' ]
          Supplier,

          @ObjectModel.text.element: [ 'ProductName' ]
          Product,

          @ObjectModel.text.element: [ 'CustomerName' ]
          Customer,

          @ObjectModel.text.element: [ 'PurchasingOrganizationName' ]
          PurchasingOrganization,

          @Semantics.amount.currencyCode: 'Currency'
          SpotPaymentPrice,

          @Semantics.amount.currencyCode: 'Currency'
          SpotFuelAmount,

          Currency,

          @ObjectModel.text.element: [ 'DistributionChannelName' ]
          OperationType,

          @ObjectModel.text.element: [ 'VehicleCategoryDescription' ]
          VehicleCategory,

          @ObjectModel.text.element: [ 'VehicleTypeDescription' ]
          VehicleType,

          @ObjectModel.text.element: [ 'VehicleBodyDescription' ]
          VehicleBody,

          VehicleCapacity,

          @Semantics.text: true
          _Supplier.SupplierName,

          @Semantics.text: true
          _Product._Text.ProductName                         : localized,

          @Semantics.text: true
          _Customer.CustomerName,

          @Semantics.text: true
          _VehicleCategory.Vehiclecategorydesc                as VehicleCategoryDescription,

          @Semantics.text: true
          _VehicleType.VehicleTypeDesc                        as VehicleTypeDescription,

          @Semantics.text: true
          _VehicleBody.Vehiclebodydesc                        as VehicleBodyDescription,

          @Semantics.text: true
          _DistributionChannel._Text.DistributionChannelName : localized,

          @Semantics.amount.currencyCode: 'Currency'
          //          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYSPOT'
  virtual AdditionalPromotion : zmm_additonal_premium,

          @Semantics.amount.currencyCode: 'Currency'
          //          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYSPOT'
  virtual Deduction           : zmm_deduction,

          @Semantics.amount.currencyCode: 'Currency'
          //          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYSPOT'
          ////////  virtual TotalPrice           : zmm_total_price,
          TotalPrice,

          //          _Payment.PaymentMade,

          PaymentMade,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYSPOT'
  virtual PaymentMadeStatus   : abap.int4,

          @Semantics.text: true
          _PurchasingOrganization.PurchasingOrganizationName,

          PurchaseOrder,
          
          
          PurchasingHistoryDocument,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYSPOT'
  virtual POStatus            : abap.int4,

//          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_PROGRESSPAYSPOT'
//  virtual POFilter            : abap_boolean,
          POFilter,

          BPTaxNumber,
          
          SupplierInvoiceReference,
          

          /* Associations */
          _Product,
          _Supplier,
          _Customer,
          _VehicleCategory,
          _VehicleType,
          _VehicleBody,
          _PurchasingOrganization
}
