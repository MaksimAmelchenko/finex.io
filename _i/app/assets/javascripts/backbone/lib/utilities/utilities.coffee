@CashFlow.module 'Utilities', (Utilities, App, Backbone, Marionette, $, _) ->
  Utilities.numberToMoney = (value, idMoney) ->
    money = App.entities.moneys.get(idMoney)
    precision = money.get('precision')
    '<nobr>' + s.numberFormat(value, precision, '.', ' ') + '</nobr>'
