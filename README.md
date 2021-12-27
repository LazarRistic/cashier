# Cashier

## Usage
```elixir
name = "CASHIERS_NAME_HERE"
pricing_rules = %{
  "GR1" => [Cashier.Core.PricingRule.BOGO],
  "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
  "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
}
Cashier.new name, pricing_rules
Cashier.scan name, "GR1"
Cashier.scan name, %Cashier.Core.Product{code: "GR1", name: "Green tea", price: Money.new(3_11, :GBP)}
Cashier.total name
```
## Description

You are the lead programmer for a small chain of supermarkets. You are required to make a simple
cashier function that adds products to a cart and displays the total price.
You have the following test products registered:
Product code Name Price
| Product |  code Name   | Price  |
| ------- | :----------: | :----: |
| GR1     |  Green tea   | £3.11  |
| SR1     | Strawberries | £5.00  |
| CF1     |    Coffee    | £11.23 |

## Special conditions:

- The CEO is a big fan of buy-one-get-one-free offers and of green tea. He wants us to add a
rule to do this.
- The COO, though, likes low prices and wants people buying strawberries to get a price
discount for bulk purchases. If you buy 3 or more strawberries, the price should drop to £4.50
per strawberry.
- The CTO is a coffee addict. If you buy 3 or more coffees, the price of all coffees should drop
to two thirds of the original price.

Our check-out can scan items in any order, and because the CEO and COO change their minds often,
it needs to be flexible regarding our pricing rules.

## Product

Product are located in Mix configuration file.

## Pricing rules

Pricing rules are in form of map, where key is product code and value is list of modules that use's `PricingRule` behavior