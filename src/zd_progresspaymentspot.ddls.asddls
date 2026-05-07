@EndUserText.label: 'Progress Payment Spot Abstract Entity'
define abstract entity ZD_ProgressPaymentSpot

{
  CalendarYear           : calendaryear;
  CalendarMonth          : calendarmonth;
  Supplier               : lifnr;
  Product                : matnr;
  Customer               : kunnr;

  ProductName            : maktx;
  VehicleCategory        : zmm_vehiclecategory;

  @Semantics.amount.currencyCode: 'Currency'
  SpotPaymentPrice       : zsd_spot_payment_price;

  Currency               : waers;

  @Semantics.amount.currencyCode: 'Currency'
  AdditionalPromotion    : zmm_additonal_premium;

  @Semantics.amount.currencyCode: 'Currency'
  Deduction              : zmm_deduction;

  @Semantics.amount.currencyCode: 'Currency'
  TotalPrice             : zmm_total_price;

  @Semantics.amount.currencyCode: 'Currency'
  SpotFuelAmount         : zmm_spot_fuel_amount;

  PurchasingOrganization : vkorg;

  PurchaseOrder          : ebeln;
  //  @Consumption.filter: { mandatory: true, selectionType: #SINGLE }
  //  @EndUserText.label: 'Date'
//  PostingDate : abap.datn;
}
