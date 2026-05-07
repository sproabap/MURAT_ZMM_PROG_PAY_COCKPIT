@EndUserText.label: 'Progress Payment Rental Abstract Entity'
define abstract entity ZD_ProgressPaymentRental

{
  ProductName          : maktx;
  VehicleCategory      : zmm_vehiclecategory;
  //  VestingModel         : zmm_vestingmodel;
  Currency             : waers;

  @Semantics.amount.currencyCode: 'Currency'
  VestingAmount        : zmm_progress_pay_amount;

  @Semantics.amount.currencyCode: 'Currency'
  TotalDeductionAmount : zmm_total_deduction_amount;

  @Semantics.amount.currencyCode: 'Currency'
  BonusAmount          : zmm_additional_bonus_amount;

  ActualDays           : zmm_actual_days;

  ActualTripCount      : zsd_de_number_of_trips;
  ActualKM             : zmm_total_km;

  @Semantics.amount.currencyCode: 'Currency'
  FuelVestingAmount    : zmm_fuel_vesting_amount;

  //  @Semantics.amount.currencyCode: 'Currency'
  //  VehicleDeductionAmount : zvestdeductamount;

  @Semantics.amount.currencyCode: 'Currency'
  TotalVestingAmount   : zmm_total_progress_pay_amount;

  ScaleDetails         : abap.string(0);

  PurchaseOrder        : ebeln;

  //  PurchasingOrganization : vkorg;
}
