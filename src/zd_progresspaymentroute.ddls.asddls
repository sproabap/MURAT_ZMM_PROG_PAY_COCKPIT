@EndUserText.label: 'Progress Payment Route Abstract Entity'
define abstract entity ZD_PROGRESSPAYMENTROUTE

{
  ProductName          : maktx;
  VehicleCategory      : zmm_vehiclecategory;
  Currency             : waers;

  @Semantics.amount.currencyCode: 'Currency'
  VestingAmount        : zmm_progress_pay_amount;

  @Semantics.amount.currencyCode: 'Currency'
  TotalDeductionAmount : zmm_total_deduction_amount;

  @Semantics.amount.currencyCode: 'Currency'
  BonusAmount          : zmm_additional_bonus_amount;

  ActualTripCount      : zsd_de_number_of_trips;
  ActualKM             : zsd_sdtotaldistance;

  @Semantics.amount.currencyCode: 'Currency'
  FuelVestingAmount    : zmm_fuel_vesting_amount;

  //  @Semantics.amount.currencyCode: 'Currency'
  //  VehicleDeductionAmount : zvestdeductamount;

  @Semantics.amount.currencyCode: 'Currency'
  TotalVestingAmount   : zmm_total_progress_pay_amount;

  PurchaseOrder        : ebeln;
}
